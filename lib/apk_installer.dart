// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:io';

import 'package:wsa_pacman/android/android_utils.dart';
import 'package:wsa_pacman/android/permissions.dart';
import 'package:wsa_pacman/android/reader_apk.dart';
import 'package:wsa_pacman/global_state.dart';
import 'package:wsa_pacman/main.dart';
import 'package:wsa_pacman/widget/themed_pane_item.dart';
import 'package:wsa_pacman/windows/win_io.dart';
import 'package:wsa_pacman/widget/adaptive_icon.dart';
import 'package:wsa_pacman/widget/flexible_info_bar.dart';
import 'package:wsa_pacman/widget/move_window_nomax.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;

import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:wsa_pacman/windows/win_path.dart';

import 'dart:developer';
import 'theme.dart';


class ApkInstaller extends StatefulWidget {
  const ApkInstaller({Key? key}) : super(key: key);

  static void createLaunchIcon(String package, String appName) {
    WinIO.createShortcut(
      "%LOCALAPPDATA%\\Microsoft\\WindowsApps\\${Env.WSA_INFO.familyName}\\WsaClient.exe", 
      "${WinPath.desktop}\\$appName", 
      args: "/launch wsa://$package",
      icon: '%LOCALAPPDATA%\\Packages\\${Env.WSA_INFO.familyName}\\LocalState\\$package.ico');
  }

  static void installApk(String apkFile, String ipAddress, int port, [bool downgrade = false]) async {
    log("INSTALLING \"$apkFile\" on on $ipAddress:$port...");
    var installation = Process.run('${Env.TOOLS_DIR}\\adb.exe', ['-s', '$ipAddress:$port', 'install', if (downgrade) '-r', if (downgrade) '-d', apkFile])
      .timeout(const Duration(seconds: 30)).onError((error, stackTrace) => ProcessResult(-1, -1, null, null));
    GState.apkInstallState.update((_) => InstallState.INSTALLING);
    var result = await installation;
    log("EXIT CODE: ${result.exitCode}");
    String error = result.stderr.toString();
    log("OUTPUT: ${result.stdout}");
    log("ERROR: ${error}");
    if (result.exitCode == 0) GState.apkInstallState.update((_) => InstallState.SUCCESS);
    else {
      GState.apkInstallState.update((_) => InstallState.ERROR);
      //TODO add cause
      RegExpMatch? errorMatch = RegExp(r'(^|\n)\s*adb:\s+failed\s+to\s+install\s+.*:\s+Failure\s+\[([^:]*):\s*([^\s].*[^\s])\s*\]').firstMatch(error);
      String errorCode = errorMatch?.group(2) ?? "";
      GState.errorCode.update((_) => errorCode.isNotEmpty ? errorCode : "UNKNOWN_ERROR");
      String errorDesc = errorMatch?.group(3) ?? "";
      GState.errorDesc.update((_) => errorDesc.isNotEmpty ? errorDesc : "The installation has failed, but no error was thrown");
    }
  }

  @override
  _ApkInstallerState createState() => _ApkInstallerState();
}

class _ApkInstallerState extends State<ApkInstaller> {
  int index = 0;
  ToggleButtonThemeData? warningButtonTheme;
  bool createShortcut = false;
  bool startingWSA = false;
  
  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    Widget icon;
    String appTitle = GState.apkTitle.of(context);
    Widget? aForeground = GState.apkForegroundIcon.of(context);
    Widget? lIcon = GState.apkIcon.of(context);
    WSAStatusAlert connectionStatus = GState.connectionStatus.of(context);
    bool isConnected = connectionStatus.isConnected;
    InstallType? installType = GState.apkInstallType.of(context);
    bool canInstall = isConnected && installType != null && installType != InstallType.UNKNOWN;
    InstallState installState = GState.apkInstallState.of(context);
    final mica = GState.mica.of(context);
    final theme = FluentTheme.of(context);
    if (startingWSA && isConnected) startingWSA = false;
    final autostartWSA = !startingWSA && !isConnected && GState.autostartWSA.of(context);

    if (autostartWSA) {
      startingWSA = true;
      Process.run(Env.WSA_EXECUTABLE, []).onError((_, __){
        setState(() {startingWSA = false;});
        return ProcessResult(-1, -1, null, null);
      });
    }

    if (installType == InstallType.DOWNGRADE && warningButtonTheme == null) warningButtonTheme = ToggleButtonThemeData.standard(theme.copyWith(accentColor: Colors.orange));

    String package = GState.package.of(context);
    String version = GState.version.of(context);
    String activity = GState.activity.of(context);
    bool isLaunchable = package.isNotEmpty && activity.isNotEmpty;

    String oldVersion = GState.oldVersion.of(context);

    String ipAddress = GState.ipAddress.of(context);
    int port = GState.androidPort.of(context);

    if (aForeground != null) icon = AdaptiveIcon(backColor: GState.apkBackgroundColor.of(context), background: GState.apkBackgroundIcon.of(context), foreground: aForeground, radius: GState.iconShape.of(context).radius);
    else if (lIcon != null) icon = FittedBox(child: lIcon);
    else icon = const ProgressRing();

    Widget titleWidget = Row (
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(child: SizedBox(width: 30.00, height: 30.00, child: icon)), const Flexible(child: SizedBox(width: 20)), Text(appTitle, style: theme.typography.bodyLarge), 
                //Spacer(), WindowButtons()
      ]
    );

    return Mica(child: moveWindow(Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ((){switch(installState) {case InstallState.PROMPT: return [
          titleWidget,
          Column (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Do you want to install this application?"),
              const SizedBox(height: 10),
              Text("Version:\u00A0${oldVersion.isNotEmpty ? '$oldVersion\u00A0=>\u00A0' : ''}${version.replaceAll(' ', '\u00A0')}", style: TextStyle(color: theme.disabledColor), overflow: TextOverflow.ellipsis, maxLines: 1),
              Text("Package:\u00A0$package", style: TextStyle(color: theme.disabledColor), overflow: TextOverflow.ellipsis, maxLines: 1),
              /*ListView(
                padding: EdgeInsets.only(
                  bottom: kPageDefaultVerticalPadding,
                  left: PageHeader.horizontalPadding(context),
                  right: PageHeader.horizontalPadding(context),
                ),
                //controller: controller,
                children: [const Text("Hello darkness my old friend", )]
              )*/
            ]
          ),
          const SizedBox(height: 10),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Container(
            //decoration: ChipTheme.of(context).decoration?.resolve({ButtonStates.focused})?.lerpTo(SnackbarTheme.of(context).decoration, 0.07),
            color: mica.disabled || theme.brightness.isDark ? theme.inactiveBackgroundColor.lerpWith(theme.scaffoldBackgroundColor, 0.65)
              : theme.scaffoldBackgroundColor.lerpWith(theme.inactiveBackgroundColor, 0.038),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            //color: Colors.red, 
            child: ListView(
            //padding: const EdgeInsets.all(5),
            children: [
              for (var permission in GState.permissions.of(context)) Container(
                padding: EdgeInsets.only(right: 10),
                child: ThemablePaneItem(
                  title: Text(permission.description),
                  icon: permission.icon,
                  translucent: mica.enabled
                ).build(
                  context,
                  false,
                  (){1;},
                  displayMode: PaneDisplayMode.open,
                )
              )
            ],
          )))),
          const SizedBox(height: 20),
          //const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              noMoveWindow(Button(
                child: const Text('Cancel'),
                onPressed: false ? null : (){appWindow.close();},
              )),
              const SizedBox(width: 15),
              noMoveWindow(ToggleButton(
                child: Text(startingWSA ? "Starting..." : installType?.buttonText ?? "Loading..."),
                checked: true,
                style: installType == InstallType.DOWNGRADE ? warningButtonTheme : null,
                onChanged: !canInstall ? null : (_){ApkInstaller.installApk(ApkReader.APK_FILE, ipAddress, port, installType == InstallType.DOWNGRADE);},
              )),
              /*const SizedBox(width: 15),noMoveWindow(ToggleButton(
                child: const Text('TEST-ICON'),
                checked: true,
                onChanged: (_){ApkReader.init();},
              ))*/
            ]
          )
        ];
        case InstallState.INSTALLING: return [
          titleWidget,
          const SizedBox(height: 10),
          Text("Installing application $appTitle..."),
          const Spacer(),
          Row(children: const [Expanded(child: ProgressBar(strokeWidth: 6))]),
        ];
        case InstallState.SUCCESS: return [
          titleWidget,
          const SizedBox(height: 10),
          Text("The application $appTitle was successifully installed"),
          if (installType == InstallType.INSTALL) const SizedBox(height: 10),
          if (installType == InstallType.INSTALL) Checkbox(
            checked: createShortcut,
            content: const Text("Create desktop shortcut"),
            onChanged: (value) => setState(() => createShortcut = value!),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              noMoveWindow(Button(
                child: const Text('Dismiss'),
                onPressed: (){if (createShortcut) ApkInstaller.createLaunchIcon(package, appTitle); appWindow.close();},
              )),
              (){return isLaunchable ? const SizedBox(width: 15) : SizedBox.shrink();}(),
              (){return isLaunchable ? noMoveWindow(ToggleButton(
                child: const Text('Open app'),
                checked: true,
                onChanged: (_){if (createShortcut) ApkInstaller.createLaunchIcon(package, appTitle); Process.run('${Env.TOOLS_DIR}\\adb.exe', ['-s', '$ipAddress:$port', 'shell', 'am start -n ${GState.package.of(context)}/${GState.activity.of(context)}']); appWindow.close();},
              )) : const SizedBox.shrink();}()
            ]
          )
        ];
        case InstallState.ERROR: return [
          titleWidget,
          const SizedBox(height: 10),
          Text("The application $appTitle was not installed"),
          const SizedBox(height: 10),
          FlexibleInfoBar(
            title: noMoveWindow(material.SelectableText(GState.errorCode.of(context))),
            content: noMoveWindow(material.SelectableText(GState.errorDesc.of(context))),
            severity: InfoBarSeverity.error
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              noMoveWindow(Button(
                child: const Text('Dismiss'),
                onPressed: (){appWindow.close();},
              ))
            ]
          )
        ];
        default: return [] as List<Widget> ;
        }})(),
      ),
    )));
  }
}