import 'package:archive/archive.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ColorConst extends Color {
  const ColorConst.withOpacity(int value, double opacity) : super(
    ( (((opacity * 0xff ~/ 1) & 0xff) << 24) | ((0x00ffffff & value)) ) & 0xFFFFFFFF);
}

extension MapUtils<K,V> on Map<K,V> {
  List<V> getAll(Iterable<K> keys) {
    List<V> list = [];
    for (var key in keys) {
      final value = this[key];
      if (value!=null) list.add(value);
    }
    return list;
  }
}

extension ArchiveUtils on Archive {
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