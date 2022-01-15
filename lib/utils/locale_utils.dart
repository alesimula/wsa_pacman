// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
export 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'package:wsa_pacman/windows/win_io.dart';
import 'string_utils.dart';

extension LocaleUtils on Locale {
  _NamedLocale _asNamedLocale([int? lcid]) => lcid == null ? _NamedLocale(languageCode, countryCode) : _NamedLocaleLCID(lcid, languageCode, countryCode);
  _SystemLocale get _asSystemLocale => _SystemLocale(languageCode, countryCode);
  static late final NamedLocale _DEFAULT_SYSTEM_LOCALE = _SystemLocale("en");
  static late final _DEFAULT_LOCALIZATION = lookupAppLocalizations(_DEFAULT_SYSTEM_LOCALE);
  //static late final _LOCALE = {for (final l in supportedLocales) l.lcid : l};
  static late final NamedLocale SYSTEM_LOCALE = (() {
    try {return (intl.Intl.systemLocale = intl.Intl.canonicalizedLocale(Platform.localeName)).asLocale?._asSystemLocale ?? _DEFAULT_SYSTEM_LOCALE;}
    catch (e) {return intl.Intl.systemLocale.asLocale?._asSystemLocale ?? _DEFAULT_SYSTEM_LOCALE;}
  })();

  //String langName() => isSystemLocale ? "System" : lookupAppLocalizations(this).locale_desc;
  static late final supportedLocales = <NamedLocale>[LocaleUtils.SYSTEM_LOCALE]
      .followedBy(AppLocalizations.supportedLocales.map<NamedLocale>((l) => _NamedLocale(l.languageCode, l.countryCode))).toList();
  int? toLCID() => _WinLocale.localeToLCID(toLanguageTag());
  static NamedLocale? fromLCID(int lcid) => lcid == 0 ? SYSTEM_LOCALE : _WinLocale.localeFromLCID(lcid);
  static NamedLocale fromLCIDOrDefault(int lcid) => fromLCID(lcid) ?? SYSTEM_LOCALE;
  bool get isSystemLocale => identical(this, SYSTEM_LOCALE);
  AppLocalizations get _localizationOrDefault {
    try {return lookupAppLocalizations(this);}
    catch(_) {return _DEFAULT_LOCALIZATION;}
  }
}


class _WinLocale {
  static const int LOCALE_NAME_MAX_LENGTH = 85;

  static final _LocaleNameToLCID = kernel32.lookupFunction<
    Uint32 Function(Pointer<Utf16> lpName, Uint32 dwFlags), 
    int Function(Pointer<Utf16> lpName, int dwFlags)>('LocaleNameToLCID');
  static final _LCIDToLocaleName = kernel32.lookupFunction<
    Uint32 Function(Uint32 locale, Pointer<Utf16> lpName, Int32 cchName, Uint32 dwFlags), 
    int Function(int locale, Pointer<Utf16> lpName, int cchName, int dwFlags)>('LCIDToLocaleName');

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
  const NamedLocale._(String _languageCode, [String? _countryCode]) : super(_languageCode, _countryCode);
  String get name;
  int get lcid;
}

class _NamedLocale extends NamedLocale {
  _NamedLocale(String _languageCode, [String? _countryCode]) : super._(_languageCode, _countryCode);
  @override late final String name = lookupAppLocalizations(this).locale_desc;
  @override late final int lcid = toLCID() ?? (){throw ArgumentError("Unknown language tag: ${toLanguageTag()}");}();
  @override int get hashCode => lcid;
  @override bool operator ==(Object other) => other is! _SystemLocale && (other is NamedLocale ? other.languageCode == languageCode && other.lcid == lcid : super==other);
}

class _NamedLocaleLCID extends _NamedLocale {
  _NamedLocaleLCID(this.lcid, String _languageCode, [String? _countryCode]) : super(_languageCode, _countryCode);
  // ignore: overridden_fields 
  @override late final String name = (){try {return super.name;} catch (e) {return "Unknown";}}();
  // ignore: overridden_fields 
  @override final int lcid;
}

class _SystemLocale extends NamedLocale {
  _SystemLocale(String _languageCode, [String? _countryCode]) : super._(_languageCode, _countryCode);
  @override late final String name = _localizationOrDefault.locale_system;
  @override final int lcid = 0;
  @override final int hashCode = 0;
  @override bool operator ==(Object other) => other is _SystemLocale;
}