// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'dart:typed_data';

extension IntUtils on int {
  static const int LOCALHOST = 2130706433;

  String get asIpv4 => InternetAddress.fromRawAddress(Uint8List(4)..buffer.asByteData().setInt32(0, this)).address;
}