// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, constant_identifier_names

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:path/path.dart' as lib_path;

final kernel32 = DynamicLibrary.open('kernel32.dll');
final _CreateMutex = kernel32.lookupFunction<
      IntPtr Function(Pointer<SECURITY_ATTRIBUTES> lpMutexAttributes, Pointer<Utf16> lpName, Uint32 dwFlags, Uint32 dwDesiredAccess),
      int Function(Pointer<SECURITY_ATTRIBUTES> lpMutexAttributes, Pointer<Utf16> lpName, int dwFlags, int dwDesiredAccess)>('CreateMutexExW');
final _OpenMutex = kernel32.lookupFunction<
      IntPtr Function(Uint32 dwDesiredAccess, Int32 bInheritHandle, Pointer<Utf16> lpName),
      int Function(int dwDesiredAccess, int bInheritHandle, Pointer<Utf16> lpName)>('OpenMutexW');
final _WaitForSingleObjectEx = kernel32.lookupFunction<
      Uint32 Function(Uint32 hHandle, Uint32 dwMilliseconds, Int32 bAlertable),
      int Function(int hHandle, int dwMilliseconds, int bAlertable)>('WaitForSingleObjectEx');
final _ReleaseMutex = kernel32.lookupFunction<
      Int32 Function(Uint32 hHandle),
      int Function(int hHandle)>('ReleaseMutex');
final _GetShortPathName = kernel32.lookupFunction<
      Uint32 Function(Pointer<Utf16> lpszLongPath, Pointer<Utf16> lpszShortPath, Uint32 cchBuffer),
      int Function(Pointer<Utf16> lpszLongPath, Pointer<Utf16> lpszShortPath, int cchBuffer)>('GetShortPathNameW');
final _SetFileInformationByHandle = kernel32.lookupFunction<
      Uint32 Function(Uint32 hFile, Uint32 fileInformationClass,Pointer lpFileInformation, DWORD dwBufferSize),
      int Function(int hFile, int fileInformationClass, Pointer lpFileInformation, int dwBufferSize)>('SetFileInformationByHandle');

enum _FILE_INFO_BY_HANDLE_CLASS {
  FileBasicInfo, FileStandardInfo, FileNameInfo, FileRenameInfo, FileDispositionInfo, FileAllocationInfo,
  FileEndOfFileInfo, FileStreamInfo, FileCompressionInfo, FileAttributeTagInfo, FileIdBothDirectoryInfo,
  FileIdBothDirectoryRestartInfo, FileIoPriorityHintInfo, FileRemoteProtocolInfo, FileFullDirectoryInfo,
  FileFullDirectoryRestartInfo, FileStorageInfo, FileAlignmentInfo, FileIdInfo, FileIdExtdDirectoryInfo,
  FileIdExtdDirectoryRestartInfo, FileDispositionInfoEx, FileRenameInfoEx, FileCaseSensitiveInfo,
  FileNormalizedNameInfo, MaximumFileInfoByHandleClass
}

class RegistryKeyValuePair {
  final String key;
  final String value;

  const RegistryKeyValuePair(this.key, this.value);
}

/// Locks files and marks them for deletion
/// The files will be deleted if the application is closed or by calling dispose()
/// The files cannot be opened unless unflagged by calling clear()
class FileDisposeQueue {
  final _handles = <int>{};

  /// Adds a file to the deletion queue
  /// File will be locked
  bool add(File file) {
    int? handle = _lockFile(file);
    if (handle != null) _handles.add(handle);
    return handle != null;
  }

  /// Unlock all, remove delete flag and clear collection
  /// Returns true if all files are cleared successfully, false otherwise
  bool clear() {
    final failed = <int>[];
    for (int handle in _handles) {
      if (_setLock(handle, false)) CloseHandle(handle);
      else failed.add(handle);
    }
    failed.isEmpty ? _handles.clear() : _handles.retainAll(failed);
    return failed.isEmpty;
  }

  /// Dispose of all files immediately and clear collection
  void dispose() {
    for (int handle in _handles) CloseHandle(handle);
    _handles.clear();
  }

  bool _setLock(int handle, bool lock) {
    Pointer<BOOL> lpBool = malloc<BOOL>()..value = lock ? TRUE : FALSE;
    try {
      int res1 = _SetFileInformationByHandle(handle, _FILE_INFO_BY_HANDLE_CLASS.FileDispositionInfo.index, lpBool, sizeOf<BOOL>());
      int res2 = _SetFileInformationByHandle(handle, _FILE_INFO_BY_HANDLE_CLASS.FileDispositionInfoEx.index, lpBool, sizeOf<BOOL>());
      return res1 != 0 || res2 != 0;
    }
    finally {
      free(lpBool);
    }
  }

  int? _lockFile(File file) {
    final lpToken = malloc<HANDLE>();
    final pszPath = file.absolute.path.toNativeUtf16();
    
    try {
      int handle = CreateFile(pszPath, DELETE, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, nullptr, 
          OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
      bool locked = _setLock(handle, true);
      if (!locked) CloseHandle(handle);
      return handle != INVALID_HANDLE_VALUE && locked ? handle : null;
    }
    finally {
      free(lpToken);
      free(pszPath);
    }
  }
}

extension WinFile on File {
  static const int _EPOCH_NT_DELTA_MICROSECONDS = 11644473600100000;

  static String? getShortName(String path) {
    final lpFilePath = TEXT(path);
    LPWSTR? lpShortFilePath;
    try {
      int result = _GetShortPathName(lpFilePath, nullptr, 0);
      if (result == 0) return null;
      result = _GetShortPathName(lpFilePath, lpShortFilePath = malloc<WCHAR>(result).cast<Utf16>(), result);
      if (result == 0) return null;
      return lpShortFilePath.toDartString();
    }
    finally {
      free(lpFilePath);
      if (lpShortFilePath != null) free(lpShortFilePath);
    }
  }

  static String? getShortBaseName(String path) {
    String? shortName = getShortName(path);
    return (shortName != null) ? lib_path.basename(shortName) : null;
  }
  
  String? get shortName => getShortName(absolute.path);
  String? get shortBaseName => getShortBaseName(absolute.path);
  
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

enum ShellOp {
  EDIT, EXPLORE, FIND, OPEN, PRINT, PROPERTIES, RUNAS
}

extension on ShellOp {
  LPWSTR getOperation() {switch (this) {
    case ShellOp.EDIT: return "edit".toNativeUtf16();
    case ShellOp.EXPLORE: return "explore".toNativeUtf16();
    case ShellOp.FIND: return "find".toNativeUtf16();
    case ShellOp.OPEN: return "open".toNativeUtf16();
    case ShellOp.PRINT: return "print".toNativeUtf16();
    case ShellOp.PROPERTIES: return "properties".toNativeUtf16();
    case ShellOp.RUNAS: return "runas".toNativeUtf16();
  }}
}

class WinIO {
  static bool run(ShellOp operation, String file, String? param) {
    if (file.isEmpty) return false;
    LPWSTR lpOperation = operation.getOperation();
    LPWSTR lpFile = file.toNativeUtf16();
    LPWSTR lpParameters = param != null && param.isNotEmpty ? param.toNativeUtf16() : nullptr;
    try {
      return ShellExecute(0, lpOperation, lpFile, lpParameters, nullptr, SW_HIDE) > 32;
    } 
    finally {
      free(lpOperation);
      free(lpFile);
      free(lpParameters);
    }
  }

  static bool findMutexWstr(LPWSTR lpMutexName) {
    int mutexHandle = _OpenMutex(0x00100000, 0, lpMutexName);
    if (mutexHandle != 0) {CloseHandle(mutexHandle); return true;}
    else return false;
  }

  static bool findMutex(String mutexName) {
    final lpMutexName = TEXT(mutexName);
    //int mutexHandle = _CreateMutex(nullptr, TEXT(r"{42CEB0DF-325A-4FBE-BBB6-C259A6C3F0BB}"), 0, 0x001F0001);
    try {return findMutexWstr(lpMutexName);}
    finally {free(lpMutexName);}
  }

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