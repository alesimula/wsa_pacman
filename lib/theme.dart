import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;

enum NavigationIndicators { sticky, end }

class AppTheme extends ChangeNotifier {
  static final AccentColor alpineLandingDark = AccentColor('normal', const <String, Color>{
    'darkest': Color(0xff126568),
    'darker': Color(0xff146D70),
    'dark': Color(0xff157477),
    'normal': Color(0xff167C80),
    'light': Color(0xff188387),
    'lighter': Color(0xff198A8E),
    'lightest': Color(0xff1B9296),
  });
  static final AccentColor alpineLandingLight = AccentColor('normal', const <String, Color>{
    'darkest': Color(0xff167C80),
    'darker': Color(0xff188387),
    'dark': Color(0xff198A8E),
    'normal': Color(0xff1C9EA0),
    'light': Color(0xff1DA5A5),
    'lighter': Color(0xff20B2B2),
    'lightest': Color(0xff21B7B7),
  });
  AccentColor? _color; //Alpine landing FTW
  AccentColor getColor(bool darkMode) => _color ?? (darkMode ? alpineLandingDark : alpineLandingLight);
  void setColor(AccentColor color) {
    _color = (identical(color, alpineLandingDark) || identical(color, alpineLandingLight)) ? null : color;
    notifyListeners();
  }

  PaneDisplayMode _displayMode = PaneDisplayMode.top;
  PaneDisplayMode get displayMode => _displayMode;
  set displayMode(PaneDisplayMode displayMode) {
    _displayMode = displayMode;
    notifyListeners();
  }

  NavigationIndicators _indicator = NavigationIndicators.sticky;
  NavigationIndicators get indicator => _indicator;
  set indicator(NavigationIndicators indicator) {
    _indicator = indicator;
    notifyListeners();
  }

  /*flutter_acrylic.AcrylicEffect _acrylicEffect =
      flutter_acrylic.AcrylicEffect.disabled;
  flutter_acrylic.AcrylicEffect get acrylicEffect => _acrylicEffect;
  set acrylicEffect(flutter_acrylic.AcrylicEffect acrylicEffect) {
    _acrylicEffect = acrylicEffect;
    notifyListeners();
  }*/
}

AccentColor get systemAccentColor {
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.android ||
      kIsWeb) {
    return AccentColor('normal', {
      'darkest': SystemTheme.accentColor.darkest,
      'darker': SystemTheme.accentColor.darker,
      'dark': SystemTheme.accentColor.dark,
      'normal': SystemTheme.accentColor.accent,
      'light': SystemTheme.accentColor.light,
      'lighter': SystemTheme.accentColor.lighter,
      'lightest': SystemTheme.accentColor.lightest,
    });
  }
  return Colors.blue;
}
