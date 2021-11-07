import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:wsa_pacman/android/permissions.dart';
import 'package:wsa_pacman/apk_installer.dart';
import 'package:wsa_pacman/main.dart';
import 'package:shared_value/shared_value.dart';
import 'package:synchronized/synchronized.dart';

import 'proto/options.pb.dart';

import 'package:fluent_ui/fluent_ui.dart';

class GState {
  static final connectionStatus = SharedValue(value: WSAPeriodicConnector.alertStatus);
  static final theme = PersistableValue(value: Options_Theme.SYSTEM, loader: (o)=>o.theme, setter: (o,e)=> o.theme = e); 
  static final ipAddress = SharedValue(value: "127.0.0.1");
  static final androidPort = PersistableValue(value: 58526, loader: (o)=>o.port, setter: (o,e)=>o.port = e);
  static final androidPortPending = SharedValue(value: androidPort.$.toString());
  //APK Info
  static final apkTitle = SharedValue<String>(value: "");
  static final package = SharedValue<String>(value: "");
  static final activity = SharedValue<String>(value: "");
  static final version = SharedValue<String>(value: "");
  static final permissions = SharedValue<Set<AndroidPermission>>(value: {});
  static final apkInstallType = SharedValue<InstallType?>(value: null);
  static final apkInstallState = SharedValue<InstallState>(value: InstallState.PROMPT);
  static final apkIcon = SharedValue<Widget?>(value: null);
  static final apkBackgroundIcon = SharedValue<Widget?>(value: null);
  static final apkForegroundIcon = SharedValue<Widget?>(value: null);
  static final apkBackgroundColor = SharedValue<Color?>(value: null);
  //Installation info
  static final errorCode = SharedValue<String>(value: "");
  static final errorDesc = SharedValue<String>(value: "");
}

extension Options_Theme_Mode on Options_Theme? {
  ThemeMode get mode {
    switch (this) {
      case Options_Theme.SYSTEM: return ThemeMode.system;
      case Options_Theme.LIGHT: return ThemeMode.light;
      case Options_Theme.DARK: return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }
}

class PersistableValue<T> extends SharedValue<T> {
  static final _protoLock = Lock();
  static final _fileLock = Lock();

  final Function(Options options, T value) _setter;
  static Options? _options;
  static File? _optionsFile;
  static final Future<Options> _optionsFuture = () async {
    final directory = Directory("${Env.USER_PROFILE}${RegExp(r'.*[/\\]$').hasMatch(Env.USER_PROFILE) ? '' : r'\'}.wsamanager\\")..createSync();
    _optionsFile = File("${directory.path}\\options.bin")..createSync()..openSync();
    return (_options = Options.fromBuffer(_optionsFile!.readAsBytesSync()));
  }();

  PersistableValue({String? key, required T value, required T Function(Options options) loader, required Function(Options options, T value) setter, bool autosave = false})
      : _setter = setter, super(key: key, value: value, autosave: autosave) {
    _withOptions((options) {super.$ = loader(options);});
  }

  static Future _withOptions(Function(Options options) setter) async {_protoLock.synchronized(() async {
    setter(_options ?? await _optionsFuture);
  });}

  static Future persistOptions() async {_fileLock.synchronized(() async {
    File optionsFile;
    if (_optionsFile != null) optionsFile = _optionsFile!;
    else {
      await _optionsFuture;
      optionsFile = _optionsFile!;
    }
    //optionsFile.writeAsBytesSync((_options ?? await _optionsFuture).writeToBuffer());
    Uint8List? optionBytes;
    await _withOptions((options) => optionBytes = options.writeToBuffer());
    optionsFile.writeAsBytesSync(optionBytes!);
  });}

  Future persist() => persistOptions();

  void _saveOptions() => _withOptions((options) => _setter(options, $));

  @override
  set $(T newValue) {
    super.$ = newValue;
    _saveOptions();
  }
}