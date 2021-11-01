
// ignore_for_file: curly_braces_in_flow_control_structures

class Node {
  int _hIndex;
  Node? parent;
  final List<String> values;
  final Map<String, Node> children = {};

  bool get hasValues => values.isNotEmpty;
  bool get hasChildren => children.isNotEmpty;
  String? get value => values.isNotEmpty ? values[0] : null;

  Node(this._hIndex, this.values, {this.parent});
  Node.single(String value) : this(0, [value]);
  Node.empty() : this(0, []);
}

//Missing grouping and kind of janky
//Using regular expressions for now
Map<String, Node> read(String output) {
  bool inThisNode = true;
  int? substrIndex = 0;
  int? lastNodePos = 0;
  Node? lastNode;
  Node? newNode;
  Map<String, Node> map = {};
  for (var e in output.split('\n')) {
    substrIndex = e.indexOf(':');
    if (substrIndex == -1) {newNode = null; continue;}
    inThisNode = true;
    int nodePos = e.indexOf(RegExp(r'[^\s]'));
    int _lastPos = (lastNodePos ?? nodePos);

    String key = e.substring(0,substrIndex).trim();
    String value = e.substring(substrIndex+1).trim();

    var parent = lastNode?.parent;
    if (_lastPos != nodePos || parent != null) {
      inThisNode = false;
      if (_lastPos < nodePos) {
        newNode = Node(nodePos, [value], parent: lastNode);
        lastNode!.children[key] = newNode;
        lastNode = newNode;
      }
      else {
        while (lastNode!._hIndex != nodePos) lastNode = lastNode.parent;
        var parent = lastNode.parent;
        if (parent == null) inThisNode = true;
        else parent.children[key] = (lastNode = Node(nodePos, [value], parent: parent));
      }
    }
    lastNodePos = nodePos;
    //log("NODE: ${nodePos}");
    if (inThisNode) lastNode = (newNode = Node(nodePos, [value]));
    if(key.isNotEmpty && inThisNode) map[key] = newNode!;
  }
  return map;
}
