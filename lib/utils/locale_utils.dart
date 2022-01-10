// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'dart:ui';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
export 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'package:wsa_pacman/windows/win_io.dart';
import 'string_utils.dart';


extension LocaleUtils on Locale {
  _SystemLocale get _asSystemLocale => _SystemLocale(languageCode, countryCode);
  static late final NamedLocale _DEFAULT_SYSTEM_LOCALE = _SystemLocale("en");
  static late final _DEFAULT_LOCALIZATION = lookupAppLocalizations(_DEFAULT_SYSTEM_LOCALE);
  static late final _LOCALE = {for (final l in supportedLocales) l.lcid : l};
  static late final NamedLocale SYSTEM_LOCALE = (() {
    try {return (intl.Intl.systemLocale = intl.Intl.canonicalizedLocale(Platform.localeName)).asLocale?._asSystemLocale ?? _DEFAULT_SYSTEM_LOCALE;}
    catch (e) {return intl.Intl.systemLocale.asLocale?._asSystemLocale ?? _DEFAULT_SYSTEM_LOCALE;}
  })();

  //String langName() => isSystemLocale ? "System" : lookupAppLocalizations(this).locale_desc;
  static late final supportedLocales = <NamedLocale>[LocaleUtils.SYSTEM_LOCALE]
      .followedBy(AppLocalizations.supportedLocales.map<NamedLocale>((l) => _NamedLocale(l.languageCode, l.countryCode))).toList();
  static NamedLocale? fromLCID(int lcid) => lcid == 0 ? SYSTEM_LOCALE : _LOCALE[lcid];
  static NamedLocale fromLCIDOrDefault(int lcid) => lcid == 0 ? SYSTEM_LOCALE : _LOCALE[lcid] ?? SYSTEM_LOCALE;
  bool get isSystemLocale => identical(this, SYSTEM_LOCALE);
  AppLocalizations get _localizationOrDefault {
    try {return lookupAppLocalizations(this);}
    catch(_) {return _DEFAULT_LOCALIZATION;}
  }
}

abstract class NamedLocale extends Locale {
  const NamedLocale._(String _languageCode, [String? _countryCode]) : super(_languageCode, _countryCode);
  String get name;
  int get lcid;
}

class _NamedLocale extends NamedLocale {
  _NamedLocale(String _languageCode, [String? _countryCode]) : super._(_languageCode, _countryCode);
  @override late final String name = lookupAppLocalizations(this).locale_desc;
  @override late final int lcid = WinIO.localeToLCID(toLanguageTag()) ?? (){throw ArgumentError("Unknown language tag: ${toLanguageTag()}");}();
  @override int get hashCode => lcid;
  @override bool operator ==(Object other) => (other is NamedLocale && other.lcid == lcid) || (other is Locale && super==other);
}

class _SystemLocale extends NamedLocale {
  _SystemLocale(String _languageCode, [String? _countryCode]) : super._(_languageCode, _countryCode);
  @override late final String name = _localizationOrDefault.locale_system;
  @override final int lcid = 0;
  @override final int hashCode = 0;
  @override bool operator ==(Object other) => other is _SystemLocale;
}