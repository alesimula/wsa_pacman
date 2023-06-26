// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:async';
import 'dart:developer';

import 'package:jovial_svg/jovial_svg.dart';
import 'package:mdi/mdi.dart';
import 'package:protobuf/protobuf.dart';
import 'package:wsa_pacman/global_state.dart';
import 'package:wsa_pacman/proto/options.pb.dart';
import 'package:wsa_pacman/utils/locale_utils.dart';
import 'package:wsa_pacman/widget/adaptive_icon.dart';
import 'package:wsa_pacman/widget/fluent_card.dart';
import 'package:wsa_pacman/widget/fluent_combo_box.dart';
import 'package:wsa_pacman/widget/fluent_expander.dart';
import 'package:wsa_pacman/widget/fluent_text_box.dart';
import 'package:wsa_pacman/widget/smooth_list_view.dart';
import 'package:wsa_pacman/windows/win_info.dart';

import '/utils/string_utils.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

const List<String> accentColorNames = [
  'System',
  'Yellow',
  'Orange',
  'Red',
  'Magenta',
  'Purple',
  'Blue',
  'Teal',
  'Green',
];

class LateUpdater<E> {
  static const SETTINGS_UPDATE_TIMER = Duration(seconds:3);
  E initialValue;
  Timer? timer;
  Function(E value) callback;

  LateUpdater(this.initialValue, this.callback);
  update(E newValue) {
    initialValue = newValue;
    timer?.cancel();
    timer = Timer(SETTINGS_UPDATE_TIMER, (){if (initialValue == newValue) callback(initialValue);});
  }

  cancel() => timer?.cancel();

  instant(E newValue) {
    timer?.cancel();
    callback(newValue);
  }
}

class ScreenSettings extends StatefulWidget {
  ScreenSettings({Key? key, this.controller}) : super(key: key);
  final ScrollController? controller;

  @override
  State<StatefulWidget> createState() => ScreenSettingsState(controller: this.controller);
}

late final androidPortUpdater = LateUpdater<int>(GState.androidPort.$, (value){
  GState.androidPort..update((p0) => value)..persist();
  log("AGGIORNATO: ${GState.androidPort.$}");
});

class ScreenSettingsState extends State<ScreenSettings> {
  static const SETTINGS_UPDATE_TIMER = Duration(seconds:3);
  ScreenSettingsState({this.controller});
  final ScrollController? controller;

  static late final _exBackground = _loadIcon("assets/icons/missing_icon_background.si");
  static late final _exForeground = _loadIcon("assets/icons/missing_icon_foreground.si");
  static late final _exLegacyIcon = _loadIcon("assets/icons/missing_icon_legacy.si");

  static Future<ScalableImageWidget> _loadIcon(String asset) async {
    var scalable = ScalableImage.fromSIAsset(rootBundle, asset);
    return ScalableImageWidget(si: await scalable);
  }

  static List<Widget> optionsListDeferred<E extends ProtobufEnum, V>(List<E> values, String Function(E)? title, V Function(E e) getter, bool Function(V v) checked, Function(E e, V v) updater) => List.generate(values.length, (index) {
    final modeOpt = values[index];
    final mode = getter(modeOpt);
    return Padding(
      padding: index != values.length - 1 ? const EdgeInsets.only(bottom: 8.0) : EdgeInsets.zero,
      child: RadioButton(
        checked: checked(mode),
        onChanged: (value) {
          if (value) {
            updater(modeOpt, mode);
            //GState.theme..update((p0) => modeOpt)..persist();
            //themeMode = mode;
          }
        },
        content: Text(title != null ? title(modeOpt) : modeOpt.toString().normalized),
      ),
    );
  });

  static List<Widget> optionsList<E extends ProtobufEnum>(List<E> values, String Function(E)? title, bool Function(E e) checked, Function(E e) updater) =>
      optionsListDeferred<E, E>(values, title, (e) => e, checked, (e, v) => updater(e));
  
  static late final _localeItems = <NamedLocale>[LocaleUtils.SYSTEM_LOCALE].followedBy(LocaleUtils.supportedLocales).map((l)=>ComboboxItem(child: Text(l.name), value: l)).toList();

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    final theme = FluentTheme.of(context);
    final locale_lang = GState.locale.of(context);
    final lang = AppLocalizations.of(context)!;
    
    final tooltipThemeData = TooltipThemeData(decoration: () {
      const radius = BorderRadius.zero;
      final shadow = [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(1, 1),
          blurRadius: 10.0,
        ),
      ];
      final border = Border.all(color: Colors.grey[100], width: 0.5);
      if (theme.brightness == Brightness.light) {
        return BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          border: border,
          boxShadow: shadow,
        );
      } else {
        return BoxDecoration(
          color: Colors.grey,
          borderRadius: radius,
          border: border,
          boxShadow: shadow,
        );
      }
    }());

    const empty = SizedBox.shrink();
    const hSpacer = SizedBox(width: 10.0);
    const smallSpacer = SizedBox(height: 5.0);
    const spacer = SizedBox(height: 10.0);
    const biggerSpacer = SizedBox(height: 40.0);

    final themeMode = GState.theme.of(context).mode;
    final iconShape = GState.iconShape.of(context);
    final mica = GState.mica.of(context);
    final legacyIcons = GState.legacyIcons.of(context);
    final autostartWSA = GState.autostartWSA.of(context);
    final installTimeout = GState.installTimeout.of(context);
    final locale = AppLocalizations.of(context);

    final OFF = lang.btn_switch_off;
    final ON = lang.btn_switch_on;

    final exampleIcon = FutureBuilder(
      future: legacyIcons ? _exLegacyIcon : (() async =>AdaptiveIcon(background: await _exBackground, foreground: await _exForeground, radius: iconShape.radius))(), 
      builder: (context, AsyncSnapshot<Widget> snapshot) => snapshot.data ?? empty
    );

    return ScaffoldPage(
      header: PageHeader(title: Text(lang.screen_settings)),
      content: SmoothListView(
        padding: EdgeInsets.only(
          bottom: kPageDefaultVerticalPadding,
          left: PageHeader.horizontalPadding(context),
          right: PageHeader.horizontalPadding(context),
        ),
        children: [
          spacer,
          FluentCard(
            leading: const Icon(Mdi.networkOutline , size: 23),
            content: Text(lang.settings_port),
            trailing: SizedBox(width: 300, height: 32, child: FluentTextBox(
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  var androidPortVal = (newValue.text.isNumeric()) ? (newValue.text.length > 5 || (newValue.text.isEmpty ? 58526 : int.parse(newValue.text)) <= 65535 ? newValue : TextEditingValue(text: "65535", selection: newValue.selection)) : 
                  (oldValue.text.isNumeric() ? oldValue : TextEditingValue.empty);
                  GState.androidPortPending.$ = androidPortVal.text.isEmpty ? 58526.toString() : androidPortVal.text;
                  return androidPortVal;
                })
              ],
              maxLength: 5,
              maxLines: 1,
              maxLengthEnforced: true,
              controller: TextEditingController.fromValue(TextEditingValue(text: GState.androidPortPending.$)),
              autofocus: false,
              onChanged: (value)=>androidPortUpdater.update(value.isEmpty ? 58526 : int.parse(value)),
              enableSuggestions: false,
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
              prefix: const Padding(padding: EdgeInsetsDirectional.only(start: 10), child: Text("127.0.0.1 :")),
              suffix: IconButton (
                iconButtonMode: IconButtonMode.small,
                icon: const Icon(FluentIcons.reset),
                onPressed: () {GState.androidPortPending.update((_) => 58526.toString()); androidPortUpdater.instant(58526); setState((){});},
              )
            )),
          ),
          smallSpacer,
          FluentCard(
            leading: const Icon(Mdi.powerStandby , size: 23),
            content: Text(lang.settings_autostart),
            trailing: Row(children: [ConstrainedBox(constraints: const BoxConstraints(minWidth: 28.5), child: Text(autostartWSA ? ON : OFF)), ToggleSwitch(
              checked: autostartWSA,
              onChanged: (v) => GState.autostartWSA..$ = v..persist()
            )]),
          ),
          smallSpacer,
          FluentCard(
            leading: const Icon(Mdi.timerOutline, size: 23),
            content: Text(lang.settings_timeout(installTimeout == 0 ? '∞' : '$installTimeout')),
            trailing: SizedBox(width: 300, height: 32, child: FluentCard(isInner: true, content: Slider(
              min: 0,
              max: 105, 
              value: (installTimeout == 0 ? 105 : installTimeout < 15 ? 15 : installTimeout > 105 ? 105 : installTimeout).toDouble(),
              divisions: 7,
              label: installTimeout == 0 ? '∞' : '$installTimeout',
              style: SliderThemeData(
                labelBackgroundColor: theme.brightness == Brightness.dark ? const Color(0x22DDDDDD) : const Color(0x33000000)
              ),
              onChanged: (l){l = (l == 0) ? 15 : (l == 105) ? 0 : l; GState.installTimeout..$=l.toInt()..persist();},
            ))),
          ),
          smallSpacer,
          FluentCard(
            leading: const Icon(Mdi.translate , size: 23),
            content: Text(lang.settings_language),
            trailing: SizedBox(width: 300, height: 32, child: FluentCombobox<NamedLocale>(
              allowUnknown: true,
              onTap: (){}, placeholder: Text(locale_lang.name), 
              isExpanded: true,
              value: locale_lang,
              onChanged: (l){if (l != null) GState.locale..$=l..persist();},
              items: _localeItems,
            )),
          ),
          smallSpacer,
          ExpanderWin11(
            leading: const Icon(Mdi.themeLightDark, size: 23),
            header: Text(lang.theme_mode),
            content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: 
                optionsListDeferred<Options_Theme, ThemeMode>(Options_Theme.values, (e)=>e.description(lang), (e) => e.mode, (v) => themeMode == v, (e, v) => GState.theme..update((p0) => e)..persist())
            ),
            //headerBackgroundColor: ThemablePaneItem.uncheckedInputAlphaColor(theme, states),
            direction: ExpanderDirection.down, // (optional). Defaults to ExpanderDirection.down
            initiallyExpanded: false, // (false). Defaults to false
          ),
          smallSpacer,
          if (WinVer.isWindows11OrGreater) ExpanderWin11(
            leading: const Icon(Mdi.blur, size: 23),
            header: Text(lang.theme_mica),
            content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: 
                optionsList<Options_Mica>(Options_Mica.values, (e)=>e.description(lang), (e) => mica == e, (e) => GState.mica..update((_) => e)..persist())
            ),
            //headerBackgroundColor: ThemablePaneItem.uncheckedInputAlphaColor(theme, states),
            direction: ExpanderDirection.down, // (optional). Defaults to ExpanderDirection.down
            initiallyExpanded: false, // (false). Defaults to false
          ),
          if (WinVer.isWindows11OrGreater) smallSpacer,
          ExpanderWin11(
            leading: SizedBox(width: 23.00, height: 23.00, child: exampleIcon),
            header: Text(lang.theme_icon_adaptive),
            content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: 
                optionsList<Options_IconShape>(Options_IconShape.values, (e)=>e.description(lang), (e) => iconShape == e, (e) => GState.iconShape..update((_) => e)..persist())
            ),
            trailing: Row(children: [ConstrainedBox(constraints: const BoxConstraints(minWidth: 28.5), child: Text(legacyIcons ? OFF : ON)), ToggleSwitch(
              checked: !legacyIcons,
              onChanged: (v) => GState.legacyIcons..$ = !v..persist()
            )]),
            //headerBackgroundColor: ThemablePaneItem.uncheckedInputAlphaColor(theme, states),
            direction: ExpanderDirection.down, // (optional). Defaults to ExpanderDirection.down
            initiallyExpanded: false, // (false). Defaults to false
          )
        ],
      ),
    );
  }
  
}
