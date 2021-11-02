// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' hide log;
import 'dart:typed_data';

import 'package:shared_value/shared_value.dart';
import 'package:wsa_pacman/global_state.dart';
import 'package:wsa_pacman/main.dart';
import 'package:wsa_pacman/widget/adaptive_icon.dart';
import 'package:wsa_pacman/widget/move_window_nomax.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'dart:developer';
import 'theme.dart';
import 'dart:convert';
import 'package:yaml/yaml.dart';
import 'package:jovial_svg/jovial_svg.dart';

extension on String {
  String? find(String regexp, [int group = 0]) {
    var matches = RegExp(regexp).allMatches(this);
      return (matches.isNotEmpty) ? matches.first.group(group)! : null;
  }

  Iterable<String> findAll(String regexp, [int group = 0]) {
    return RegExp(regexp).allMatches(this).map((m) => m.group(group)!);
  }

  Iterable<R> findAllAnd<R>(String regexp, R Function(Match) provider) {
    return RegExp(regexp).allMatches(this).map((m) => provider(m));
  }
}

extension on Archive {
  List<ArchiveFile> getFiles(Iterable<String>? names) {
    List<ArchiveFile> files = [];
    if (names == null || names.isEmpty) return files;
    var regex = RegExp('^(${names.join("|")})\$');
    for (var file in this.files) {
      if (regex.hasMatch(file.name)) files.add(file);
    }
    return files;
  }
}

enum InstallState {
    PROMPT, INSTALLING, SUCCESS, ERROR
}
enum InstallType {
    INSTALL, UPDATE, DOWNGRADE
}
enum ResType {
    COLOR, FILE
}
ResType getResType(String typeId) {switch (typeId) {
  case "1d": return ResType.COLOR;
  case "1c": return ResType.COLOR;
  default: return ResType.FILE;
}}
Map<String, String> fillType = {
  "0": "winding",
  "1": "evenOdd",
  "2": "inverseWinding",
  "3": "inverseEvenOdd",
};
class Resource {
  ResType type;
  Iterable<String> values;
  Resource(this.values, [this.type = ResType.FILE]);
}

class ApkReader {
  //I just put '&& true' there so I could conveniently switch it off
  static bool DEBUG = !kReleaseMode && true;
  static String TEST_FILE = /*r'C:\Users\Alex\Downloads\com.atono.dropticket.apk'*/ '';
  static late Future<String> resourceDump;
  static late Future<String> stringDump;
  static late Future<Archive> apkArchive;

  static late final ProcessData data;

  static Future<Archive> _initArchive(File file) async {
    return ZipDecoder().decodeBytes(file.readAsBytesSync());
  }
  static void initArchive() {
    //Maintain a lock on the file
    File file = File(TEST_FILE)..open();
    apkArchive = compute(_initArchive, file);
  }

  ///Decodes a binary xml
  static Future<Uint8List> _decodeXml(Uint8List encoded) async {
    var axmldec = await Process.start('${Env.TOOLS_DIR}\\axmldec.exe', []);
    axmldec.stdin.add(encoded);
    //For some reason i need this
    axmldec.stdin.writeln();
    await axmldec.stdin.flush();
    await axmldec.stdin.close();
    var builder = BytesBuilder();
    //Encoded is just there not to create a new empty list
    await axmldec.stdout.fold(encoded, (prev, newv){builder.add(newv); return prev;});
    return builder.takeBytes();
  }

  //Returns xml string, clears errors and normalizes fields
  static Future<String> decodeXml(Uint8List encoded) async {
    var xml = utf8.decode(await _decodeXml(encoded), allowMalformed: true);
    return xml.replaceAllMapped(RegExp('([\\s\\n]android:pathData=[\'"])[^M]*(M[0-9])'), (m) => m.group(1)!+m.group(2)! )
      //TODO gradients <aapt:attr name="android:fillColor"> <gradient ...
      .replaceAllMapped(RegExp('([cC]olor=[\'"])(type([0-9])+/([0-9]*))'), (m) => m.group(1)!+'#'+(int.parse(m.group(4)!).toRadixString(16).padLeft(8, '0')) )
      .replaceAllMapped(RegExp('([\\s\\n]android:fillType=[\'"])([0-9]*)'), (m) => m.group(1)!+ (fillType[m.group(2)!] ?? "winding") );
  }

  //TODO use a map to avoid searching for values twice
  static Future<Resource?> getResources(String resId) async {
    String resources = await resourceDump;
    ResType? type;
    if (DEBUG) log("checking RES-ID: $resId");
    Iterable<dynamic>? resCodes = resources.findAllAnd('(^|\\s|\\n)*$resId[\\s]+.*\\st=0x0*([^\\s\\n]*).*\\sd=0x0*([^\\s\\n]*)[\\s|\\n]', (m) =>
       ((type ??= getResType(m.group(2)!)) == ResType.FILE) ? int.parse(m.group(3)!, radix: 16) : m.group(3)! );
    if (resCodes.isNotEmpty) {
      if (DEBUG) log("found RES-VALUES: $resCodes of RES-TYPE: $type for RES-ID: $resId");
      //Fix 'type' not resolved in release mode because of the lazy nature of the 'map' function
      resCodes.first;
      if (type == ResType.COLOR) return Resource(resCodes.map((e)=>e), type!);
      //resCodes as Iterable<int>;
      String strings = await stringDump;
      Iterable<String> files = strings.findAll('(^|\\n|\\s)*String\\s+#(${resCodes.join("|")})\\s*:\\s*([^\\s\\n]*)', 3);
      if (DEBUG) log("found RES-FILES: $files of RES-TYPE: $type for RES-ID: $resId");
      return files.isNotEmpty ? Resource(files, type!) : null;
    }
    else return null;
  }

  static Future _getIconFile(String fileName) async {
    bool isXml = fileName.endsWith(".xml");
    Archive apkFile = await apkArchive;
    ArchiveFile IconFile = apkFile.findFile(fileName)!;
    
    Uint8List image = IconFile.content;
    String xmlData = isXml ? await decodeXml(image) : "";
    Widget? widget = isXml ? null : Image.memory(image);
    data.execute(() => GState.apkIcon.update((_) => isXml ? ScalableImageWidget(si: ScalableImage.fromAvdString(xmlData)) : widget));
  }

  static Future _getAdaptiveIconFiles(String? backgroundId, String foregroundId) async {
    /*String resources = await resourceDump;
    Iterable<int>? bCode = (backgroundId != null) ? resources.findAll('(^|\\s|\\n)*$backgroundId[\\s]+.*\\sd=0x0*([^\\s\\n]*)[\\s|\\n]', 2).map((s) => int.parse(s, radix: 16)) : null;
    Iterable<int> fCode = resources.findAll('(^|\\s|\\n)*$foregroundId[\\s]+.*\\sd=0x0*([^\\s\\n]*)[\\s|\\n]', 2).map((s) => int.parse(s, radix: 16));

    //this log somehow appears to slow down the process
    if (DEBUG) log("BACKGROUND-RES: $bCode\nFOREGROUND-RES: $fCode");

    String strings = await stringDump;
    Iterable<String>? bFiles = (bCode != null) ? strings.findAll('(^|\\n|\\s)*String\\s+#(${bCode.join("|")})\\s*:\\s*([^\\s\\n]*)', 3) : null;
    Iterable<String>? fFiles = strings.findAll('(^|\\n|\\s)*String\\s+#(${fCode.join("|")})\\s*:\\s*([^\\s\\n]*)', 3);
    if (DEBUG) {
      log("BACKGROUND-IMG: $bFiles");
      log("FOREGROUND-IMG: $fFiles");
    }*/

    Future<Resource?>? futureBackground = backgroundId != null ? getResources(backgroundId) : null;
    Future<Resource?> futureForeground = getResources(foregroundId);
    Resource? background = futureBackground != null ? await futureBackground : null;
    Resource foreground = (await futureForeground)!;
    bool isBackColor = background?.type == ResType.COLOR;
    bool isBackXml = !isBackColor && (background?.values.isNotEmpty ?? false) && background!.values.first.endsWith(".xml");
    bool isForeXml = foreground.values.isNotEmpty && foreground.values.first.endsWith(".xml");
    
    Archive apkFile = await apkArchive;
    List<ArchiveFile>? backFiles = isBackColor ? [] : apkFile.getFiles(background?.values);
    List<ArchiveFile> foreFiles = apkFile.getFiles(foreground.values);
    
    Uint8List foreImg = isForeXml ? foreFiles.first.content : foreFiles.last.content;
    Uint8List? backImg = (backFiles.isEmpty) ? null : isBackXml ? backFiles.first.content : backFiles.last.content;
    var foreXml = isForeXml ? decodeXml(foreImg) : null;
    var backXml = isBackXml ? decodeXml(foreImg) : null;
    Widget? backWidget;
    Widget? foreWidget;

    
    if (!isForeXml) foreWidget = Image.memory(foreImg);
    if (!isBackXml) backWidget = isBackColor ? null : (backImg != null) ? Image.memory(backImg) : null;

    String backXmlData = isBackXml ? await backXml! : "";
    String foreXmlData = isForeXml ? await foreXml! : "";

    if (isBackColor) {
      final color = Color(int.parse(background!.values.first, radix: 16));
      data.execute(() => GState.apkBackgroundColor.update((_)=>color));
    }
    else if (backWidget != null) data.execute(() => GState.apkBackgroundIcon.update((_)=>!isBackXml ? backWidget : ScalableImageWidget(si: ScalableImage.fromAvdString(backXmlData))));
    data.execute(() => GState.apkForegroundIcon.update((_)=>!isForeXml ? foreWidget : ScalableImageWidget(si: ScalableImage.fromAvdString(foreXmlData)) ));
    
    /*log('XML: ${foreXml}');
    GState.apkForegroundIcon.update((a)=>ScalableImageWidget(si: ScalableImage.fromAvdString(foreXml)) );
    //GState.apkBackgroundIcon.update((a)=>ScalableImageWidget(si: ScalableImage.fromAvdString(bbb)) );
    if (isBackColor) GState.apkBackgroundColor.update((p0) => Color(int.parse(background!.values.first, radix: 16)));
    else if (backXml != null)  GState.apkForegroundIcon.update((a)=>ScalableImageWidget(si: ScalableImage.fromAvdString(backXml)) );*/
    //ScalableImageWidget(si: ScalableImage.fromAvdString(ic_launcher));
    //SvgPicture.memory(xmlBytes);

    
    
    //TODO Uncomment this
    /*GState.apkForegroundIcon.update((a)=>Image.memory(forePNG));
    if (backPNG != null) GState.apkBackgroundIcon.update((a)=>Image.memory(backPNG));
    //apkFile.files.where((a)=>false);
    log("SIZE2 "+foreFiles.length.toString());
    log("done"+apkFile.toString());*/
  }

  //Retrieves APK information (Make sync?)
  static void _init(ProcessData pData) async {
    data = pData;
    TEST_FILE = data.fileName;
    //resourceDump = Process.run('${Env.TOOLS_DIR}\\aapt.exe', ['dump', 'resources', TEST_FILE]).then<String>((p) => p.stdout.toString());
    resourceDump = compute( (String file) async {return await Process.run('${Env.TOOLS_DIR}\\aapt.exe', ['dump', 'resources', file]).then<String>((p) => p.stdout.toString());}, TEST_FILE );
    stringDump = compute( (String file) async {return await Process.run('${Env.TOOLS_DIR}\\aapt.exe', ['dump', 'strings', file]).then<String>((p) => p.stdout.toString());}, TEST_FILE );
    initArchive();

    Future? iconUpdThread;
    Future<ProcessResult>? inner;
    var process = Process.run('${Env.TOOLS_DIR}\\aapt.exe', ['dump', 'badging', TEST_FILE])..then((value) {
      if (value.exitCode == 0) {
        String dump = value.stdout.toString();
        String? info = dump.find(r'(^|\n)package:.*');

        data.execute(() => GState.package.update((_) => info?.find(r"(^|\n|\s)name=\s*'([^'\n\s$]*)", 2) ?? ""));
        String versionCode = info?.find(r"(^|\n|\s)versionCode=\s*'([^'\n\s$]*)", 2) ?? "";
        data.execute(() => GState.version.update((_) => info?.find(r"(^|\n|\s)versionName=\s*'([^'\n\s$]*)", 2) ?? ""));
        data.execute(() => GState.activity.update((_) => dump.find(r"(^|\n)launchable-activity:.*name='([^'\n\s$]*)", 2) ?? ""));

        String? application = dump.find(r'(^|\n)application:\s*(.*)');
        String? title = application?.find(r"(^|\n|\s)label='([^']*)'", 2);
        String? icon = application?.find(r"(^|\n|\s)icon='([^']*)'", 2);
        data.execute(() => GState.apkTitle.update((_) => title ?? "UNKNOWN_TITLE"));
        //TODO check type of installation
        data.execute(() => GState.apkInstallType.update((p0) => InstallType.INSTALL));
        
        if (icon?.endsWith(".xml") ?? false) inner = Process.run('${Env.TOOLS_DIR}\\aapt2.exe', ['dump', 'xmltree', '--file', icon!, TEST_FILE])..then((value) {
          if (value.exitCode != 0) {log("XML ICON ERROR"); return;}
          String iconData = value.stdout.toString();
          String? background = iconData.find(r'(^|\n|\s)*E:[\s]?background\s[^\n]*\n\s*A:.*=@([^\s\n]*)', 2);
          String? foreground = iconData.find(r'(^|\n|\s)*E:[\s]?foreground\s[^\n]*\n\s*A:.*=@([^\s\n]*)', 2);
          
          if (DEBUG) log("APK-ICON-IDS: background_id=$background, foreground_id=$foreground");

          //then is apparently not called immediately
          /*resourceDump.then((value){
            String resources = value.stdout.toString();
            log(resources.findAll('(^|\\s|\\n)*$background[\\s]+.*\\sd=0x0*([^\\s\\n]*)[\\s|\\n]', 2).map((s)=>'#$s').toString());
          });*/
          if (foreground != null) iconUpdThread = _getAdaptiveIconFiles(background, foreground);
          else iconUpdThread= _getIconFile(icon);
        }); else if (icon != null && icon.isNotEmpty) {
          //Probably a png
          iconUpdThread = _getIconFile(icon);
        }
        if (DEBUG) log("APK-INFO:  title='$title', icon='$icon'");
      }
      else {
        log("ERROR");
      }
    }).onError((error, stackTrace) {
      //data.pipe.send("WEEEERROR: $stackTrace");
    });
    await process;
    if (inner != null) await inner;
    if (iconUpdThread != null) await iconUpdThread;
    //data.pipe.send("WOOOOOOOO2: ${coso.stdout.toString()}");
  }

  FutureOr<R> computeOrDebug<Q, R>(ComputeCallback<Q, R> callback, Q message, {String? debugLabel}) => (DEBUG && false) ? 
      callback(message) : compute(callback, message, debugLabel: debugLabel);

  static void init(String fileName) async {
    ReceivePort port = ReceivePort();
    port.listen((message) {
      if (message is VoidCallback) {
        log("RECEIVED-FUNCTION");
        message();
      }
      else log("RECEIVED-MESSAGE: $message");
    });
    compute(_init, ProcessData(fileName, port.sendPort));
  }
}

class ProcessData {
  final String fileName;
  final SendPort pipe;
  //Listener has to execute this in the main thread
  execute(VoidCallback callback) {
    pipe.send(callback);
  }
  ProcessData(this.fileName, this.pipe);
}

class ApkInstaller extends StatefulWidget {
  const ApkInstaller({Key? key}) : super(key: key);

  static void installApk(String apkFile, String ipAddress, int port) async {
    log("INSTALLING \"$apkFile\" on on $ipAddress:$port...");
    var installation = Process.run('${Env.TOOLS_DIR}\\adb.exe', ['-s', '$ipAddress:$port', 'install', apkFile])
      .timeout(const Duration(seconds: 30)).onError((error, stackTrace) => ProcessResult(-1, -1, null, null));
    GState.apkInstallState.update((_) => InstallState.INSTALLING);
    var result = await installation;
    log("EXIT CODE: ${result.exitCode}");
    if (exitCode == 0) GState.apkInstallState.update((_) => InstallState.SUCCESS);
    else {
      GState.apkInstallState.update((_) => InstallState.ERROR);
      //TODO add cause
    }
  }

  @override
  _ApkInstallerState createState() => _ApkInstallerState();
}

class _ApkInstallerState extends State<ApkInstaller> {
  int index = 0;
  
  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    Widget icon;
    String appTitle = GState.apkTitle.of(context);
    Widget? aForeground = GState.apkForegroundIcon.of(context);
    Widget? lIcon = GState.apkIcon.of(context);
    WSAStatusAlert connectionStatus = GState.connectionStatus.of(context);
    InstallType? installType = (connectionStatus.severity == InfoBarSeverity.success) ? GState.apkInstallType.of(context) : null;
    InstallState installState = GState.apkInstallState.of(context);

    String package = GState.package.of(context);
    String activity = GState.activity.of(context);
    bool isLaunchable = package.isNotEmpty && activity.isNotEmpty;

    String ipAddress = GState.ipAddress.of(context);
    int port = GState.androidPort.of(context);

    if (aForeground != null) icon = AdaptiveIcon(backColor: GState.apkBackgroundColor.of(context), background: GState.apkBackgroundIcon.of(context), foreground: aForeground);
    else if (lIcon != null) icon = lIcon;
    else icon = const ProgressRing();

    Widget titleWidget = Row (
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(child: SizedBox(width: 30.00, height: 30.00, child: icon)), const Flexible(child: SizedBox(width: 20)), Text(appTitle, style: FluentTheme.of(context).typography.subtitle), 
                //Spacer(), WindowButtons()
      ]
    );

    return Mica(child: moveWindow(Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ((){switch(installState) {case InstallState.PROMPT: return [
          titleWidget,
          Column (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 10),
              Text("Do you want to install this application?"),
            ]
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              noMoveWindow(Button(
                child: const Text('Cancel'),
                onPressed: false ? null : (){appWindow.close();},
              )),
              const SizedBox(width: 15),
              noMoveWindow(ToggleButton(
                child: const Text('Install'),
                checked: true,
                onChanged: installType == null ? null : (_){ApkInstaller.installApk(ApkReader.TEST_FILE, ipAddress, port) ;},
              )),
              /*const SizedBox(width: 15),noMoveWindow(ToggleButton(
                child: const Text('TEST-ICON'),
                checked: true,
                onChanged: (_){ApkReader.init();},
              ))*/
            ]
          )
        ];
        case InstallState.INSTALLING: return [
          titleWidget,
          const SizedBox(height: 10),
          Text("Installing application $appTitle..."),
          const Spacer(),
          Row(children: const [Expanded(child: ProgressBar(strokeWidth: 6))]),
        ];
        case InstallState.SUCCESS: return [
          titleWidget,
          const SizedBox(height: 10),
          Text("The application $appTitle was successifully installed"),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              noMoveWindow(Button(
                child: const Text('Dismiss'),
                onPressed: (){appWindow.close();},
              )),
              (){return isLaunchable ? const SizedBox(width: 15) : SizedBox.shrink();}(),
              (){return isLaunchable ? noMoveWindow(ToggleButton(
                child: const Text('Open app'),
                checked: true,
                onChanged: (_){log('am start -n ${GState.package.of(context)}/${GState.activity.of(context)}'); Process.run('${Env.TOOLS_DIR}\\adb.exe', ['-s', '$ipAddress:$port', 'shell', 'am start -n ${GState.package.of(context)}/${GState.activity.of(context)}']);},
              )) : const SizedBox.shrink();}()
            ]
          )
        ];
        case InstallState.ERROR: return [
          titleWidget,
          const SizedBox(height: 10),
          Text("The application $appTitle was successifully installed"),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              noMoveWindow(Button(
                child: const Text('Dismiss'),
                onPressed: (){appWindow.close();},
              ))
            ]
          )
        ];
        default: return [] as List<Widget> ;
        }})(),
      ),
    )));
  }
}