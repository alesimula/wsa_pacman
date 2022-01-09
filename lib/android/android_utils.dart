import 'package:wsa_pacman/utils/locale_utils.dart';

class Resource {
  ResType type;
  Iterable<String> values;
  Resource(this.values, [this.type = ResType.FILE]);
}

enum InstallState {
    PROMPT, INSTALLING, SUCCESS, ERROR
}
enum InstallType {
    UNKNOWN, INSTALL, REINSTALL, UPDATE, DOWNGRADE
}
enum ResType {
    COLOR, FILE
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