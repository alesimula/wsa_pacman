// ignore_for_file: constant_identifier_names

import 'package:wsa_pacman/android/reader_apk.dart';
import 'package:wsa_pacman/android/reader_xapk.dart';
import 'package:wsa_pacman/io/isolate_runner.dart';
import 'package:wsa_pacman/utils/locale_utils.dart';

class Resource {
  ResType type;
  Iterable<String> values;
  Resource(this.values, [this.type = ResType.FILE]);
}

/// Flags passed to the apk reader isolates
enum APK_READER_FLAGS {
  UI_LOADED, LEGACY_ICON
}

enum InstallState {
  PROMPT, INSTALLING, SUCCESS, ERROR, TIMEOUT
}
enum InstallType {
  UNKNOWN, INSTALL, REINSTALL, UPDATE, DOWNGRADE
}
enum ResType {
  COLOR, POINTER, FILE
}
enum AppPackage {
  NONE, APK, XAPK
}

extension AppPackageType on AppPackage {
  static AppPackage fromArguments(List<String> args) => args.isEmpty ? AppPackage.NONE : fromFilename(args.first);
  static AppPackage fromFilename(String? name) => name == null || name.isEmpty ? AppPackage.NONE : 
      name.endsWith(".xapk") ? AppPackage.XAPK : AppPackage.APK;
  IsolateRef<String, APK_READER_FLAGS>? Function(String) get read { switch (this) {
    case AppPackage.APK: return ApkReader().start;
    case AppPackage.XAPK: return XapkReader().start;
    case AppPackage.NONE: return (_)=>null;
  }}
  bool get directInstall => this == AppPackage.APK;
}

extension InstallTypeExt on InstallType {
  String buttonText(AppLocalizations locale) {switch (this) {
    case InstallType.UNKNOWN: return locale.installer_btn_install;
    case InstallType.INSTALL: return locale.installer_btn_install;
    case InstallType.REINSTALL: return locale.installer_btn_reinstall;
    case InstallType.UPDATE: return locale.installer_btn_update;
    case InstallType.DOWNGRADE: return locale.installer_btn_downgrade;
  }}
}
ResType getResType(String typeId) {switch (typeId) {
  case "1d": return ResType.COLOR;
  case "1c": return ResType.COLOR;
  case "1": return ResType.POINTER;
  default: return ResType.FILE;
}}
Map<String, String> fillType = {
  "0": "winding",
  "1": "evenOdd",
  "2": "inverseWinding",
  "3": "inverseEvenOdd",
};
Map<String, String> gradientType = {
  "0": "linear",
  "1": "radial",
  "2": "sweep"
};