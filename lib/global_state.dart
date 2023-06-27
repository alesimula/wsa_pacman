// ignore_for_file: non_constant_identifier_names, constant_identifier_names, curly_braces_in_flow_control_structures, camel_case_extensions

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
export 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'package:protobuf/protobuf.dart';
import 'package:wsa_pacman/android/android_utils.dart';
import 'package:wsa_pacman/android/permissions.dart';
import 'package:wsa_pacman/main.dart';
import 'package:shared_value/shared_value.dart';
import 'package:synchronized/synchronized.dart';
import 'package:wsa_pacman/utils/locale_utils.dart';
import 'package:wsa_pacman/utils/misc_utils.dart';
import 'package:wsa_pacman/windows/win_info.dart';
import 'package:wsa_pacman/windows/win_io.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;

import 'proto/options.pb.dart';
import 'utils/string_utils.dart';
import 'utils/int_utils.dart';
import 'package:fluent_ui/fluent_ui.dart';

class GState {
  // App options
  static final connectionStatus = SharedValue(value: WSAPeriodicConnector.alertStatus);
  static final ipAddress = PersistableValue<String>(value: "127.0.0.1", loader: (o)=>o.ipAddress.asIpv4, setter:  (o,e)=>o.ipAddress = e.ipv4AsInt ?? IntUtils.LOCALHOST);
  static final androidPort = PersistableValue<int>(value: 58526, loader: (o)=>o.port, setter: (o,e)=>o.port = e);
  static final androidPortPending = SharedValue(value: androidPort.$.toString());
  // Interface options
  static final locale = PersistableValue<NamedLocale>(value: LocaleUtils.SYSTEM_LOCALE, loader: (o)=>LocaleUtils.fromLCIDOrDefault(o.locale), setter: (o,e)=> o.locale = e.lcid);
  // Theme options
  static final theme = PersistableValue<Options_Theme>(value: Options_Theme.SYSTEM, loader: (o)=>o.theme, setter: (o,e)=> o.theme = e); 
  static final iconShape = PersistableValue<Options_IconShape>(value: Options_IconShape.SQUIRCLE, loader: (o)=>o.iconShape, setter: (o,e)=> o.iconShape = e);
  static final legacyIcons = PersistableValue<bool>(value: false, loader: (o)=>o.legacyIcons, setter: (o,e)=> o.legacyIcons = e);
  static final mica = PersistableValue<Options_Mica>(value: Options_Mica.FULL, loader: (o)=>o.mica, setter: (o,e)=> o.mica = e);
  static final autostartWSA = PersistableValue<bool>(value: false, loader: (o)=>o.autostart, setter: (o,e)=> o.autostart = e);
  static final installTimeout = PersistableValue<int>(value: 30, loader: (o)=>o.timeout, setter: (o,e)=> o.timeout = e);
  // APK Info
  static final apkTitle = SharedValue<String>(value: "");
  static final package = SharedValue<String>(value: "");
  static final activity = SharedValue<String>(value: "");
  static final version = SharedValue<String>(value: "");
  static final oldVersion = SharedValue<String>(value: "");
  static final permissions = SharedValue<Set<AndroidPermission>>(value: {});
  static final apkInstallType = SharedValue<InstallType?>(value: null);
  static final apkInstallState = SharedValue<InstallState>(value: InstallState.PROMPT);
  static final apkIcon = SharedValue<Widget?>(value: null);
  static final apkBackgroundIcon = SharedValue<Widget?>(value: null);
  static final apkForegroundIcon = SharedValue<Widget?>(value: null);
  static final apkAdaptiveNoScale = SharedValue<bool>(value: false);
  static final apkBackgroundColor = SharedValue<Color?>(value: null);
  static final installCallback = SharedValue<Function(String ipAddress, int port, AppLocalizations lang, int timeout, [bool downgrade])?>(value: null);
  // Installation info
  static final errorCode = SharedValue<String>(value: "");
  static final errorDesc = SharedValue<String>(value: "");
}

const String UNLOCALIZED_OPTION = "UNLOCALIZED_OPTION";

extension Options_Micas_Ext on Options_Mica {
  static late final bool isSupported = WinVer.isWindows11OrGreater;
  bool get supported => isSupported;
  bool get disabled => this == Options_Mica.DISABLED || !isSupported;
  bool get enabled => this != Options_Mica.DISABLED && isSupported;
  bool get full => this == Options_Mica.FULL && isSupported;
  bool get partial => this == Options_Mica.PARTIAL && isSupported;

  String description(AppLocalizations lang) {switch (this) {
    case Options_Mica.FULL: return lang.theme_mica_full;
    case Options_Mica.PARTIAL: return lang.theme_mica_partial;
    case Options_Mica.DISABLED: return lang.settings_option_generic_disabled;
    default: return UNLOCALIZED_OPTION;
  }}
}

extension Options_IconShape_Ext on Options_IconShape? {
  double get radius {switch (this) {
    case Options_IconShape.SQUIRCLE: return 0.6;
    case Options_IconShape.CIRCLE: return 1;
    case Options_IconShape.ROUNDED_SQUARE: return 0.35;
    default: return 0.6;
  }}

  String description(AppLocalizations lang) {switch (this) {
    case Options_IconShape.SQUIRCLE: return lang.theme_icon_adaptive_squircle;
    case Options_IconShape.CIRCLE: return lang.theme_icon_adaptive_circle;
    case Options_IconShape.ROUNDED_SQUARE: return lang.theme_icon_adaptive_rounded_square;
    default: return UNLOCALIZED_OPTION;
  }}
}

extension Options_Theme_Mode on Options_Theme? {
  ThemeMode get mode {switch (this) {
    case Options_Theme.SYSTEM: return ThemeMode.system;
    case Options_Theme.LIGHT: return ThemeMode.light;
    case Options_Theme.DARK: return ThemeMode.dark;
    default: return ThemeMode.system;
  }}

  String description(AppLocalizations lang) {switch (this) {
    case Options_Theme.SYSTEM: return lang.settings_option_generic_system;
    case Options_Theme.LIGHT: return lang.theme_mode_light;
    case Options_Theme.DARK: return lang.theme_mode_dark;
    default: return UNLOCALIZED_OPTION;
  }}
}

class AppOptions {
  static const PERIODIC_FILE_CHECK_TIMER = Duration(seconds: 2);
  static final _fileLock = Lock();
  static final _protoLock = Lock();
  static Options? _options;
  static File? _optionsFile;
  static late Future<DateTime> _lastModified;
  static Future<Options> _optionsFuture = () async {
    // TODO options file migration; remove eventually
    final oldDirectory = Directory("${Env.USER_PROFILE}${RegExp(r'.*[/\\]$').hasMatch(Env.USER_PROFILE) ? '' : r'\'}.wsamanager\\");
    // TODO options file migration; remove eventually
    final _oldOtionsFile = File("${oldDirectory.path}\\options.bin");
    final directory = Directory("${Env.USER_PROFILE}${RegExp(r'.*[/\\]$').hasMatch(Env.USER_PROFILE) ? '' : r'\'}.wsa-pacman\\")..createSync();
    // TODO options file migration; remove eventually
    if (oldDirectory.existsSync()) {
      if (_oldOtionsFile.existsSync()) {
        if (!File("${directory.path}\\options.bin").existsSync()) _oldOtionsFile.copySync("${directory.path}\\options.bin");
        _oldOtionsFile.deleteSync();
      }
      oldDirectory.delete(recursive: false);
    }
    _optionsFile = File("${directory.path}\\options.bin")..createSync()..openSync();
    _lastModified = _optionsFile!.lastModified();
    directory.watch().listen((event) {
      if (event.path.endsWith('\\options.bin')) _checkSettingsFileChange();
    });
    try {return (_options = Options.fromBuffer(_optionsFile!.readAsBytesSync()));}
    on InvalidProtocolBufferException catch(_) {return Options();}
  }();

  static void _checkSettingsFileChange() async {
    late final bool shouldUpdate;
    await AppOptions._fileLock.synchronized(() async {
      final newLastModified = _optionsFile!.lastModifiedAccurate() ?? await _optionsFile!.lastModified();
      shouldUpdate = (newLastModified.isAfter(await _lastModified));
      if (shouldUpdate) _lastModified = Future.value(newLastModified);
    });
    if (shouldUpdate) {
      _options = null;
      _optionsFuture = () async {
        Options options;
        try {options = (_options = Options.fromBuffer(_optionsFile!.readAsBytesSync()));}
        on InvalidProtocolBufferException catch(_) {options = (_options = Options());}
        PersistableValue.reinitializeAll();
        return options;
      }();
    }
  }

  //Call to initialize reading options as soon as possible
  static void init() {}

  static Future withOptions(Function(Options options) setter) {return _protoLock.synchronized(() async {
    setter(_options ?? await _optionsFuture);
  });}
}

class PersistableValue<T> extends SharedValue<T> {

  final Function(Options options, T value) _setter;
  Future? _initializer;
  static final List<Function(Options options)> _reinitializers = [];
  static void reinitializeAll() => AppOptions.withOptions((options) {for (final reinitializer in _reinitializers) reinitializer(options);});

  PersistableValue({String? key, required T value, required T Function(Options options) loader, required Function(Options options, T value) setter, bool autosave = false})
      : _setter = setter, super(key: key, value: value, autosave: autosave){
    reinitializer(Options options) {super.setIfChanged(loader(options)); _initializer = null;}
    _initializer = AppOptions.withOptions(reinitializer);
    _reinitializers.add(reinitializer);
  }

  static Future persistOptions() {return AppOptions._fileLock.synchronized(() async {
    File optionsFile;
    if (AppOptions._optionsFile != null) optionsFile = AppOptions._optionsFile!;
    else {
      await AppOptions._optionsFuture;
      optionsFile = AppOptions._optionsFile!;
    }
    //optionsFile.writeAsBytesSync((_options ?? await _optionsFuture).writeToBuffer());
    Uint8List? optionBytes;
    await AppOptions.withOptions((options) => optionBytes = options.writeToBuffer());
    optionsFile.writeAsBytesSync(optionBytes!);
    AppOptions._lastModified = Future.value(DateTime.now());
  });}

  Future persist() => persistOptions();

  void _saveOptions() => AppOptions.withOptions((options) => _setter(options, $));

  void doWhenReady(void Function(T value) callback, [BuildContext? context]) {
    final initializer = _initializer;
    if (initializer != null) initializer.then((_)=>callback(context == null ? $ : of(context)));
    else callback(context == null ? $ : of(context));
  }

  Future<T> whenReady([BuildContext? context]) async {
    final initializer = _initializer;
    if (initializer != null) await initializer;
    return context == null ? $ : of(context);
  }

  @override
  T of(BuildContext? context) {
    // TODO: implement of
    return super.of(context);
  }

  @override
  set $(T newValue) {
    super.$ = newValue;
    _saveOptions();
  }
}