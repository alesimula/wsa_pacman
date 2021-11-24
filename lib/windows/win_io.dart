// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, constant_identifier_names

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class RegistryKeyValuePair {
  final String key;
  final String value;

  const RegistryKeyValuePair(this.key, this.value);
}

extension WinFile on File {
  static const int _EPOCH_NT_DELTA_MICROSECONDS = 11644473600100000;
  
  /// Converts Flutter file to native file handle;
  /// Must call [CloseHandle] to release it
  int? toNativeFile() {
    final lpPath = absolute.path.toNativeUtf16();
    try {
      final handle = CreateFile(lpPath, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, 
          nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
      return handle != INVALID_HANDLE_VALUE ? handle : null;
    }
    finally {
      free(lpPath);
    }
  }

  /// Returns a more accurate modified date (microseconds precision as opposed to seconds)
  DateTime? lastModifiedAccurate() {
    int? handle = toNativeFile();
    if (handle != null) {
      final info = malloc<BY_HANDLE_FILE_INFORMATION>();
      try {
        int code = GetFileInformationByHandle(handle, info);
        if (code == 0) return null;
        FILETIME lastWrite = info.ref.ftLastWriteTime;
        int microseconds = (lastWrite.dwHighDateTime << 32 | lastWrite.dwLowDateTime) ~/ 10 - _EPOCH_NT_DELTA_MICROSECONDS;
        return DateTime.fromMicrosecondsSinceEpoch(microseconds);
      }
      finally {
        CloseHandle(handle);
        free(info);
      }
    }
  }
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