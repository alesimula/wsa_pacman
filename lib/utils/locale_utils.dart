// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'dart:ui';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
export 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'string_utils.dart';


extension LocaleUtils on Locale {
  _SystemLocale get _asSystemLocale => _SystemLocale(languageCode, countryCode);
  static late final NamedLocale _DEFAULT_SYSTEM_LOCALE = _SystemLocale("en");
  static late final _DEFAULT_LOCALIZATION = lookupAppLocalizations(_DEFAULT_SYSTEM_LOCALE);
  static late final _LOCALE = {for (final l in supportedLocales) l.hashCode : l};
  static late final NamedLocale SYSTEM_LOCALE = (() {
    try {return (intl.Intl.systemLocale = intl.Intl.canonicalizedLocale(Platform.localeName)).asLocale?._asSystemLocale ?? _DEFAULT_SYSTEM_LOCALE;}
    catch (e) {return intl.Intl.systemLocale.asLocale?._asSystemLocale ?? _DEFAULT_SYSTEM_LOCALE;}
  })();

  //String langName() => isSystemLocale ? "System" : lookupAppLocalizations(this).locale_desc;
  static late final supportedLocales = <NamedLocale>[LocaleUtils.SYSTEM_LOCALE]
      .followedBy(AppLocalizations.supportedLocales.map<NamedLocale>((l) => _NamedLocale(l.languageCode, l.countryCode)));
  static NamedLocale? fromHash(int hash) => hash == 0 ? SYSTEM_LOCALE : _LOCALE[hash];
  static NamedLocale fromHashOrDefault(int hash) => hash == 0 ? SYSTEM_LOCALE : _LOCALE[hash] ?? SYSTEM_LOCALE;
  bool get isSystemLocale => identical(this, SYSTEM_LOCALE);
  AppLocalizations get _localizationOrDefault {
    try {return lookupAppLocalizations(this);}
    catch(_) {return _DEFAULT_LOCALIZATION;}
  }
}

abstract class NamedLocale extends Locale {
  const NamedLocale._(String _languageCode, [String? _countryCode]) : super(_languageCode, _countryCode);
  String get name;
}

class _NamedLocale extends NamedLocale {
  late final String _name;
  _NamedLocale(String _languageCode, [String? _countryCode]) : super._(_languageCode, _countryCode) {
    _name = lookupAppLocalizations(this).locale_desc;
  }
  @override String get name => _name;
}

class _SystemLocale extends NamedLocale {
  late final String _name;
  _SystemLocale(String _languageCode, [String? _countryCode]) : super._(_languageCode, _countryCode) {
    _name = _localizationOrDefault.locale_system;
  }
  @override String get name => _name;
  @override int get hashCode => 0;
  @override bool operator ==(Object other) => other is _SystemLocale;
}