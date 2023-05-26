// ignore_for_file: non_constant_identifier_names, constant_identifier_names, curly_braces_in_flow_control_structures

import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:win32/win32.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
export 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_localizations/flutter_localizations.dart' as locale;
import 'package:wsa_pacman/windows/win_io.dart';
import 'string_utils.dart';

// Extra RTL language definitions in case they are missing from [widget.WidgetsLocalizations._rtlLanguages]
const List<String> _RTL_LANGUAGE_OVERRIDES = <String>[
  'ku', // Kurdish
];

extension LocaleUtils on Locale {
  _NamedLocale _asNamedLocale([int? lcid]) => lcid == null ? _NamedLocale(languageCode, countryCode, scriptCode) : _NamedLocaleLCID(lcid, languageCode, countryCode);
  _SystemLocale get _asSystemLocale => _SystemLocale(languageCode, countryCode, scriptCode);
  static late final NamedLocale _DEFAULT_SYSTEM_LOCALE = _SystemLocale("en");
  static late final _DEFAULT_LOCALIZATION = lookupAppLocalizations(_DEFAULT_SYSTEM_LOCALE);
  //static late final _LOCALE = {for (final l in supportedLocales) l.lcid : l};
  static late final NamedLocale SYSTEM_LOCALE = (() {
    try {return (intl.Intl.systemLocale = intl.Intl.canonicalizedLocale(Platform.localeName)).asLocale?._asSystemLocale ?? _DEFAULT_SYSTEM_LOCALE;}
    catch (e) {return intl.Intl.systemLocale.asLocale?._asSystemLocale ?? _DEFAULT_SYSTEM_LOCALE;}
  })();

  static late final supportedLocales = SplayTreeSet<NamedLocale>.from(AppLocalizations.supportedLocales.map<NamedLocale>((l) => _NamedLocale(l.languageCode, l.countryCode, l.scriptCode)), (a, b) => a.name.compareTo(b.name));
  int? toLCID() => _WinLocale.localeToLCID(toLanguageTag());
  static NamedLocale? fromLCID(int lcid) => lcid == 0 ? SYSTEM_LOCALE : _WinLocale.localeFromLCID(lcid);
  static NamedLocale fromLCIDOrDefault(int lcid) => fromLCID(lcid) ?? SYSTEM_LOCALE;
  bool get isSystemLocale => identical(this, SYSTEM_LOCALE);
  AppLocalizations get _localizationOrDefault {
    try {return lookupAppLocalizations(this);}
    catch(_) {return _DEFAULT_LOCALIZATION;}
  }

  static Locale? _SYSTEM_MATCH;
  static Locale localeResolutionCallback(Locale? locale, Iterable<Locale> list) {
    Locale? bestMatch;
    int confidence = 0;
    if (locale != null) {
      if (locale is _NamedLocale && list is Iterable<NamedLocale>) {
        if (locale._isValid == true) return locale;
        else if (locale._isValid == null) for (final lc in list) if (locale == lc) {locale._isValid = true; return lc;}
        locale._isValid = false;
      }
      else if (locale is! _SystemLocale || _SYSTEM_MATCH == null) for (final lc in list) if (locale.languageCode == lc.languageCode) {
        int newConfidence = locale.scriptCode == lc.scriptCode ? locale.countryCode == lc.countryCode ? 8 : lc.countryCode == null ? 7 : 6 : 
            locale.countryCode == lc.countryCode ? 5 : lc.scriptCode == null ? lc.countryCode == null ? 4 : 3 : lc.countryCode == null ? 2 : 1;
        if (newConfidence > confidence) {
          confidence = newConfidence;
          bestMatch = lc;
          if (confidence == 8) break;
        }
      }
    }
    bestMatch = bestMatch ?? const Locale("en");
    return (locale is _SystemLocale) ? _SYSTEM_MATCH ??= bestMatch : bestMatch;
  }
}

// Only used to add extra missing RTL languages
class _WidgetsLocalizationsOverridesDelegate extends widgets.LocalizationsDelegate<widgets.WidgetsLocalizations> {
  const _WidgetsLocalizationsOverridesDelegate();
  @override bool isSupported(Locale locale) => true;
  @override Future<widgets.WidgetsLocalizations> load(Locale locale) => WidgetLocalizationOverrides.load(locale);
  @override bool shouldReload(_WidgetsLocalizationsOverridesDelegate old) => false;
  @override String toString() => 'WidgetLocalizationOverrides.delegate(all locales)';
}

// Only used to add extra missing RTL languages
class WidgetLocalizationOverrides extends locale.GlobalWidgetsLocalizations {
  WidgetLocalizationOverrides(Locale locale) : super(locale) {
    final String language = locale.languageCode.toLowerCase();
    TextDirection defaultDirection = super.textDirection;
    _textDirection = defaultDirection == TextDirection.rtl ? defaultDirection : 
        _RTL_LANGUAGE_OVERRIDES.contains(language) ? TextDirection.rtl : TextDirection.ltr;
  }
  
  late TextDirection _textDirection;
  static const widgets.LocalizationsDelegate<widgets.WidgetsLocalizations> delegate = _WidgetsLocalizationsOverridesDelegate();
  @override TextDirection get textDirection => _textDirection;
  static Future<widgets.WidgetsLocalizations> load(Locale locale) {
    return SynchronousFuture<widgets.WidgetsLocalizations>(WidgetLocalizationOverrides(locale));
  }
}


class _WinLocale {
  static const int LOCALE_NAME_MAX_LENGTH = 85;
  //static const int LOCALE_SSCRIPTS = 108;
  static const int LOCALE_SPARENT = 109;

  static final _LocaleNameToLCID = kernel32.lookupFunction<
    Uint32 Function(Pointer<Utf16> lpName, Uint32 dwFlags), 
    int Function(Pointer<Utf16> lpName, int dwFlags)>('LocaleNameToLCID');
  static final _LCIDToLocaleName = kernel32.lookupFunction<
    Uint32 Function(Uint32 locale, Pointer<Utf16> lpName, Int32 cchName, Uint32 dwFlags), 
    int Function(int locale, Pointer<Utf16> lpName, int cchName, int dwFlags)>('LCIDToLocaleName');

  static String parentScriptCode(Locale locale) {
    final lpLocaleName = '${locale.languageCode}${locale.countryCode != null ? "-${locale.countryCode}" : ""}'.toNativeUtf16();
    final lpLCData = malloc<WCHAR>(LOCALE_NAME_MAX_LENGTH).cast<Utf16>();
    try {
      int result = GetLocaleInfoEx(lpLocaleName, LOCALE_SPARENT, lpLCData, LOCALE_NAME_MAX_LENGTH);
      return (result != 0 ? lpLCData.toDartString() : '').find('^[^_-]*[_-]([^_-]+)', 1) ?? '';
    }
    finally {
      free(lpLocaleName);
      free(lpLCData);
    }
  }

  static int? localeToLCID(String locale) {
    final lpName = locale.toNativeUtf16();
    try {
      final int lcid = _LocaleNameToLCID(lpName, 0);
      switch (lcid) {
        case 0: case 0x1000: case 0x0C00: return null;
        default: return lcid;
      }
    }
    finally {free(lpName);}
  }

  static NamedLocale? localeFromLCID(int lcid) {
    LPWSTR? lpName = malloc<WCHAR>(LOCALE_NAME_MAX_LENGTH).cast<Utf16>();
    try {
      int result = _LCIDToLocaleName(lcid, lpName, LOCALE_NAME_MAX_LENGTH, 0);
      return result != 0 ? lpName.toDartString().asLocale?._asNamedLocale(lcid) : null;
    }
    finally {free(lpName);}
  }
}


abstract class NamedLocale extends Locale {
  const NamedLocale._(String _languageCode, [String? _countryCode, String? _scriptCode]) : 
      super.fromSubtags(languageCode: _languageCode, countryCode: _countryCode, scriptCode: _scriptCode);
  String get name;
  int get lcid;
}

class _NamedLocale extends NamedLocale {
  bool? _isValid;
  _NamedLocale(String _languageCode, [String? _countryCode, String? _scriptCode]) : super._(_languageCode, _countryCode, _scriptCode);
  @override late final String name = lookupAppLocalizations(this).locale_desc;
  @override late final int lcid = toLCID() ?? (){throw ArgumentError("Unknown language tag: ${toLanguageTag()}");}();
  @override int get hashCode => lcid;
  @override bool operator ==(Object other) => other is! _SystemLocale && (other is NamedLocale ? other.languageCode == languageCode && other.lcid == lcid : super==other);
}

class _NamedLocaleLCID extends _NamedLocale {
  _NamedLocaleLCID(this.lcid, String _languageCode, [String? _countryCode, String? _scriptCode]) : super(_languageCode, _countryCode, _scriptCode);
  // ignore: overridden_fields 
  @override late final String name = (){try {return super.name;} catch (e) {return "Unknown";}}();
  // ignore: overridden_fields 
  @override final int lcid;
}

class _SystemLocale extends NamedLocale {
  _SystemLocale(String _languageCode, [String? _countryCode, String? _scriptCode]) : super._(_languageCode, _countryCode) {
    if (_scriptCode != null) scriptCode = _scriptCode;
  }
  // ignore: overridden_fields
  @override late String? scriptCode = _WinLocale.parentScriptCode(this);
  @override late final String name = _localizationOrDefault.locale_system;
  @override final int lcid = 0;
  @override final int hashCode = 0;
  @override bool operator ==(Object other) => other is _SystemLocale;
}