// ignore_for_file: camel_case_types, constant_identifier_names, non_constant_identifier_names, curly_braces_in_flow_control_structures

import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import '../utils/misc_utils.dart';
import 'package:wsa_pacman/windows/win_path.dart';

import 'win_io.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:path/path.dart' as lib_path;

final ntdll = DynamicLibrary.open('ntdll.dll');
final advapi32 = DynamicLibrary.open('advapi32.dll');
const _ANYSYZE_ARRAY = 1;

class UNICODE_STRING extends Struct {
  @USHORT() external int length;
  @USHORT() external int maximumLength;
  external LPWSTR buffer;
  void free() => calloc.free(buffer);
}

class OBJECT_ATTRIBUTES extends Struct {
  @ULONG() external int length;
  @HANDLE() external int rootDirectory;
  external Pointer<UNICODE_STRING> objectName;
  @ULONG() external int attributes;
  external Pointer securityDescriptor;
  external Pointer securityQualityOfService;
}

/*class _IO_STATUS_BLOCK extends Struct {
  external _IO_STATUS_BLOCK__Anonymous_e__Union Anonymous;
  @UintPtr() external int Information;
}

class _IO_STATUS_BLOCK__Anonymous_e__Union extends Union {
  @NTSTATUS() external int hIcon;
  @IntPtr() external int hMonitor;
}*/

class REPARSE_MOUNTPOINT_DATA_BUFFER extends Struct {
  @DWORD() external int reparseTag;
  @DWORD() external int reparseDataLength;
  @WORD() external int reserved;
  @WORD() external int reparseTargetLength;
  @WORD() external int reparseTargetMaximumLength;
  @WORD() external int reserved1;
  @Array(_ANYSYZE_ARRAY) external Array<WCHAR> reparseTarget;
}

class _TOKEN_PRIVILEGES extends Struct {
  @DWORD() external int privilegeCount;
  @Array(_ANYSYZE_ARRAY) external Array<_LUID_AND_ATTRIBUTES> privileges;
}

class _LUID_AND_ATTRIBUTES extends Struct {
  external LUID luid;
  @DWORD() external int attributes;
}

final _NtCreateSymbolicLinkObject = ntdll.lookupFunction<
      Uint32 Function(Pointer<IntPtr> linkHandle, Uint32 desiredAccess, Pointer<OBJECT_ATTRIBUTES> objectAttributes, Pointer<UNICODE_STRING> linkTarget),
      int Function(Pointer<IntPtr> linkHandle, int desiredAccess, Pointer<OBJECT_ATTRIBUTES> objectAttributes, Pointer<UNICODE_STRING> linkTarget)>('NtCreateSymbolicLinkObject');
final _NtStatusToDosError = ntdll.lookupFunction<Uint32 Function(Int32 status), int Function(int status)>('RtlNtStatusToDosError');
final _CreateDirectoryObject = ntdll.lookupFunction<
    Uint32 Function(Pointer<IntPtr> lpHandle, Uint32 desiredAccess, Pointer<OBJECT_ATTRIBUTES> obj_attr, HANDLE shadowDirectoryHandle, Uint32 flags), 
    int Function(Pointer<IntPtr> lpHandle, int desiredAccess, Pointer<OBJECT_ATTRIBUTES> obj_attr, int shadowDirectoryHandle, int flags)>('NtCreateDirectoryObjectEx');
/*final _NtOpenFile = ntdll.lookupFunction<
    Uint32 Function(Pointer<IntPtr> lpHandle, Uint32 desiredAccess, Pointer<OBJECT_ATTRIBUTES> obj_attr, Pointer<_IO_STATUS_BLOCK> ioStatusBlock, Uint32 shareAccess, Uint32 openOptions), 
    int Function(Pointer<IntPtr> lpHandle, int desiredAccess, Pointer<OBJECT_ATTRIBUTES> obj_attr, Pointer<_IO_STATUS_BLOCK> ioStatusBlock, int shareAccess, int openOptions)>('NtOpenFile');*/
final _NtOpenSection = ntdll.lookupFunction<
    Uint32 Function(Pointer<IntPtr> lpHandle, Uint32 desiredAccess, Pointer<OBJECT_ATTRIBUTES> obj_attr), 
    int Function(Pointer<IntPtr> lpHandle, int desiredAccess, Pointer<OBJECT_ATTRIBUTES> obj_attr)>('NtOpenSection');

/*final _DefineDosDevice = kernel32.lookupFunction<
    Uint32 Function(Uint32 dwFlags, Pointer<Utf16> lpDeviceName, Pointer<Utf16> lpTargetPath),
    int Function(int dwFlags, Pointer<Utf16> lpDeviceName, Pointer<Utf16> lpTargetPath)>('DefineDosDeviceW');*/

/*final _GetSessionID = kernel32.lookupFunction<
    Uint32 Function(),
    int Function()>('WTSGetActiveConsoleSessionId');*/
final _ProcessIdToSessionId = kernel32.lookupFunction<
    Uint32 Function(Uint32 pid, Pointer<Uint32> lpSessionId),
    int Function(int pid, Pointer<Uint32> lpSessionId)>('ProcessIdToSessionId');

final _LookupPrivilegeValue = advapi32.lookupFunction<
    Uint32 Function(LPWSTR lpSystemName, LPWSTR lpName, Pointer<LUID> lpLuid),
    int Function(LPWSTR lpSystemName, LPWSTR lpName, Pointer<LUID> lpLuid)>('LookupPrivilegeValueW');
final _AdjustTokenPrivileges = advapi32.lookupFunction<
    Uint32 Function(HANDLE tokenHandle, BOOL disableAllPrivileges, Pointer<_TOKEN_PRIVILEGES> newState, DWORD bufferLength, Pointer<_TOKEN_PRIVILEGES> previousState, Pointer<DWORD> returnLength),
    int Function(int tokenHandle, int disableAllPrivileges, Pointer<_TOKEN_PRIVILEGES> newState, int bufferLength, Pointer<_TOKEN_PRIVILEGES> previousState, Pointer<DWORD> returnLength)>('AdjustTokenPrivileges');

extension on LPWSTR {
  Pointer<UNICODE_STRING> toUnicodeString([int? knownLength]) {
    final lpUnicodeString = malloc<UNICODE_STRING>();
    final unicodeString = lpUnicodeString.ref;
    unicodeString.buffer = this;
    unicodeString.length = (knownLength ?? length) * 2; // Expressed in bytes
    unicodeString.maximumLength = unicodeString.length + 2;
    return lpUnicodeString;
  }
}

extension WinDir on Directory {
  int? toNativeDir() {
    final lpPath = absolute.path.toNativeUtf16();
    HANDLE hToken;

    try {
      final handle = CreateFile(lpPath, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, 
          nullptr, OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, NULL);
      return handle != INVALID_HANDLE_VALUE ? handle : null;
    }
    finally {
      free(lpPath);
    }
  }
}

extension on String {
  static const _IO_REPARSE_TAG_MOUNT_POINT = 0xA0000003;
  
  Pointer<UNICODE_STRING> toUnicodeString({Allocator allocator = malloc}) {
    final units = codeUnits;
    final Pointer<Uint16> result = allocator<Uint16>(units.length + 1);
    final Uint16List nativeString = result.asTypedList(units.length + 1);
    nativeString.setRange(0, units.length, units);
    nativeString[units.length] = 0;
    return result.cast<Utf16>().toUnicodeString(units.length);
  }
  
  Pointer<REPARSE_MOUNTPOINT_DATA_BUFFER> toReparseMountpoint() {
    final rTargetUnits = codeUnits;
    final lpReparseBuffer = calloc.allocate<REPARSE_MOUNTPOINT_DATA_BUFFER>(sizeOf<REPARSE_MOUNTPOINT_DATA_BUFFER>() + (rTargetUnits.length + 1) * sizeOf<WCHAR>());
    final reparseBuffer = lpReparseBuffer.ref;

    final Pointer<Uint16> lpTarget = lpReparseBuffer.cast<BYTE>().elementAt(2 * sizeOf<DWORD>() + 4 * sizeOf<WORD>()).cast<Uint16>();
    final Uint16List nativeString = lpTarget.asTypedList(rTargetUnits.length + 1);
    nativeString.setRange(0, rTargetUnits.length, rTargetUnits);
    nativeString[rTargetUnits.length] = 0;
    
    reparseBuffer.reparseTag = _IO_REPARSE_TAG_MOUNT_POINT;
    reparseBuffer.reparseTargetMaximumLength = (rTargetUnits.length + 1) * sizeOf<WCHAR>();
    reparseBuffer.reparseTargetLength = rTargetUnits.length * sizeOf<WCHAR>();
    reparseBuffer.reparseDataLength = reparseBuffer.reparseTargetLength + 12;
    return lpReparseBuffer;
  }
}

extension DOSUnicodeStringPtrUtils on Pointer<UNICODE_STRING> {
  void free() {
    ref.free();
    calloc.free(this);
  }
}

class NtIO {
  static const _REPARSE_MOUNTPOINT_HEADER_SIZE = 8;

  static const DDD_NO_BROADCAST_SYSTEM = 0x00000008;
  static const DDD_RAW_TARGET_PATH = 0x00000001;
  static const DDD_REMOVE_DEFINITION = 0x00000002;
  static const DIRECTORY_ALL_ACCESS = STANDARD_RIGHTS_REQUIRED | 0xF;
  static const OBJ_CASE_INSENSITIVE = 0x00000040;
  static const SYMBOLIC_LINK_ALL_ACCESS = STANDARD_RIGHTS_REQUIRED | 0x1;

  static late final NT_TEMP_DIR_NAME = Directory(WinPath.tempSubdir).createTempSync("WSA-PacMan-DOS@$pid@").basename;
  static late final String? _DOS_DIRECTORY = (){
    String dirName = "\\BaseNamedObjects\\$NT_TEMP_DIR_NAME";
    return createNativeDirectory(dirName) != null ? dirName : null;
  }();
  
  static const _SE_PRIVILEGE_ENABLED = 0x00000002;
  static late final _SE_RESTORE_NAME = TEXT("SeRestorePrivilege");
  static late final _SE_BACKUP_NAME = TEXT("SeBackupPrivilege");

  static late final int? _NT_JUNCTION_HANDLE = (_DOS_DIRECTORY != null) ? createJunction(_DOS_DIRECTORY!, "${WinPath.tempSubdir}\\$NT_TEMP_DIR_NAME", true) : null;

  static int? _SESSION_ID;
  static late final int? SESSION_ID = () {
    if (_SESSION_ID == null) {
      Pointer<Uint32> lpSID  = malloc<Uint32>();
      try {
        lpSID = malloc<Uint32>();
        int result = _ProcessIdToSessionId(pid, lpSID);
        return result != 0 ? (_SESSION_ID = lpSID.value) : null;
      } finally {
        free(lpSID);
      }
    } else return _SESSION_ID;
  }();

  /// Creates a temporary shortcut inside the object manager and links it inside %TEMP%
  /// Returns the relative path starting from WinPath.tempSubdir to access it
  static String? createTempShortcut(String target, String shortcutName) {
    String? directory = _DOS_DIRECTORY;
    if (directory != null) {
      NtIO.createNativeSymlink(0, "\\??\\$target", "$_DOS_DIRECTORY\\$shortcutName");
      _NT_JUNCTION_HANDLE;
      return "$NT_TEMP_DIR_NAME\\$shortcutName";
    }
  }

  /// Deletes the junction to the NT directory
  static void deleteNtTempDirJunction() => (_NT_JUNCTION_HANDLE != null) ? CloseHandle(_NT_JUNCTION_HANDLE!) != 0 : false;
  

  /// Opens a directory, returns its handle
  static int? openDirectory(String path, bool bReadWrite, [bool deleteOnClose = false]) {
    final lpToken = malloc<HANDLE>();
    final pszPath = path.toNativeUtf16();
    final lpTp = malloc<_TOKEN_PRIVILEGES>();
    final tp = lpTp.ref;
    
    try {
      OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, lpToken);
      _LookupPrivilegeValue(nullptr, bReadWrite ? _SE_RESTORE_NAME : _SE_BACKUP_NAME, lpTp.cast<DWORD>().elementAt(1).cast<LUID>());
      tp.privilegeCount = 1;
      tp.privileges[0].attributes = _SE_PRIVILEGE_ENABLED;
      final hToken = lpToken.value;
      _AdjustTokenPrivileges(hToken, FALSE, lpTp, sizeOf<_TOKEN_PRIVILEGES>(), nullptr, nullptr);
      CloseHandle(hToken);

      // Open the directory
      int dwAccess = bReadWrite ? (GENERIC_READ | GENERIC_WRITE) : GENERIC_READ;
      int hDir = CreateFile(pszPath, dwAccess, 0, nullptr, OPEN_EXISTING, FILE_FLAG_OPEN_REPARSE_POINT | FILE_FLAG_BACKUP_SEMANTICS | (deleteOnClose ? FILE_FLAG_DELETE_ON_CLOSE : 0), 0);
      return hDir != INVALID_HANDLE_VALUE ? hDir : null;
    }
    finally {
      free(lpToken);
      free(pszPath);
      free(lpTp);
    }
  }

  /// Creates a junction of the target directory using the symlink directory and returns the handle
  /// The symlink directory must be empty
  /// TODO parse targetDir and append "\??\" if necessary?
  static int? createJunction(String targetDir, String symlinkDir, [bool deleteOnClose = true]) {
    final lpReparseBuffer = targetDir.toReparseMountpoint();
    int? dirHandle = openDirectory(symlinkDir, true, deleteOnClose);
    final lpBytesReturned = malloc<Uint32>();
    try {
      int result = dirHandle != null ? DeviceIoControl(dirHandle, FSCTL_SET_REPARSE_POINT, lpReparseBuffer,
            lpReparseBuffer.ref.reparseDataLength + _REPARSE_MOUNTPOINT_HEADER_SIZE, nullptr, 0, lpBytesReturned, nullptr) : 0;
      if (result == 0) log("\x1B[91mJunction point creation failed: ${getMessageDOS(GetLastError())}");
      if (result == 0 && dirHandle != null && deleteOnClose) CloseHandle(dirHandle);
      return result != 0 ? dirHandle : null;
    }
    finally {
      free(lpReparseBuffer);
      free(lpBytesReturned);
      //if (dirHandle != null) CloseHandle(dirHandle);
    }
  }

  /// Like createJunction, but returns a boolean (created) and is always permanent
  static bool createJunctionPerm(String targetDir, String symlinkDir) {
    int? handle = createJunction(targetDir, symlinkDir, false);
    if (handle != null) CloseHandle(handle);
    return handle != null;
  }

  static Pointer<OBJECT_ATTRIBUTES> _InitializeObjectAttributes(Pointer<UNICODE_STRING> name, int flags, int rootDirHandle, Pointer<SECURITY_DESCRIPTOR> securityDescriptor) {
    final lpAttributes = malloc<OBJECT_ATTRIBUTES>();
    final attributes = lpAttributes.ref;
    attributes.length = sizeOf<OBJECT_ATTRIBUTES>();
    attributes.objectName = name;
    attributes.attributes = flags;
    attributes.rootDirectory = rootDirHandle;
    attributes.securityDescriptor = securityDescriptor;
    attributes.securityQualityOfService = nullptr;
    return lpAttributes;
  }

  /*static void defineDosDevice() {
    log("DIRNAME: \\${NT_TEMP_DIR_NAME}");
    log("${_CreateDirectoryObject}");
    final lpTargetPath = "Global\\GLOBALROOT\\$NT_TEMP_DIR_NAME".toNativeUtf16();
    final lpDeviceName = r"C:\Users\Alex\Downloads\lolktestk".toNativeUtf16();
    int dosDevice = _DefineDosDevice(DDD_NO_BROADCAST_SYSTEM | DDD_RAW_TARGET_PATH, lpDeviceName, lpTargetPath);
    log("DOS_CREATE: ${dosDevice}");
  }*/

  /// Converts NT status code to an error message
  static String getMessageNt(int code) => getMessageDOS(_NtStatusToDosError(code));
  /// Converts DOS code to an error message
  static String getMessageDOS(int code) {
    const _FORMAT_MESSAGE_ALLOCATE_BUFFER = 0x00000100;
    const LANGID_EN = 0x0409;
    final lpLpBuffer = calloc<Pointer<Utf16>>();
    try {
      int result = FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_ARGUMENT_ARRAY | _FORMAT_MESSAGE_ALLOCATE_BUFFER, nullptr, code, LANGID_EN, lpLpBuffer.cast(), 1024, nullptr);
      return result != ERROR_MORE_DATA ? result != 0 ? lpLpBuffer.value.toDartString().replaceFirst(RegExp(r'\.?[\n\s]*$'), '') : "Unknown error" : "Error message too long";
    }
    finally {
      free(lpLpBuffer.value);
      free(lpLpBuffer);
    }
  }

  /// Creates a directory inside the object manager
  static int? createNativeDirectory(String nativePath) {
    final objectName = nativePath.toUnicodeString();
    final objAttrs = _InitializeObjectAttributes(objectName, OBJ_CASE_INSENSITIVE, 0, nullptr);
    final lpHandle = calloc<IntPtr>();
    try {
      int result = _CreateDirectoryObject(lpHandle, DIRECTORY_ALL_ACCESS, objAttrs, 0, 0);
      if (result != 0) log("\x1B[91mNative directory cration failed: ${getMessageNt(result)}", level: 1000);
      else return lpHandle.value;
    }
    finally {
      objectName.free();
      free(objAttrs);
      free(lpHandle);
    }
  }

  /// Creates a directory inside the object manager
  static bool openSection(String nativePath, [bool logErrors = true]) {
    final objectName = nativePath.toUnicodeString();
    final objAttrs = _InitializeObjectAttributes(objectName, OBJ_CASE_INSENSITIVE, 0, nullptr);
    final lpHandle = calloc<IntPtr>();
    try {
      int result = _NtOpenSection(lpHandle, GENERIC_READ, objAttrs);
      if (result != 0) {
        if (logErrors) log("\x1B[91mFailed to open section in object manager: ${getMessageNt(result)}", level: 1000);
        return false;
      }
      else {
        CloseHandle(lpHandle.value);
        return true;
      }
    }
    finally {
      objectName.free();
      free(objAttrs);
      free(lpHandle);
    }
  }


  /// Creates a directory inside the object manager
  /*static int? openNativeObject(String nativePath) {
    final objectName = nativePath.toUnicodeString();
    final objAttrs = _InitializeObjectAttributes(objectName, OBJ_CASE_INSENSITIVE, 0, nullptr);
    final lpHandle = calloc<IntPtr>();
    final lpStatusBlock = calloc<_IO_STATUS_BLOCK>();
    try {
      //int result = _CreateDirectoryObject(lpHandle, DIRECTORY_ALL_ACCESS, objAttrs, 0, 0);
      int result = _NtOpenFile(lpHandle, FILE_READ_ATTRIBUTES | SYNCHRONIZE, objAttrs, lpStatusBlock, 0x00000007 /*FILE_SHARE_READ*/, 0x00200000 | 0x00000020 | 0x00004000/*0x00000040 | 0x00004000*/);
      log("OPENED OBJECT: $result");
      if (result != 0) log("\x1B[91mNative directory cration failed: ${getMessageNt(result)}", level: 1000);
      else return lpHandle.value;
    }
    finally {
      objectName.free();
      free(objAttrs);
      free(lpHandle);
      free(lpStatusBlock);
    }
  }*/

  /// Creates a shortcut inside the object manager
  static int? createNativeSymlink(int rootDirHandle, String target, String symlink) {
    final lpTarget = target.toUnicodeString();
    final lpSymlink = symlink.toUnicodeString();
    final attributes = _InitializeObjectAttributes(lpSymlink, OBJ_CASE_INSENSITIVE, rootDirHandle, nullptr);
    final lpHandle = calloc<IntPtr>();
    try {
      int result = _NtCreateSymbolicLinkObject(lpHandle, SYMBOLIC_LINK_ALL_ACCESS, attributes, lpTarget);
      if (result != 0) log("\x1B[91mNative symlink creation failed: ${getMessageNt(result)}", level: 1000);
      else return lpHandle.value;
    }
    finally {
      lpTarget.free();
      lpSymlink.free();
      free(attributes);
      free(lpHandle);
    }
  }
}