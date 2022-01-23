// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Demonstrates usage of various shell APIs to retrieve known folder locations

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class WinPath {
  /// Get the path of the temporary directory (typically %TEMP%)
  static late String temp = Directory.systemTemp.absolute.path;

  /// Sub-directory inside %TEMP% to use by the application
  static late String tempSubdir = Directory.systemTemp.createTempSync("WSA-PacMan-").absolute.path;

  /// Get the desktop path
  static late String desktop = (){
    final appsFolder = GUIDFromString(FOLDERID_Desktop);
    final ppszPath = calloc<PWSTR>();

    try {
      final hr =
          SHGetKnownFolderPath(appsFolder, KF_FLAG_DEFAULT, NULL, ppszPath);

      if (FAILED(hr)) {
        throw WindowsException(hr);
      }

      final path = ppszPath.value.toDartString();
      return path;
    } finally {
      free(appsFolder);
      free(ppszPath);
    }
  }();
}
