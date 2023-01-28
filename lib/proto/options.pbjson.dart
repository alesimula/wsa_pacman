///
//  Generated code. Do not modify.
//  source: options.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use optionsDescriptor instead')
const Options$json = const {
  '1': 'Options',
  '2': const [
    const {'1': 'ipAddress', '3': 1, '4': 1, '5': 13, '7': '2130706433', '10': 'ipAddress'},
    const {'1': 'port', '3': 2, '4': 1, '5': 13, '7': '58526', '10': 'port'},
    const {'1': 'autostart', '3': 8, '4': 1, '5': 8, '10': 'autostart'},
    const {'1': 'timeout', '3': 10, '4': 1, '5': 13, '7': '30', '10': 'timeout'},
    const {'1': 'locale', '3': 9, '4': 1, '5': 13, '10': 'locale'},
    const {'1': 'theme', '3': 3, '4': 1, '5': 14, '6': '.proto.Options.Theme', '10': 'theme'},
    const {'1': 'legacyIcons', '3': 4, '4': 1, '5': 8, '10': 'legacyIcons'},
    const {'1': 'systemAccent', '3': 5, '4': 1, '5': 8, '10': 'systemAccent'},
    const {'1': 'iconShape', '3': 6, '4': 1, '5': 14, '6': '.proto.Options.IconShape', '10': 'iconShape'},
    const {'1': 'mica', '3': 7, '4': 1, '5': 14, '6': '.proto.Options.Mica', '7': 'FULL', '10': 'mica'},
  ],
  '4': const [Options_Theme$json, Options_IconShape$json, Options_Mica$json],
};

@$core.Deprecated('Use optionsDescriptor instead')
const Options_Theme$json = const {
  '1': 'Theme',
  '2': const [
    const {'1': 'SYSTEM', '2': 0},
    const {'1': 'LIGHT', '2': 1},
    const {'1': 'DARK', '2': 2},
  ],
};

@$core.Deprecated('Use optionsDescriptor instead')
const Options_IconShape$json = const {
  '1': 'IconShape',
  '2': const [
    const {'1': 'SQUIRCLE', '2': 0},
    const {'1': 'CIRCLE', '2': 1},
    const {'1': 'ROUNDED_SQUARE', '2': 2},
  ],
};

@$core.Deprecated('Use optionsDescriptor instead')
const Options_Mica$json = const {
  '1': 'Mica',
  '2': const [
    const {'1': 'FULL', '2': 0},
    const {'1': 'PARTIAL', '2': 1},
    const {'1': 'DISABLED', '2': 2},
  ],
};

/// Descriptor for `Options`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List optionsDescriptor = $convert.base64Decode('CgdPcHRpb25zEigKCWlwQWRkcmVzcxgBIAEoDToKMjEzMDcwNjQzM1IJaXBBZGRyZXNzEhkKBHBvcnQYAiABKA06BTU4NTI2UgRwb3J0EhwKCWF1dG9zdGFydBgIIAEoCFIJYXV0b3N0YXJ0EhwKB3RpbWVvdXQYCiABKA06AjMwUgd0aW1lb3V0EhYKBmxvY2FsZRgJIAEoDVIGbG9jYWxlEioKBXRoZW1lGAMgASgOMhQucHJvdG8uT3B0aW9ucy5UaGVtZVIFdGhlbWUSIAoLbGVnYWN5SWNvbnMYBCABKAhSC2xlZ2FjeUljb25zEiIKDHN5c3RlbUFjY2VudBgFIAEoCFIMc3lzdGVtQWNjZW50EjYKCWljb25TaGFwZRgGIAEoDjIYLnByb3RvLk9wdGlvbnMuSWNvblNoYXBlUglpY29uU2hhcGUSLQoEbWljYRgHIAEoDjITLnByb3RvLk9wdGlvbnMuTWljYToERlVMTFIEbWljYSIoCgVUaGVtZRIKCgZTWVNURU0QABIJCgVMSUdIVBABEggKBERBUksQAiI5CglJY29uU2hhcGUSDAoIU1FVSVJDTEUQABIKCgZDSVJDTEUQARISCg5ST1VOREVEX1NRVUFSRRACIisKBE1pY2ESCAoERlVMTBAAEgsKB1BBUlRJQUwQARIMCghESVNBQkxFRBAC');
