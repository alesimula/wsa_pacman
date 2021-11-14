// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class RegistryKeyValuePair {
  final String key;
  final String value;

  const RegistryKeyValuePair(this.key, this.value);
}

class WinIO {
  /// Creates a Windows shortcut (.lnk);
  static void createShortcut(String filePath, String linkPath, {String? description, String? args, String? icon}) {
    final shellLink = ShellLink.createInstance();
    final lpPath = filePath.toNativeUtf16();
    final lpArgs = args?.toNativeUtf16();
    final lpIcon = icon?.toNativeUtf16();
    final lpLinkPath = "$linkPath.lnk".toNativeUtf16();
    final lpDescription = description?.toNativeUtf16() ?? nullptr;
    final ptrIID_IPersistFile = convertToCLSID(IID_IPersistFile);
    final ppf = calloc<COMObject>();

    try {
      shellLink.SetPath(lpPath);
      if (lpArgs != null) shellLink.SetArguments(lpArgs);
      if (description != null) shellLink.SetDescription(lpDescription);
      if (lpIcon != null) shellLink.SetIconLocation(lpIcon, 0);

      final hr = shellLink.QueryInterface(ptrIID_IPersistFile, ppf.cast());
      if (SUCCEEDED(hr)) {
        final persistFile = IPersistFile(ppf);
        persistFile.Save(lpLinkPath, TRUE);
        persistFile.Release();
      }
      shellLink.Release();
    } finally {
      free(lpPath);
      if (lpArgs != null) free(lpArgs);
      if (lpIcon != null) free(lpIcon);
      free(lpLinkPath);
      if (lpDescription != nullptr) free(lpDescription);
      free(ptrIID_IPersistFile);
      free(ppf);
    }
  }
}