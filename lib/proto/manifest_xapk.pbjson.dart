///
//  Generated code. Do not modify.
//  source: manifest_xapk.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use manifestXapkDescriptor instead')
const ManifestXapk$json = const {
  '1': 'ManifestXapk',
  '2': const [
    const {'1': 'xapk_version', '3': 1, '4': 1, '5': 13, '7': '1', '10': 'xapkVersion'},
    const {'1': 'package_name', '3': 2, '4': 1, '5': 9, '10': 'packageName'},
    const {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'locales_name', '3': 4, '4': 3, '5': 11, '6': '.proto.ManifestXapk.LocalesNameEntry', '10': 'localesName'},
    const {'1': 'version_code', '3': 5, '4': 1, '5': 13, '10': 'versionCode'},
    const {'1': 'version_name', '3': 6, '4': 1, '5': 9, '10': 'versionName'},
    const {'1': 'min_sdk_version', '3': 7, '4': 1, '5': 13, '10': 'minSdkVersion'},
    const {'1': 'target_sdk_version', '3': 8, '4': 1, '5': 13, '10': 'targetSdkVersion'},
    const {'1': 'permissions', '3': 9, '4': 3, '5': 9, '10': 'permissions'},
    const {'1': 'split_configs', '3': 10, '4': 3, '5': 9, '10': 'splitConfigs'},
    const {'1': 'total_size', '3': 11, '4': 1, '5': 13, '10': 'totalSize'},
    const {'1': 'icon', '3': 12, '4': 1, '5': 9, '10': 'icon'},
    const {'1': 'split_apks', '3': 13, '4': 3, '5': 11, '6': '.proto.ManifestXapk.ApkFile', '10': 'splitApks'},
    const {'1': 'expansions', '3': 14, '4': 3, '5': 11, '6': '.proto.ManifestXapk.ApkExpansion', '10': 'expansions'},
  ],
  '3': const [ManifestXapk_LocalesNameEntry$json, ManifestXapk_ApkFile$json, ManifestXapk_ApkExpansion$json],
  '4': const [ManifestXapk_InstallDir$json],
};

@$core.Deprecated('Use manifestXapkDescriptor instead')
const ManifestXapk_LocalesNameEntry$json = const {
  '1': 'LocalesNameEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use manifestXapkDescriptor instead')
const ManifestXapk_ApkFile$json = const {
  '1': 'ApkFile',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'file', '3': 2, '4': 1, '5': 9, '10': 'file'},
  ],
};

@$core.Deprecated('Use manifestXapkDescriptor instead')
const ManifestXapk_ApkExpansion$json = const {
  '1': 'ApkExpansion',
  '2': const [
    const {'1': 'install_location', '3': 1, '4': 1, '5': 14, '6': '.proto.ManifestXapk.InstallDir', '10': 'installLocation'},
    const {'1': 'file', '3': 2, '4': 1, '5': 9, '10': 'file'},
    const {'1': 'install_path', '3': 3, '4': 1, '5': 9, '10': 'installPath'},
  ],
};

@$core.Deprecated('Use manifestXapkDescriptor instead')
const ManifestXapk_InstallDir$json = const {
  '1': 'InstallDir',
  '2': const [
    const {'1': 'EXTERNAL_STORAGE', '2': 0},
    const {'1': 'INTERNAL_STORAGE', '2': 1},
  ],
};

/// Descriptor for `ManifestXapk`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List manifestXapkDescriptor = $convert.base64Decode('CgxNYW5pZmVzdFhhcGsSJAoMeGFwa192ZXJzaW9uGAEgASgNOgExUgt4YXBrVmVyc2lvbhIhCgxwYWNrYWdlX25hbWUYAiABKAlSC3BhY2thZ2VOYW1lEhIKBG5hbWUYAyABKAlSBG5hbWUSRwoMbG9jYWxlc19uYW1lGAQgAygLMiQucHJvdG8uTWFuaWZlc3RYYXBrLkxvY2FsZXNOYW1lRW50cnlSC2xvY2FsZXNOYW1lEiEKDHZlcnNpb25fY29kZRgFIAEoDVILdmVyc2lvbkNvZGUSIQoMdmVyc2lvbl9uYW1lGAYgASgJUgt2ZXJzaW9uTmFtZRImCg9taW5fc2RrX3ZlcnNpb24YByABKA1SDW1pblNka1ZlcnNpb24SLAoSdGFyZ2V0X3Nka192ZXJzaW9uGAggASgNUhB0YXJnZXRTZGtWZXJzaW9uEiAKC3Blcm1pc3Npb25zGAkgAygJUgtwZXJtaXNzaW9ucxIjCg1zcGxpdF9jb25maWdzGAogAygJUgxzcGxpdENvbmZpZ3MSHQoKdG90YWxfc2l6ZRgLIAEoDVIJdG90YWxTaXplEhIKBGljb24YDCABKAlSBGljb24SOgoKc3BsaXRfYXBrcxgNIAMoCzIbLnByb3RvLk1hbmlmZXN0WGFway5BcGtGaWxlUglzcGxpdEFwa3MSQAoKZXhwYW5zaW9ucxgOIAMoCzIgLnByb3RvLk1hbmlmZXN0WGFway5BcGtFeHBhbnNpb25SCmV4cGFuc2lvbnMaPgoQTG9jYWxlc05hbWVFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgBGi0KB0Fwa0ZpbGUSDgoCaWQYASABKAlSAmlkEhIKBGZpbGUYAiABKAlSBGZpbGUakAEKDEFwa0V4cGFuc2lvbhJJChBpbnN0YWxsX2xvY2F0aW9uGAEgASgOMh4ucHJvdG8uTWFuaWZlc3RYYXBrLkluc3RhbGxEaXJSD2luc3RhbGxMb2NhdGlvbhISCgRmaWxlGAIgASgJUgRmaWxlEiEKDGluc3RhbGxfcGF0aBgDIAEoCVILaW5zdGFsbFBhdGgiOAoKSW5zdGFsbERpchIUChBFWFRFUk5BTF9TVE9SQUdFEAASFAoQSU5URVJOQUxfU1RPUkFHRRAB');
