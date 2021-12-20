import 'package:win32/win32.dart';
import 'package:wsa_pacman/windows/win_io.dart';

class WSAStatus {
  static late final _WSA_CLIENT_MUTEX = TEXT(r"{42CEB0DF-325A-4FBE-BBB6-C259A6C3F0BB}");

  static bool get isBooted => WinIO.findMutexWstr(_WSA_CLIENT_MUTEX);
}