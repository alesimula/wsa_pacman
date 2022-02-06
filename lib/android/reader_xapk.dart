// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:collection/collection.dart';

import 'package:archive/archive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wsa_pacman/android/android_utils.dart';
import 'package:wsa_pacman/android/permissions.dart';
import 'package:wsa_pacman/android/reader_apk.dart';
import 'package:wsa_pacman/global_state.dart';
import 'package:wsa_pacman/main.dart';
import 'package:wsa_pacman/utils/misc_utils.dart';
import 'package:wsa_pacman/proto/manifest_xapk.pb.dart';
import 'package:wsa_pacman/utils/regexp_utils.dart';
import 'package:wsa_pacman/widget/adaptive_icon.dart';
import 'package:wsa_pacman/windows/nt_io.dart';
import 'package:wsa_pacman/windows/win_path.dart';

enum Architecture {
  amd64, i386, aarch64, arm, ppc64, ppc
}

extension Architectures on Architecture {
  static late final fullRegex = '(${[for (final arch in Architecture.values) for (final label in arch.labels) label].join('|')})';
  get regex => '(${[for (final label in labels) label].join('|')})';
  List<String> get labels => (){switch (this) {
    case Architecture.i386: return ["i386", "i686", "i586", "i486", "x86"];
    case Architecture.amd64: return ["x86_64", "amd64"];
    case Architecture.arm: return ["aarch32", "arm"];
    case Architecture.aarch64: return ["arm64", "aarch64"];
    case Architecture.ppc: return ["powerpc", "ppc"];
    case Architecture.ppc64: return ["powerpc64", "ppc64"];
  }}();
}



class XapkReader {
  static int _versionCode = 0;
  static String APK_FILE = '';
  static late Future<Archive> _xapkArchive;
  static late final Directory _xapkTempDir = Directory(WinPath.tempSubdir).createTempSync("XAPK-Extracted@$pid@");

  static Future<Archive> _initArchiveFile(File file) async => ZipDecoder().decodeBytes(file.readAsBytesSync());
  static void _initArchive() {
    //Maintain a lock on the file
    File file = File(APK_FILE)..open();
    _xapkArchive = _initArchiveFile(file);
  }

  static ManifestXapk _decodeManifest(List<int> bytes) => ManifestXapk.create()
    ..mergeFromProto3Json(utf8.decoder.fuse(json.decoder).convert(bytes));

  static void installXApk(String workingDir, List<String> apkFiles, List<ManifestXapk_ApkExpansion> expansions, String ipAddress, int port, AppLocalizations lang, [bool downgrade = false]) async {
    if (apkFiles.isNotEmpty) log("INSTALLING \"${apkFiles.first}\" on on $ipAddress:$port...");
    var installation = Process.run('${Env.TOOLS_DIR}\\adb.exe', ['-s', '$ipAddress:$port', 'install-multiple', if (downgrade) '-r', if (downgrade) '-d', ...apkFiles], workingDirectory: workingDir)
      .timeout(const Duration(seconds: 30)).onError((error, stackTrace) => ProcessResult(-1, -1, null, null));
    log("COMMAND: ${['-s', '$ipAddress:$port', 'install-multiple', if (downgrade) '-r', if (downgrade) '-d', ...apkFiles].join(" ")}");
    GState.apkInstallState.update((_) => InstallState.INSTALLING);
    var result = await installation;
    log("EXIT CODE: ${result.exitCode}");
    String error = result.stderr.toString();
    log("OUTPUT: ${result.stdout}");
    log("ERROR: $error");
    if (result.exitCode == 0) GState.apkInstallState.update((_) => InstallState.SUCCESS);
    else {
      GState.apkInstallState.update((_) => InstallState.ERROR);
      //TODO add cause
      RegExpMatch? errorMatch = RegExp(r'(^|\n)\s*adb:\s+failed\s+to\s+install\s+.*:\s+Failure\s+\[([^:]*):\s*([^\s].*[^\s])\s*\]').firstMatch(error);
      String errorCode = errorMatch?.group(2) ?? "";
      GState.errorCode.update((_) => errorCode.isNotEmpty ? errorCode : "UNKNOWN_ERROR");
      String errorDesc = errorMatch?.group(3) ?? "";
      GState.errorDesc.update((_) => errorDesc.isNotEmpty ? errorDesc : lang.installer_error_nomsg);
    }
  }

  static List<String> _getApkList(ManifestXapk manifest) {
    final archRegex = RegExp('^config\\.${Architectures.fullRegex}.*');
    final String defaultBaseName = '${manifest.packageName}.apk';
    Iterable<String> apkList;
    if (manifest.splitApks.isNotEmpty) {
      bool isBaseApk(ManifestXapk_ApkFile fileInfo) => fileInfo.id == 'base' || fileInfo.file == defaultBaseName;
      ManifestXapk_ApkFile? baseApk = manifest.splitApks.firstWhereOrNull(isBaseApk);
      if (manifest.splitApks.first == baseApk || baseApk == null) apkList = manifest.splitApks.map((e) => e.file);
      else apkList = [baseApk.file].followedBy(manifest.splitApks.whereNot(isBaseApk).map((e) => e.file));
    }
    else if (manifest.splitConfigs.isNotEmpty) {
      Iterable<String> configFiles = manifest.splitConfigs.map((e) => '$e.apk');
      apkList = manifest.splitConfigs.contains(manifest.packageName) ? configFiles : [defaultBaseName].followedBy(configFiles);
    }
    else apkList = [defaultBaseName];

    final List<String> archApkList = apkList.where((file) => archRegex.hasMatch(file)).toList();
    if (archApkList.isEmpty || archApkList.length == 1) return apkList.toList();
    apkList = apkList.whereNot((file) => archRegex.hasMatch(file));
    for (final arch in Architecture.values) {
      final regex = RegExp('^config\\.${arch.regex}.*');
      for (final file in archApkList) if (regex.hasMatch(file)) return apkList.followedBy([file]).toList();
    }
    return apkList.followedBy([apkList.first]).toList();
  }

  static void _readManifest(IsolateData pData) async { try {
    APK_FILE = pData.fileName;
    _initArchive();
    final archive = (await _xapkArchive);
    final manifestFile = archive.findFile('manifest.json');
    log("LOADING MANIFEST");
    // TODO loading
    if (manifestFile == null) return;
    log("READING MANIFEST");
    final manifest = _decodeManifest(manifestFile.content as List<int>);
    Set<AndroidPermission> permissions = manifest.permissions.map((perm) => AndroidPermissionList.get(perm)).whereNotNull().toSet();
    pData.execute(() {
      _versionCode = manifest.versionCode;
      GState.apkTitle.$ = manifest.name;
      GState.version.$ = manifest.versionName;
      GState.package.$ = manifest.packageName;
      GState.permissions.$ = permissions;
    });
    String iconFile = manifest.icon.isNotEmpty ? manifest.icon : "icon.png";
    final icon = archive.findFile(iconFile);
    final image = icon != null ? Image.memory(icon.content) : null;
    pData.execute(() async {
      if (image != null) {
        GState.apkAdaptiveNoScale.$ = true;
        GState.apkBackgroundIcon.$ = image;
        GState.apkForegroundIcon.$ = const SizedBox();
      }
      else ApkReader.setDefaultIcon(await GState.legacyIcons.whenReady());
    });

    final apkList = _getApkList(manifest);
    String installDir = _xapkTempDir.absolute.path;
    pData.execute(() {
      GState.installCallback.$ = (ipAddress, port, lang, [downgrade = false]) => installXApk(installDir, apkList, [], ipAddress, port, lang, downgrade);
    });



    /*final handle = NtIO.openDirectory(_xapkTempDir.absolute.path, true, true);
    log("HANDLE: $handle");*/

    archive.extractAllSync(_xapkTempDir);
    if (manifest.packageName.isNotEmpty) pData.execute(() {
      ApkReader.loadInstallType(manifest.packageName, manifest.versionCode);
    });

    log("DIRECTORY: ${_xapkTempDir.path}");
  } catch (e) {
    _xapkTempDir.deleteSync(recursive: true);
    //(await _xapkArchive).clear();
  }}


  /// Starts a process to read apk data
  static void start(String fileName) async {
    APK_FILE = fileName;
    ReceivePort port = ReceivePort();
    port.listen((message) {
      if (message is VoidCallback) {message();}
    });
    //Recheck installation type when connected
    compute(_readManifest, IsolateData(fileName, false, port.sendPort));
    StreamSubscription? sub;
    sub = GState.connectionStatus.stream.listen((event) async {
      String package = GState.package.$;
      InstallType? installType = GState.apkInstallType.$;
      if (GState.apkInstallType.$ == InstallType.UNKNOWN) {
        await ApkReader.loadInstallType(GState.package.$, _versionCode);
        if (GState.apkInstallType.$ != InstallType.UNKNOWN) sub?.cancel();
      }
      else if (installType != null) sub?.cancel();
    });
  }
}