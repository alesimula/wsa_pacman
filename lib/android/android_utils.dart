
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
  String get buttonText {switch (this) {
    case InstallType.UNKNOWN: return "Install";
    case InstallType.INSTALL: return "Install";
    case InstallType.REINSTALL: return "Reinstall";
    case InstallType.UPDATE: return "Update";
    case InstallType.DOWNGRADE: return "Downgrade (unsafe)";
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