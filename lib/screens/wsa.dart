// ignore_for_file: avoid_print

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:mdi/mdi.dart';
import 'package:wsa_pacman/widget/fluent_card.dart';
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

    const smallSpacer = SizedBox(height: 5.0);

    return ScaffoldPage(
      header: const PageHeader(title: Text('WSA Package Manager')),
      content: ListView(
        padding: EdgeInsets.only(
          bottom: kPageDefaultVerticalPadding,
          left: PageHeader.horizontalPadding(context),
          right: PageHeader.horizontalPadding(context),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InfoBar(
              title: Text(connectionStatus.title),
              content: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                Text(connectionStatus.desc),
                const SizedBox(width: 15.0),
                if (connectionStatus.type == ConnectionStatus.ARRESTED) Button(child: const Text("Turn on"), onPressed: () => Process.run(Env.WSA_EXECUTABLE, [], workingDirectory: Env.WSA_SYSTEM_PATH))
              ]),
              isLong: true,
              severity: connectionStatus.severity,
              action: () {
                // Do nothing for now
              }(),
            )
          ),
          const SizedBox(height: 20),
          Text('Android Management', style: FluentTheme.of(context).typography.bodyLarge),
          const SizedBox(height: 20),
          FluentCard(
            leading: const Icon(Mdi.android , size: 23),
            content: const Text('Manage Applications'),
            isButton: true,
            onPressed: connectionStatus.isDisconnected ? 
                null : () => Process.run('${Env.TOOLS_DIR}\\adb.exe', ['-s', '${GState.ipAddress.of(context)}:${GState.androidPort.of(context)}', 
                  'shell', r'am start com.android.settings/.Settings\$ManageApplicationsActivity']),
          ),
          smallSpacer,
          FluentCard(
            leading: const Icon(Mdi.cogs, size: 23),
            content: const Text('Manage Settings'),
            isButton: true,
            onPressed: connectionStatus.isDisconnected ?
                null : () => Process.run('${Env.TOOLS_DIR}\\adb.exe', ['-s', '${GState.ipAddress.of(context)}:${GState.androidPort.of(context)}', 
                  'shell', r'am start com.android.settings/.Settings']),
          )

        ],
      ),
    );
  }
}
