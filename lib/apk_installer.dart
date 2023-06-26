// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:io';

import 'package:wsa_pacman/android/android_utils.dart';
import 'package:wsa_pacman/android/permissions.dart';
import 'package:wsa_pacman/android/reader_apk.dart';
import 'package:wsa_pacman/global_state.dart';
import 'package:wsa_pacman/main.dart';
import 'package:wsa_pacman/utils/wsa_utils.dart';
import 'package:wsa_pacman/widget/smooth_list_view.dart';
import 'package:wsa_pacman/widget/themed_pane_item.dart';
import 'package:wsa_pacman/windows/win_io.dart';
import 'package:wsa_pacman/widget/adaptive_icon.dart';
import 'package:wsa_pacman/widget/flexible_info_bar.dart';
import 'package:wsa_pacman/widget/move_window_nomax.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:wsa_pacman/windows/win_path.dart';

import 'dart:developer';


class ApkInstaller extends StatefulWidget {
  const ApkInstaller({Key? key}) : super(key: key);

  static void createLaunchIcon(String package, String appName) {
    WinIO.createShortcut(
      "%LOCALAPPDATA%\\Microsoft\\WindowsApps\\${Env.WSA_INFO.familyName}\\WsaClient.exe", 
      "${WinPath.desktop}\\$appName", 
      args: "/launch wsa://$package",
      icon: '%LOCALAPPDATA%\\Packages\\${Env.WSA_INFO.familyName}\\LocalState\\$package.ico');
  }

  static void installApk(String apkFile, String ipAddress, int port, AppLocalizations lang, int timeout, [bool downgrade = false]) async {
    log("INSTALLING \"$apkFile\" on on $ipAddress:$port...");
    var installation = ADBUtils.installToAddress(ipAddress, port, apkFile, downgrade: downgrade);
    if (timeout > 0) installation = installation.processTimeout(Duration(seconds: timeout));
    installation = installation.defaultError();
    GState.apkInstallState.update((_) => InstallState.INSTALLING);
    var result = await installation;
    log("EXIT CODE: ${result.exitCode}");
    String error = result.stderr.toString();
    log("OUTPUT: ${result.stdout}");
    log("ERROR: ${error}");
    if (result.exitCode == 0) GState.apkInstallState.update((_) => InstallState.SUCCESS);
    else if (result.isTimeout) {
      GState.apkInstallState.update((_) => InstallState.TIMEOUT);
      GState.errorCode.update((_) => "TIMEOUT");
      GState.errorDesc.update((_) => lang.installer_error_timeout);
    } else {
      GState.apkInstallState.update((_) => InstallState.ERROR);
      //TODO add cause
      RegExpMatch? errorMatch = RegExp(r'(^|\n)\s*adb:\s+failed\s+to\s+install\s+.*:\s+Failure\s+\[([^:]*):\s*([^\s].*[^\s])\s*\]').firstMatch(error);
      String errorCode = errorMatch?.group(2) ?? "";
      GState.errorCode.update((_) => errorCode.isNotEmpty ? errorCode : "UNKNOWN_ERROR");
      String errorDesc = errorMatch?.group(3) ?? "";
      GState.errorDesc.update((_) => errorDesc.isNotEmpty ? errorDesc : lang.installer_error_nomsg);
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
    final lang = AppLocalizations.of(context)!;
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    Widget icon;
    String appTitle = GState.apkTitle.of(context);
    Widget? aForeground = GState.apkForegroundIcon.of(context);
    bool adaptiveNoScale = GState.apkAdaptiveNoScale.of(context);
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
      if (!WSAUtils.launch()) setState(() {startingWSA = false;});
    }

    if (installType == InstallType.DOWNGRADE && warningButtonTheme == null) warningButtonTheme = ToggleButtonThemeData.standard(theme.copyWith(accentColor: Colors.orange));

    String package = GState.package.of(context);
    String version = GState.version.of(context);
    String activity = GState.activity.of(context);
    int installTimeout  = GState.installTimeout.of(context);
    bool isLaunchable = package.isNotEmpty && activity.isNotEmpty;

    String oldVersion = GState.oldVersion.of(context);

    String ipAddress = GState.ipAddress.of(context);
    int port = GState.androidPort.of(context);

    if (aForeground != null) icon = AdaptiveIcon(noScale: adaptiveNoScale, backColor: GState.apkBackgroundColor.of(context), background: GState.apkBackgroundIcon.of(context), foreground: aForeground, radius: GState.iconShape.of(context).radius);
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
              Text(lang.installer_message),
              const SizedBox(height: 10),
              Text((oldVersion.isNotEmpty ? lang.installer_info_version_change(oldVersion, version) : lang.installer_info_version(version)).replaceAll(' ', '\u00A0'), style: TextStyle(color: theme.disabledColor), overflow: TextOverflow.ellipsis, maxLines: 1),
              Text(lang.installer_info_package(package).replaceAll(' ', '\u00A0'), style: TextStyle(color: theme.disabledColor), overflow: TextOverflow.ellipsis, maxLines: 1),
              /*SmoothListView(
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
            child: SmoothListView(
            //padding: const EdgeInsets.all(5),
            children: [
              for (var permission in GState.permissions.of(context)) Container(
                padding: EdgeInsets.only(right: isLtr ? 10 : 0, left: isLtr ? 0 : 10),
                child: ThemablePaneItem(
                  title: Text(permission.description(lang)),
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
                child: Text(lang.installer_btn_cancel),
                onPressed: false ? null : (){appWindow.close();},
              )),
              const SizedBox(width: 15),
              noMoveWindow(ToggleButton(
                child: Text(startingWSA ? lang.installer_btn_starting : installType?.buttonText(lang) ?? lang.installer_btn_loading),
                checked: true,
                style: installType == InstallType.DOWNGRADE ? warningButtonTheme : null,
                onChanged: !canInstall ? null : (_){
                  if (Constants.packageType.directInstall) ApkInstaller.installApk(Constants.packageFile, ipAddress, port, lang, installTimeout, installType == InstallType.DOWNGRADE);
                  else GState.installCallback.$?.call(ipAddress, port, lang, installTimeout, installType == InstallType.DOWNGRADE);
                },
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
          Text(lang.installer_installing(appTitle)),
          const Spacer(),
          Row(children: const [Expanded(child: ProgressBar(strokeWidth: 6))]),
        ];
        case InstallState.SUCCESS: return [
          titleWidget,
          const SizedBox(height: 10),
          Text(lang.installer_installed(appTitle)),
          if (installType == InstallType.INSTALL) const SizedBox(height: 10),
          if (installType == InstallType.INSTALL) Checkbox(
            checked: createShortcut,
            content: Text(lang.installer_btn_checkbox_shortcut),
            onChanged: (value) => setState(() => createShortcut = value!),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              noMoveWindow(Button(
                child: Text(lang.installer_btn_dismiss),
                onPressed: (){if (createShortcut) ApkInstaller.createLaunchIcon(package, appTitle); appWindow.close();},
              )),
              (){return isLaunchable ? const SizedBox(width: 15) : const SizedBox.shrink();}(),
              (){return isLaunchable ? noMoveWindow(ToggleButton(
                child: Text(lang.installer_btn_open),
                checked: true,
                onChanged: (_){if (createShortcut) ApkInstaller.createLaunchIcon(package, appTitle); WSAUtils.launchApp(package); appWindow.close();},
              )) : const SizedBox.shrink();}()
            ]
          )
        ];
        case InstallState.ERROR: case InstallState.TIMEOUT: return [
          titleWidget,
          const SizedBox(height: 10),
          Text(lang.installer_fail(appTitle)),
          const SizedBox(height: 10),
          FlexibleInfoBar(
            title: noMoveWindow(material.SelectableText(GState.errorCode.of(context))),
            content: noMoveWindow(material.SelectableText(GState.errorDesc.of(context))),
            severity: installState == InstallState.ERROR ? InfoBarSeverity.error : InfoBarSeverity.warning
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              noMoveWindow(Button(
                child: Text(lang.installer_btn_dismiss),
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