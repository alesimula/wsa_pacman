// ignore_for_file: non_constant_identifier_names

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:wsa_pacman/windows/nt_io.dart';
import 'package:wsa_pacman/windows/win_io.dart';
import 'package:wsa_pacman/windows/win_reg.dart';

class WSAStatus {
  static late final _WSA_CLIENT_MUTEX = TEXT(r"{42CEB0DF-325A-4FBE-BBB6-C259A6C3F0BB}");
  static LPWSTR REG_VOLATILE_STORE = "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\HostComputeService\\VolatileStore\\ComputeSystem\\".normalizedRegKey!.toNativeUtf16();
  static int? REG_VOLATILE_STORE_KEY;
  static String? WSA_VM_UUID;

  /// Checks if WSA is booted (With this status, it may still be in sleep mode)
  static bool get isBooted => WinIO.findMutexWstr(_WSA_CLIENT_MUTEX);

  /// Checks if WSA is running, if booted but not running, it's in sleep mode
  static bool get isRunning {
    REG_VOLATILE_STORE_KEY ??= WinReg.openKeyLp(RegHKey.HKEY_LOCAL_MACHINE, REG_VOLATILE_STORE);
    int? sessionId = NtIO.SESSION_ID;
    if (REG_VOLATILE_STORE_KEY == null || sessionId == null) return false;
    String? wsaVmUUID = WSA_VM_UUID;
    List<String> runningVMs = wsaVmUUID == null ? WinReg.listSubkeys(REG_VOLATILE_STORE_KEY!, 36) : [wsaVmUUID];
    for (String uuid in runningVMs) {
      bool isSubsystemVMRunning = NtIO.openSection("\\Sessions\\$sessionId\\BaseNamedObjects\\WSL\\$uuid\\latte\\gralloc_0", false);
      if (isSubsystemVMRunning) {
        WSA_VM_UUID = uuid;
        return true;
      }
    }
    WSA_VM_UUID = null;
    return false;
  }
}