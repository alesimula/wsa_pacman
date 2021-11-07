// ignore_for_file: constant_identifier_names, curly_braces_in_flow_control_structures, non_constant_identifier_names



import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:mdi/mdi.dart';
import 'package:wsa_pacman/apk_installer.dart';
import 'package:wsa_pacman/widget/move_window_nomax.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
//import 'package:flutter/material.dart' hide showDialog;
import 'package:shared_value/shared_value.dart';
import 'global_state.dart';

import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:url_strategy/url_strategy.dart';

import 'screens/forms.dart';
import 'screens/others.dart';
import 'screens/settings.dart';
import 'proto/options.pb.dart';

import 'dart:io';
import 'dart:developer';
import 'dart:async';

import 'package:synchronized/synchronized.dart';

import 'theme.dart';

const String appTitle = 'WSA Package Manager';

late bool darkMode;

class WSAStatusAlert {
  WSAStatusAlert(this.severity, this.title, this.desc);

  final InfoBarSeverity severity;
  final String title;
  final String desc;

  late final InfoBar widget = InfoBar(
    title: Text(title),
    content: Text(desc),
    isLong: true,
    severity: severity,
    action: () {
      // Do nothing for now
    }(),
  );
}

enum ConnectionStatus {
  UNKNOWN, ARRESTED, OFFLINE, DISCONNECTED, CONNECTED
}
extension on ConnectionStatus {
  static final Map<ConnectionStatus, WSAStatusAlert> _statusAlers = {
    ConnectionStatus.UNKNOWN: WSAStatusAlert(InfoBarSeverity.info, "Connecting", 
      "Waiting for a WSA connection to be enstablished..."),
    ConnectionStatus.ARRESTED: WSAStatusAlert(InfoBarSeverity.warning, "Arrested", 
      "Could not enstablish a connection with WSA: either developer mode and USB debugging are disabled, WSA is powered-off or a wrong port is specified"),
    ConnectionStatus.OFFLINE: WSAStatusAlert(InfoBarSeverity.warning, "Arrested", 
      "Could not enstablish a connection with WSA: either developer mode and USB debugging are disabled, WSA is powered-off or a wrong port is specified"),
    ConnectionStatus.DISCONNECTED: WSAStatusAlert(InfoBarSeverity.error, "Disconnected", 
      "A WSA connection could not be enstablished for unknown reasons"),
    ConnectionStatus.CONNECTED: WSAStatusAlert(InfoBarSeverity.success, "Connected", 
      "Successifully connected to WSA, all systems go"),
  };

  WSAStatusAlert get statusAlert => _statusAlers[this] ?? WSAStatusAlert(InfoBarSeverity.error, "Unmapped status",
    "Encountered WSA connection status $this, the status is missing an alert message");
}

extension __EnumExtension on Enum {
  String name() {
    return toString().split('.').last.toLowerCase();
  }
}

class Env {
  static final String SYSTEM_ROOT = Platform.environment["SystemRoot"] ?? "";
  static final String USER_PROFILE = Platform.environment["UserProfile"] ?? "";
  static final String EXEC_DIR = Platform.resolvedExecutable.replaceFirst(RegExp(r'[/\\][^/\\]*$'), r'\');
  static final String TOOLS_DIR = "${EXEC_DIR}embedded-adb\\";
}

class WSAPeriodicConnector {
  static const PERIODIC_CHECK_TIMER = Duration(seconds:5);
  static ConnectionStatus status = ConnectionStatus.UNKNOWN;
  static WSAStatusAlert alertStatus = ConnectionStatus.UNKNOWN.statusAlert;
  static bool _statusInitialized = false;

  static void _checkConnectionStatus() async {
    if (_statusInitialized) {
      Process.run('${Env.SYSTEM_ROOT}\\System32\\tasklist.exe', []).then((result){
        if (!result.stdout.toString().contains(RegExp(r'(^|\n)adb.exe\s+'))) {
          status = ConnectionStatus.UNKNOWN;
          GState.connectionStatus.update((p0) => status.statusAlert);
        }
      });
    }

    var prevStatus = status;
    var process = await Process.run('${Env.TOOLS_DIR}\\adb.exe', ['devices']);
    var output = process.stdout.toString();
    if (output.contains(RegExp('(^|\\n)(localhost|127.0.0.1):${GState.androidPort.$}\\s+'))) {
      if (output.contains(RegExp('(^|\\n)(localhost|127.0.0.1):${GState.androidPort.$}\\s+offline(\$|\\n|\\s)')))
        status = ConnectionStatus.OFFLINE;
      else if (output.contains(RegExp('(^|\\n)(localhost|127.0.0.1):${GState.androidPort.$}\\s+host(\$|\\n|\\s)'))) {
        await Process.run('${Env.TOOLS_DIR}\\adb.exe', ['disconnect', '127.0.0.1:${GState.androidPort.$}']);
        _tryConnect();
      }
      else {
        status = ConnectionStatus.CONNECTED;
        if (output.contains(RegExp('(^|\\n)127.0.0.1:${GState.androidPort.$}\\s+'))) {
          if (GState.ipAddress.$ != "127.0.0.1") GState.ipAddress.update((old) => "127.0.0.1");
        }
        else if (GState.ipAddress.$ != "localhost") GState.ipAddress.update((old) => "localhost");
      }
    }
    //else status = ConnectionStatus.DISCONNECTED;
    /*if (status != prevStatus) {
      (alert.title as Text).data = ""
    }*/
    else await _tryConnect();
    if (status != prevStatus) GState.connectionStatus.update((p0) => status.statusAlert);
    _statusInitialized = false;
    log("Connection status: ${status.name()}");
  }

  static Future<void> _tryConnect() async {
    ProcessResult? process = await Process.run('${Env.TOOLS_DIR}\\adb.exe', ['connect', '127.0.0.1:${GState.androidPort.$}'])
      .timeout(const Duration(milliseconds:200), onTimeout: () => Future.value(ProcessResult(-1, -1, null, null)));
    if (process.stdout?.toString().contains(RegExp(r'(^|\n)(cannot|failed to) connect\s.*')) ?? true) 
      status = ConnectionStatus.ARRESTED;
    else status = ConnectionStatus.CONNECTED;
  }
}

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

late final List<String> args;

void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  //TODO args = arguments;
  //args = [r'C:\Users\Alex\Downloads\youtube.apk'];
  //args = [];
  const app = MyApp();
  final wrappedApp = SharedValue.wrapApp(app);
  //arguments = [r'C:\Users\Alex\Downloads\com.google.android.googlequicksearchbox_12.41.16.23.x86_64-301172250_minAPI23(x86_64)(nodpi)_apkmirror.com.apk'];
  if (arguments.isNotEmpty) ApkReader.init(arguments.first);
  args = arguments;

  setPathUrlStrategy();

  // The platforms the plugin support (01/04/2021 - DD/MM/YYYY):
  //   - Windows
  //   - Web
  //   - Android
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.android ||
      kIsWeb) {
    darkMode = await SystemTheme.darkMode;
    await SystemTheme.accentInstance.load();
  } else {
    darkMode = true;
  }
  if (!kIsWeb &&
      [TargetPlatform.windows, TargetPlatform.linux]
          .contains(defaultTargetPlatform)) {
    await flutter_acrylic.Acrylic.initialize();
  }

  WSAPeriodicConnector._checkConnectionStatus();
  Timer.periodic(WSAPeriodicConnector.PERIODIC_CHECK_TIMER, (Timer t) => WSAPeriodicConnector._checkConnectionStatus());
  runApp(wrappedApp);

  if (isDesktop) {
    doWhenWindowReady(() {
      final win = appWindow;
      if (args.isEmpty) {
        win.minSize = const Size(640, 500);
        win.size = const Size(740, 540);
        win.title = appTitle;
      }
      else {
        win.minSize = win.maxSize = win.size = const Size(500, 335);
      }
      win.alignment = Alignment.center;
      win.show();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = GState.theme.of(context).mode;
    return ChangeNotifierProvider(
      create: (_) => AppTheme(),
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return FluentApp(
          title: appTitle,
          themeMode: theme,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {'/': (_) => args.isEmpty ? const MyHomePage() : const ApkInstaller()},
          theme: ThemeData(
            accentColor: appTheme.color,
            brightness: theme == ThemeMode.system
                ? darkMode
                    ? Brightness.dark
                    : Brightness.light
                : theme == ThemeMode.dark
                    ? Brightness.dark
                    : Brightness.light,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool value = false;

  int index = 0;

  final colorsController = ScrollController();
  final settingsController = ScrollController();

  @override
  void dispose() {
    colorsController.dispose();
    settingsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    flutter_acrylic.Acrylic.setEffect(
     effect: flutter_acrylic.AcrylicEffect.acrylic,
     gradientColor: Colors.black.withOpacity(0.2)
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return NavigationView(
      appBar: NavigationAppBar(
        // height: !kIsWeb ? appWindow.titleBarHeight : 31.0,
        /*title: () {
          if (kIsWeb) return const Text(appTitle);
          return MoveWindow(
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(appTitle),
            ),
          );
        }(),*/
        actions: kIsWeb
            ? null
            : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Expanded(flex: 1,child: MoveWindow(child: Padding(padding: const EdgeInsets.only(top: 9, left: 13), child: Text(appTitle, style: FluentTheme.of(context).typography.caption)))), const WindowButtons()],
                )
            /*MoveWindow(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [Spacer(), WindowButtons()],
                ),
              ),*/
      ),
      pane: NavigationPane(
        selected: index,
        onChanged: (i) => setState(() => index = i),
        header: Container(
          height: kOneLineTileHeight,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: material.Row(children: [AnimatedContainer(
            width: 28,
            height: 28,
            duration: const Duration(milliseconds: 750),
            curve: Curves.fastOutSlowIn,
            decoration: const BoxDecoration (
              image: DecorationImage(image:  AssetImage("assets/images/logo.png"))
            ),
          ), SizedBox(width: 10), Text("WSA PacMan", style: FluentTheme.of(context).typography.bodyLarge)]),
        ),
        displayMode: appTheme.displayMode,
        indicatorBuilder: ({
          required BuildContext context,
          required NavigationPane pane,
          Axis? axis,
          required Widget child,
        }) {
          if (pane.selected == null) return child;
          axis ??= Axis.horizontal;
          assert(debugCheckHasFluentTheme(context));
          final theme = NavigationPaneTheme.of(context);
          switch (appTheme.indicator) {
            case NavigationIndicators.end:
              return EndNavigationIndicator(
                index: pane.selected!,
                offsets: () =>
                    pane.effectiveItems.getPaneItemsOffsets(pane.paneKey),
                sizes: pane.effectiveItems.getPaneItemsSizes,
                child: child,
                color: theme.highlightColor,
                curve: theme.animationCurve ?? Curves.linear,
                axis: axis,
              );
            case NavigationIndicators.sticky:
              return NavigationPane.defaultNavigationIndicator(
                context: context,
                axis: axis,
                pane: pane,
                child: child,
              );
            default:
              return NavigationIndicator(
                index: pane.selected!,
                offsets: () =>
                    pane.effectiveItems.getPaneItemsOffsets(pane.paneKey),
                sizes: pane.effectiveItems.getPaneItemsSizes,
                child: child,
                color: theme.highlightColor,
                curve: theme.animationCurve ?? Curves.linear,
                axis: axis,
              );
          }
        },
        items: [
          // It doesn't look good when resizing from compact to open
          // PaneItemHeader(header: Text('User Interaction')),
          PaneItem(
            icon: const Icon(Mdi.androidDebugBridge),
            title: const Text('WSA'),
          ),
          PaneItemSeparator(),
          /*PaneItem(
            icon: Icon(
              appTheme.displayMode == PaneDisplayMode.top
                  ? FluentIcons.more
                  : FluentIcons.more_vertical,
            ),
            title: const Text('Others'),
          ),*/
        ],
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: const Text('Settings')),
        ],
      ),
      content: NavigationBody(index: index, children: [
        const Forms(),
        //const Others(),
        Settings(controller: settingsController),
      ]),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));
    final ThemeData theme = FluentTheme.of(context);
    final buttonColors = WindowButtonColors(
      iconNormal: theme.inactiveColor,
      iconMouseDown: theme.inactiveColor,
      iconMouseOver: theme.inactiveColor,
      //Fixed button colors
      mouseOver: ButtonThemeData.buttonColor(
          theme.brightness, {ButtonStates.hovering}).lerpWith(Colors.black, 0.12),
      mouseDown: ButtonThemeData.buttonColor(
          theme.brightness, {ButtonStates.pressing}).lerpWith(theme.shadowColor, 0.12).withAlpha(150),
    );
    final closeButtonColors = WindowButtonColors(
      mouseOver: Colors.red,
      mouseDown: Colors.red.dark,
      iconNormal: theme.inactiveColor,
      iconMouseOver: Colors.red.basedOnLuminance(),
      iconMouseDown: Colors.red.dark.basedOnLuminance(),
    );
    return Row(children: [
      Tooltip(
        message: FluentLocalizations.of(context).minimizeWindowTooltip,
        child: MinimizeWindowButton(colors: buttonColors),
      ),
      Tooltip(
        message: FluentLocalizations.of(context).restoreWindowTooltip,
        child: WindowButton(
          colors: buttonColors,
          iconBuilder: (context) {
            if (appWindow.isMaximized) {
              return RestoreIcon(color: context.iconColor);
            }
            return MaximizeIcon(color: context.iconColor);
          },
          onPressed: appWindow.maximizeOrRestore,
        ),
      ),
      Tooltip(
        message: FluentLocalizations.of(context).closeWindowTooltip,
        child: CloseWindowButton(colors: closeButtonColors),
      ),
    ]);
  }
}
