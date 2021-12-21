// ignore_for_file: avoid_print

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
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
                if (connectionStatus.type == ConnectionStatus.ARRESTED) Button(child: const Text("Turn on"), onPressed: () => Process.run(Env.WSA_EXECUTABLE, []))
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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
            Expanded(
              child: Button(child: const Text('Manage Applications'), onPressed: connectionStatus.isDisconnected ? 
                null : () => Process.run('${Env.TOOLS_DIR}\\adb.exe', ['-s', '${GState.ipAddress.of(context)}:${GState.androidPort.of(context)}', 
                  'shell', r'am start com.android.settings/.Settings\$ManageApplicationsActivity'])
              ),
            )
            ,EMPTY, EMPTY])
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
            Expanded(
              child: Button(child: const Text('Manage Settings'), onPressed: connectionStatus.isDisconnected ?
                null : () => Process.run('${Env.TOOLS_DIR}\\adb.exe', ['-s', '${GState.ipAddress.of(context)}:${GState.androidPort.of(context)}', 
                  'shell', r'am start com.android.settings/.Settings']) ),
            )
            ,EMPTY, EMPTY])
          ),
          const SizedBox(height: 20),


          /*
          const SizedBox(height: 20),
          TextBox(
            maxLines: null,
            controller: _clearController,
            suffixMode: OverlayVisibilityMode.always,
            minHeight: 100,
            suffix: IconButton(
              icon: const Icon(FluentIcons.close),
              onPressed: () {
                _clearController.clear();
              },
            ),
            placeholder: 'Text box with clear button',
          ),
          const SizedBox(height: 20),
          TextBox(
            header: 'Password',
            placeholder: 'Type your placeholder here',
            obscureText: !_showPassword,
            toolbarOptions: const ToolbarOptions(
                    copy: false,
                    cut: false,
                    selectAll: true,
                    paste: true,
                  ),
            maxLines: 1,
            suffixMode: OverlayVisibilityMode.always,
            suffix: IconButton(
              icon: Icon(
                !_showPassword ? FluentIcons.lock : FluentIcons.unlock,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
            outsideSuffix: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Button(
                child: const Text('Done'),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: 20),
          Mica(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(runSpacing: 8, children: [
                SizedBox(
                  width: 200,
                  child: InfoLabel(
                    label: 'Colors',
                    child: Combobox<String>(
                      placeholder: const Text('Choose a color'),
                      isExpanded: true,
                      items: values
                          .map((e) => ComboboxItem<String>(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      value: comboBoxValue,
                      onChanged: (value) {
                        print(value);
                        if (value != null) {
                          setState(() => comboBoxValue = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 295,
                  child: DatePicker(
                    // popupHeight: kOneLineTileHeight * 6,
                    header: 'Date of birth',
                    selected: date,
                    onChanged: (v) => setState(() => date = v),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 240,
                  child: TimePicker(
                    // popupHeight: kOneLineTileHeight * 5,
                    header: 'Arrival time',
                    selected: date,
                    onChanged: (v) => setState(() => date = v),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          */



        ],
      ),
    );
  }
}
