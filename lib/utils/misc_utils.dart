// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as lib_path;
import 'package:archive/archive.dart';
import '../windows/win_io.dart';
import 'package:fluent_ui/fluent_ui.dart';

class DynamicTimer {
  int _durationUs;
  int _tick = 0;
  final void Function(Timer timer) _callback;
  Timer? _timer;

  DynamicTimer(this._callback) : _durationUs = -1;
  DynamicTimer.periodic(Duration _duration, this._callback) : _durationUs = _duration.inMicroseconds, _timer = Timer.periodic(_duration, _callback);

  void cancel() => _timer?.cancel();
  int get tick => _tick + (_timer?.tick ?? 0);
  bool get isActive => _timer?.isActive ?? false;

  /// Starts or restarts the timer with a new duration
  void setDuration(Duration duration) {
    if (duration.inMicroseconds == _durationUs) return;
    _timer?.cancel();
    _tick += _timer?.tick ?? 0;
    _durationUs = duration.inMicroseconds;
    _timer = Timer.periodic(duration, _callback);
  }
}

class ColorConst extends Color {
  const ColorConst.withOpacity(int value, double opacity) : super(
    ( (((opacity * 0xff ~/ 1) & 0xff) << 24) | ((0x00ffffff & value)) ) & 0xFFFFFFFF);
}

extension EdgeInsetsUtils on EdgeInsets {
  EdgeInsetsDirectional directional() => this is EdgeInsetsDirectional ? this as EdgeInsetsDirectional : EdgeInsetsDirectional.fromSTEB(left, top, right, bottom);
}

extension FileUtils<K,V> on FileSystemEntity {
  String get basename => lib_path.basename(path);
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

  Future<bool> extractAll(Directory directory, {bool replaceExisting = false, FileDisposeQueue? disposeLock}) async => extractAllSync(directory, replaceExisting: replaceExisting, disposeLock: disposeLock);
  bool extractAllSync(Directory directory, {bool replaceExisting = false, FileDisposeQueue? disposeLock }) {
    bool success = true;
    Future.wait([for (final file in files) () async {if (file.extractSync(directory, replaceExisting: replaceExisting, disposeLock: disposeLock)) success = false;}()]);
    return success;
  }
}

extension ArchiveFileUtils on ArchiveFile {
  Future<bool> extract(Directory directory, {bool replaceExisting = false, FileDisposeQueue? disposeLock}) async => extractSync(directory, replaceExisting: replaceExisting, disposeLock: disposeLock);
  bool extractSync(Directory directory, {bool replaceExisting = false, FileDisposeQueue? disposeLock}) {
    final file = File("${directory.absolute.path}\\$name");
    bool confirmExist = false;
    if (!replaceExisting && (confirmExist = file.existsSync())) return false;
    if (!confirmExist) file..createSync(recursive: true)..writeAsBytesSync(content);
    disposeLock?.add(file);
    return true;
  }
}