// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:base32/encodings.dart';
import 'package:charset/charset.dart';
import 'package:crypto/crypto.dart';

import 'package:base32/base32.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../utils/string_utils.dart';


const _INITIAL_OUTPUT_BUFFER_CHARS = 256;

class WinPkg {
  static String getPublisherId(String publisher) {
    return base32.encode(Uint8List.fromList(sha256.convert((utf16.encoder as Utf16Encoder).encodeUtf16Le(publisher)).bytes.sublist(0, 8)), encoding: Encoding.crockford).toLowerCase();
  }

  static String? getPackageFamilyName(String fullName) {
    final lpName = fullName.toNativeUtf16();
    var lpFamilyName = malloc<WCHAR>(_INITIAL_OUTPUT_BUFFER_CHARS).cast<Utf16>();
    final lpBufferLenght = malloc<DWORD>()..value = _INITIAL_OUTPUT_BUFFER_CHARS;
    
    try {
      int exitCode = PackageFamilyNameFromFullName(lpName, lpBufferLenght, lpFamilyName);
      if (exitCode == ERROR_INSUFFICIENT_BUFFER) {
        free(lpFamilyName);
        lpFamilyName = malloc<WCHAR>(lpBufferLenght.value).cast<Utf16>();
        PackageFamilyNameFromFullName(lpName, lpBufferLenght, lpFamilyName);
      }
      return lpFamilyName.toDartString();
    }
    finally {
      free(lpName);
      free(lpFamilyName);
      free(lpBufferLenght);
    }
  }
}


class WinPkgInfo {
  late final String name;
  late final String publisherId;
  late final String version;
  late final String architecture;

  String get fullName => "${name}_${version}_${architecture}__$publisherId"; 
  String get familyName => "${name}_$publisherId";
  void parseManifestExtras(String manifest) {}

  WinPkgInfo(String manifest) {
    try {
      String? identity = RegExp(r'<\s*Identity[^">]*("[^"]*"[^">]*)*>', multiLine: true).firstMatch(manifest)?.group(0)?.replaceAll('\n', ' ');
      name = identity?.find(r'\s+Name\s*=\s*"([^"]*)', 1) ?? 'UNKNOWN_APP_NAME';
      String? publisher = identity?.find(r'\s+Publisher\s*=\s*"([^"]*)', 1);
      publisherId = (publisher != null) ? WinPkg.getPublisherId(publisher) : 'UNKNOWN_PUBLISHER_ID';
      version = identity?.find(r'\s+Version\s*=\s*"([^"]*)', 1) ?? 'UNKNOWN_VERSION';
      architecture = identity?.find(r'\s+ProcessorArchitecture\s*=\s*"([^"]*)', 1) ?? 'UNKNOWN_ARCHITECTURE';
      parseManifestExtras(manifest);
    }
    catch(e) {/**/}
  }

  WinPkgInfo.fromSystemPath(String systemPath) : this(_tryReadManifest("$systemPath\\AppxManifest.xml"));

  static String _tryReadManifest(String manifestFile) {
    try {return File(manifestFile).readAsStringSync();}
    catch(_) {return "";}
  }
}