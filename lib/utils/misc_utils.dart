import 'package:archive/archive.dart';

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