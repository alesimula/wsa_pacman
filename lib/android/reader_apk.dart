// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, constant_identifier_names

import 'dart:isolate';
import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'android_utils.dart';
import 'permissions.dart';
import 'package:wsa_pacman/global_state.dart';
import 'package:wsa_pacman/main.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';

import 'dart:developer';
import 'dart:convert';
import 'package:jovial_svg/jovial_svg.dart';
import '../utils/regexp_utils.dart';
import '../utils/string_utils.dart';
import '../utils/misc_utils.dart';

class IsolateData {
  final String fileName;
  final SendPort pipe;
  final bool legacyIcon;
  //Listener has to execute this in the main thread
  execute(VoidCallback callback) {
    pipe.send(callback);
  }
  IsolateData(this.fileName, this.legacyIcon, this.pipe);
}

extension on int {
  String get asResId => "0x"+toRadixString(16).padLeft(8, '0');
}

/// Reads apk file data on a different process and updates global state
/// Must call [ApkReader.start] to start the process
class ApkReader {
  //I just put '&& true' there so I could conveniently switch it off
  static bool DEBUG = !kReleaseMode && true;
  static String APK_FILE = /*r'C:\Users\Alex\Downloads\com.atono.dropticket.apk'*/ '';
  static late Future<Map<String, Resource>> _resourceDump;
  static late Future<Map<int, String>> _stringDump;
  static late Future<Archive> _apkArchive;
  static int _versionCode = 0;

  static late final IsolateData data;
  static const String REGEX_QUOTED_TYPE = r'["'']type[0-9]+/([0-9]*)["'']';

  static Future<Archive> _initArchiveFile(File file) async {
    return ZipDecoder().decodeBytes(file.readAsBytesSync());
  }
  static void _initArchive() {
    //Maintain a lock on the file
    File file = File(APK_FILE)..open();
    _apkArchive = _initArchiveFile(file);
  }

  /// Decodes a binary xml
  static Future<Uint8List> _decodeXml(List<int> encoded) async {
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

  /// Returns the gradient as an aapt xml element
  static Future<String> getGradient(String gradientId) async {
    Resource? gradientRes = await getResources(gradientId);
    if (gradientRes == null || !gradientRes.values.first.endsWith(".xml")) return "";
    Archive apkFile = await _apkArchive;
    ArchiveFile? gradientFile = apkFile.findFile(gradientRes.values.first);
    if (gradientFile == null) return "";
    String gradient = RegExp("<gradient.*", multiLine: true, dotAll: true).firstMatch(await decodeXml(gradientFile.content, true))?.group(0) ?? "";
    return '<aapt:attr name="android:fillColor">$gradient</aapt:attr>';
  }

  /// Starts asyncronous task to retrieve the gradient xml, returns a placeholder string containing gradent ID
  static String _getGradientPlaceholder(Map<String, Future<String>> gradients, String gradientId) {
    String placeholder = "@@FUTURE_GRADIENT_$gradientId@@";
    if (gradients.containsKey(gradientId)) return placeholder;
    else gradients[gradientId] = getGradient(gradientId);
    return placeholder;
  }

  /// Returns xml string, clears errors and normalizes fields
  static Future<String> decodeXml(Uint8List encoded, [bool isGradient = false]) async {
    Map<String, Future<String>>? futureGradients = isGradient ? null : {};
    var xml = utf8.decode(await _decodeXml(encoded), allowMalformed: true);
    if (!isGradient) xml = xml.replaceAllMapped(RegExp('([\\s\\n]android:pathData=[\'"])[^M]*(M[0-9])'), (m) => m.group(1)!+m.group(2)! )
      .replaceAllMapped(RegExp('<(([a-zA-Z0-9]*)\\s+$REGEX_XML_NOCLOSE)(android:fillColor=[\'"])(type1/([0-9]*)[\'"])($REGEX_XML_NOCLOSE)>', multiLine: true, dotAll: true), 
        (m) => '<${m.group(1)!}${m.group(7)!.endsWith("/") ? m.group(7)!.substring(0, m.group(7)!.length-1) : m.group(7)!}>\n${_getGradientPlaceholder(futureGradients!, "0x"+int.parse(m.group(6)!).toRadixString(16).padLeft(8, '0'))}${m.group(7)!.endsWith("/") ? "\n</${m.group(2)}>" : "\n"}')
      .replaceAllMapped(RegExp('([cC]olor=[\'"])(type([0-9])+/([0-9]*))'), (m) => m.group(1)!+'#'+(int.parse(m.group(4)!).toRadixString(16).padLeft(8, '0')) )
      .replaceAllMapped(RegExp('([\\s\\n]android:fillType=[\'"])([0-9]*)'), (m) => m.group(1)!+ (fillType[m.group(2)!] ?? "winding") );
    else xml = xml.replaceAllMapped(RegExp('([cC]olor=[\'"])(type([0-9])+/([0-9]*))'), (m) => m.group(1)!+'#'+(int.parse(m.group(4)!).toRadixString(16).padLeft(8, '0')) )
      .replaceAll(RegExp("(xmlns:[^=\\s]*|android:angle)\\s*=\\s*$REGEX_XML_QUOTED"), "")
      .replaceAllMapped(RegExp('(android:type\\s*=\\s*[\'"])([0-9]*)'), (m) => m.group(1)! + (gradientType[m.group(2)!] ?? "linear"));
    
    if (!isGradient) {
      var gradientList = await Future.wait(futureGradients!.values);
      Map<String, String> gradientMap = {}; int i = 0;
      for (var gradient in futureGradients.keys) gradientMap[gradient] = gradientList[i++];
      xml = xml.replaceAllMapped(RegExp("@@FUTURE_GRADIENT_([a-zA-Z0-9]*)@@"), (m) => gradientMap[m.group(1)] ?? "");
    }
    return xml;
  }

  /// Retrieves a resource from the resource ID
  static Future<Resource?> getResources(String resId) async {
    Map<String, Resource> resources = await _resourceDump;
    if (DEBUG) log("checking RES-ID: $resId");
    var resource = resources[resId];
    if (resource != null) {
      if (DEBUG) log("found RES-VALUES: ${resource.values} of RES-TYPE: ${resource.type} for RES-ID: $resId");
      if (resource.type == ResType.COLOR) return resource;
      Map<int, String> strings = await _stringDump;
      Iterable<String> files = strings.getAll(resource.values.map((e) => int.parse(e, radix: 16)));
      if (DEBUG) log("found RES-FILES: $files of RES-TYPE: ${resource.type} for RES-ID: $resId");
      return files.isNotEmpty ? Resource(files, resource.type) : null;
    }
    else return null;
  }

  /// Retrieves non-adaptive icon image
  static Future _getIconFile(String fileName) async {
    bool isXml = fileName.endsWith(".xml");
    Archive apkFile = await _apkArchive;
    ArchiveFile IconFile = apkFile.findFile(fileName)!;
    
    Uint8List image = IconFile.content;
    String xmlData = isXml ? await decodeXml(image) : "";
    Widget? widget = isXml ? null : Image.memory(image);
    data.execute(() => GState.apkIcon.update((_) => isXml ? ScalableImageWidget(si: ScalableImage.fromAvdString(xmlData)) : widget));
  }

  /// Retrieves adaptive icon background and foreground images
  static Future _getAdaptiveIconFiles(String? backgroundId, String foregroundId) async {
    Future<Resource?>? futureBackground = backgroundId != null ? getResources(backgroundId) : null;
    Future<Resource?> futureForeground = getResources(foregroundId);
    Resource? background = futureBackground != null ? await futureBackground : null;
    Resource foreground = (await futureForeground)!;
    bool isBackColor = background?.type == ResType.COLOR;
    bool isBackXml = !isBackColor && (background?.values.isNotEmpty ?? false) && background!.values.first.endsWith(".xml");
    bool isForeXml = foreground.values.isNotEmpty && foreground.values.first.endsWith(".xml");
    
    Archive apkFile = await _apkArchive;
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
  }

  /// Retrieves installation type (whether installing for the first time, reinstalling the same version, upgrading or downgrading)
  static Future _loadInstallType(String package, int versionCode) async {if (package.isNotEmpty) {
    GState.androidPort;
    String ipAddress = await GState.ipAddress.whenReady();
    int port = await GState.androidPort.whenReady();

    return await Process.run('${Env.TOOLS_DIR}\\adb.exe', ['-s', '$ipAddress:$port', 'shell', 'dumpsys package $package']).then((result) {
      //cmd package dump
      var verMatch = RegExp(r'(\n|\s|^)versionCode=([0-9]*)[^\n]*(\n([^\s\n]*\s)*versionName=([^\n\s_$]*))?').firstMatch(result.stdout.toString());
      int? oldVersionCode = int.tryParse(verMatch?.group(2) ?? "");
      if (result.exitCode != 0) GState.apkInstallType.update((_) => InstallType.UNKNOWN);
      else if (oldVersionCode != null) {
        GState.apkInstallType.update((_) => (oldVersionCode < versionCode) ? InstallType.UPDATE : 
            (oldVersionCode > versionCode) ? InstallType.DOWNGRADE : InstallType.REINSTALL);
        String oldVersion = verMatch!.group(5) ?? "???";
        GState.oldVersion.update((_) => oldVersion);
      }
      else GState.apkInstallType.update((_) => InstallType.INSTALL);
    }).onError((_, __) {GState.apkInstallType.update((_) => InstallType.UNKNOWN);});
  } else return null;}

  //Retrieves APK information
  static void _loadApkData(IsolateData pData) async {
    data = pData;
    APK_FILE = data.fileName;
    //resourceDump = Process.run('${Env.TOOLS_DIR}\\aapt.exe', ['dump', 'resources', TEST_FILE]).then<String>((p) => p.stdout.toString());
    _resourceDump = Process.run('${Env.TOOLS_DIR}\\aapt.exe', ['dump', 'resources', APK_FILE]).then((p) => 
      p.stdout.toString().foldToMap(r'(^|\n)\s*resource\s+(0x[0-9a-zA-Z]*)[\s]+.*\st=0x0*([^\s\n]*).*\sd=0x0*([^\s\n]*)[\s|\n]', (m) => m.group(2)!, 
      (m,old) => Resource((old != null) ? ((old.values as ListQueue<String>)..addAll([m.group(4)!])) : ListQueue<String>.from([m.group(4)!]), old?.type ?? getResType(m.group(3)!)) )
    );
    //strings.findAll('(^|\\n|\\s)*String\\s+#(${resCodes.join("|")})\\s*:\\s*([^\\s\\n]*)', 3);
    _stringDump = Process.run('${Env.TOOLS_DIR}\\aapt.exe', ['dump', 'strings', APK_FILE]).then((p) => 
      p.stdout.toString().toMap(r'(^|\n)\s*String\s+#([0-9]*)\s*:\s*([^\s\n]*)', (m) => int.parse(m.group(2)!), (m) => m.group(3)!)
    );
    _initArchive();

    Future<bool> legacyIconFound = (data.legacyIcon) ? Process.run('${Env.TOOLS_DIR}\\axmldec.exe', ['-i', APK_FILE], stdoutEncoding: null).then((value) async {
      String manifest = utf8.decode(await _decodeXml(value.stdout), allowMalformed: true);
      String? icon = RegExp('<application\\s+${REGEX_XML_NOCLOSE}android:icon\\s*=\\s*$REGEX_QUOTED_TYPE', multiLine: true, dotAll: true).firstMatch(manifest)?.group(2);

      Resource? resource = icon != null ? await getResources(int.parse(icon).asResId) : null;
      // first: smaller - last: bigger ? (taking the second one)
      Iterator<String>? legacyIconFiles = resource?.values.where((e) => !e.endsWith('.xml')).iterator;
      String? iconFile = (legacyIconFiles?.moveNext() ?? false) ? legacyIconFiles!.current : null;
      if (legacyIconFiles?.moveNext() ?? false) iconFile = legacyIconFiles!.current;
      if (iconFile != null) await _getIconFile(iconFile);
      return iconFile != null;
    }).onError((_,__) => false) : Future.value(false);

    Future? iconUpdThread;
    Future<ProcessResult>? inner;
    var process = Process.run('${Env.TOOLS_DIR}\\aapt.exe', ['dump', 'badging', APK_FILE]).then((value) async {
      if (value.exitCode == 0) {
        String dump = value.stdout.toString();
        String? info = dump.find(r'(^|\n)package:.*');

        int versionCode = int.parse(info?.find(r"(^|\n|\s)versionCode=\s*'([^'\n\s$]*)", 2) ?? "0");
        data.execute(() {ApkReader._versionCode = versionCode;});

        String package = info?.find(r"(^|\n|\s)name=\s*'([^'\n\s$]*)", 2) ?? "";
        if (package.isNotEmpty) {
          data.execute(() {GState.package.update((_) => package); _loadInstallType(package, versionCode);});
        }
        //else data.execute(() => GState.apkInstallType.update((_) => InstallType.INSTALL));

        data.execute(() => GState.version.update((_) => info?.find(r"(^|\n|\s)versionName=\s*'([^'\n\s_$]*)", 2) ?? ""));
        data.execute(() => GState.activity.update((_) => dump.find(r"(^|\n)launchable-activity:.*name='([^'\n\s$]*)", 2) ?? ""));

        String? application = dump.find(r'(^|\n)application:\s*(.*)');
        String? title = application?.find(r"(^|\n|\s)label='([^']*)'", 2);
        String? icon = application?.find(r"(^|\n|\s)icon='([^']*)'", 2);
        data.execute(() => GState.apkTitle.update((_) => title ?? "UNKNOWN_TITLE"));

        Set<AndroidPermission> permissions = dump.toSet("(^|\\n)\\s*uses-permission:\\s+name=[\"']([^\"'\\n]*)", 
          (m) => AndroidPermissionList.get(m.group(2)!), (a,b)=> a.index - b.index);
        if (permissions.isEmpty) permissions.add(AndroidPermission.NONE);
        data.execute(() => GState.permissions.update((_) => permissions));
        
        if (data.legacyIcon && await legacyIconFound) return;
        else if (icon?.endsWith(".xml") ?? false) inner = Process.run('${Env.TOOLS_DIR}\\aapt2.exe', ['dump', 'xmltree', '--file', icon!, APK_FILE])..then((value) {
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
    data.execute(() async {if (GState.apkForegroundIcon.$ == null && GState.apkIcon.$ == null) {
      final fBackground = ScalableImage.fromAvdAsset(rootBundle, "assets/icons/missing_icon_background.xml");
      final fForeground = ScalableImage.fromAvdAsset(rootBundle, "assets/icons/missing_icon_foreground.xml");
      final background = await fBackground;
      final foreground = await fForeground;
      GState.apkBackgroundIcon.update((p0) => (ScalableImageWidget(si: background)));
      GState.apkForegroundIcon.update((p0) => (ScalableImageWidget(si: foreground)));
    }});
    //data.pipe.send("WOOOOOOOO2: ${coso.stdout.toString()}");
  }

  FutureOr<R> computeOrDebug<Q, R>(ComputeCallback<Q, R> callback, Q message, {String? debugLabel}) => (DEBUG) ? 
      callback(message) : compute(callback, message, debugLabel: debugLabel);

  /// Starts a process to read apk data
  static void start(String fileName) async {
    APK_FILE = fileName;
    Future<bool> legacyIcon = GState.legacyIcons.whenReady();
    ReceivePort port = ReceivePort();
    port.listen((message) {
      if (message is VoidCallback) {message();}
    });
    //Recheck installation type when connected
    compute(_loadApkData, IsolateData(fileName, await legacyIcon, port.sendPort));
    StreamSubscription? sub;
    sub = GState.connectionStatus.stream.listen((event) async {
      String package = GState.package.$;
      InstallType? installType = GState.apkInstallType.$;
      if (GState.apkInstallType.$ == InstallType.UNKNOWN) {
        await _loadInstallType(GState.package.$, _versionCode);
        if (GState.apkInstallType.$ != InstallType.UNKNOWN) sub?.cancel();
      }
      else if (installType != null) sub?.cancel();
    });
  }
}