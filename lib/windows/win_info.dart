// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:wsa_pacman/windows/win_wmi.dart';

bool testFlag(int value, int attribute) => value & attribute == attribute;

/// Represents the version number (e.g. 10.0)
class WinVer {
  int major;
  int minor;
  WinVer._(this.major, this.minor);

  static late final String WIN_CAPTION = WinWMI.queryString('Caption', 'Win32_OperatingSystem') ?? '';

  @override String toString() => '$major.$minor';

  static late final WinVer version = (){
    final versionInfo = calloc<OSVERSIONINFO>();
    versionInfo.ref.dwOSVersionInfoSize = sizeOf<OSVERSIONINFO>();

    try {
      final result = GetVersionEx(versionInfo);
      return (result != 0) ? WinVer._(versionInfo.ref.dwMajorVersion, versionInfo.ref.dwMinorVersion) : WinVer._(0, 0);
    } finally {free(versionInfo);}
  }();

  static bool isAtLeast(int major, int minor) => version.major > major || version.major == major && version.minor >= minor;

  static late final bool isWindowsXPOrGreater = isAtLeast(5, 1);
  static late final bool isWindowsVistaOrGreater = isAtLeast(6, 0);
  static late final bool isWindows7OrGreater = isAtLeast(6, 1);
  static late final bool isWindows8OrGreater = isAtLeast(6, 2);
  static late final bool isWindows10OrGreater = isAtLeast(10, 0);
  static late final bool isWindows11OrGreater = isAtLeast(10, 1) || 
      (isAtLeast(10, 0) && !WIN_CAPTION.contains(RegExp(r'(^|\s)(Windows 10x?|Server 2016)($|\s)', caseSensitive: false)) );
}