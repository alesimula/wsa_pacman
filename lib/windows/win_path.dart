// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Demonstrates usage of various shell APIs to retrieve known folder locations

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class WinPath {
  // Get the path of the temporary directory (typically %TEMP%)
  static late String temp = (){
    final buffer = wsalloc(MAX_PATH + 1);
    final length = GetTempPath(MAX_PATH, buffer);

    try {
      if (length == 0) {
        final error = GetLastError();
        throw WindowsException(error);
      } else {
        var path = buffer.toDartString();

        // GetTempPath adds a trailing backslash, but SHGetKnownFolderPath does not.
        // Strip off trailing backslash for consistency with other methods here.
        if (path.endsWith('\\')) {
          path = path.substring(0, path.length - 1);
        }
        return path;
      }
    } finally {
      free(buffer);
    }
  }();

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
