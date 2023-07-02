// ignore_for_file: avoid_print

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:mdi/mdi.dart';
import 'package:wsa_pacman/utils/wsa_utils.dart';
import 'package:wsa_pacman/widget/fluent_card.dart';
import 'package:wsa_pacman/widget/fluent_info_bar.dart';
import 'package:wsa_pacman/widget/smooth_list_view.dart';
import '../main.dart';
import '../global_state.dart';

class ScreenWSA extends StatefulWidget {
  const ScreenWSA({Key? key}) : super(key: key);

  @override
  _ScreenWSAState createState() => _ScreenWSAState();
}

class EmptyElement extends Element {
  EmptyElement(Empty widget) : super(widget);
  @override
  void performRebuild() {}
  @override
  bool get debugDoingBuild => false;
  @override
  Empty get widget => super.widget as Empty;
}
class Empty extends Widget {
  const Empty();

  @override
  Element createElement() => EmptyElement(this);
}
Expanded EMPTY = Expanded(child: Column());

class _ScreenWSAState extends State<ScreenWSA> {
  //_FormsState(this.gsmap);

  //final GSMap<Object, dynamic> gsmap;
  final autoSuggestBox = TextEditingController();

  final _clearController = TextEditingController();
  bool _showPassword = false;
  final values = ['Blue', 'Green', 'Yellow', 'Red'];
  String? comboBoxValue;

  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    var connectionStatus = GState.connectionStatus.of(context);
    final lang = AppLocalizations.of(context)!;

    const smallSpacer = SizedBox(height: 5.0);

    return ScaffoldPage(
      header: PageHeader(title: Text(lang.screen_wsa)),
      content: SmoothListView(
        padding: EdgeInsets.only(
          bottom: kPageDefaultVerticalPadding,
          left: PageHeader.horizontalPadding(context),
          right: PageHeader.horizontalPadding(context),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: FluentInfoBar(
              title: Text(connectionStatus.title(lang)),
              content: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                Text(connectionStatus.desc(lang)),
                if (connectionStatus.type == ConnectionStatus.ARRESTED) ...[
                  const SizedBox(width: 15.0),
                  Button(child: Text(lang.btn_boot), onPressed: () => WSAUtils.launch())
                ]
                else if (connectionStatus.type == ConnectionStatus.UNAUTHORIZED) ...[
                  Button(child: Text(lang.btn_auth), onPressed: () => WSAPeriodicConnector.reconnect()),
                  const SizedBox(width: 15.0),
                  Button(child: Text(lang.btn_dev_settings), onPressed: () => WSAUtils.launchDeveloperSettings())
                ],
              ]),
              isLong: true,
              severity: connectionStatus.severity,
              action: () {
                // Do nothing for now
              }(),
            )
          ),
          const SizedBox(height: 20),
          Text(lang.wsa_manage, style: FluentTheme.of(context).typography.bodyLarge),
          const SizedBox(height: 20),
          FluentCard(
            leading: const Icon(Mdi.android , size: 23),
            content: Text(lang.wsa_manage_app),
            isButton: true,
            onPressed: connectionStatus.isDisconnected ? 
                null : () => ADBUtils.shellToAddress(GState.ipAddress.of(context), GState.androidPort.of(context), 
                  r'am start -f 0x10008000 -n com.android.settings/.Settings\$ManageApplicationsActivity'),
          ),
          smallSpacer,
          FluentCard(
            leading: const Icon(Mdi.cogs, size: 23),
            content: Text(lang.wsa_manage_settings),
            isButton: true,
            onPressed: connectionStatus.isDisconnected ?
                connectionStatus.isPoweredOn ? () => WSAUtils.launchSettings() : null : 
                () => ADBUtils.shellToAddress(GState.ipAddress.of(context), GState.androidPort.of(context), 
                  r'am start com.android.settings/.Settings'),
          )

        ],
      ),
    );
  }
}
