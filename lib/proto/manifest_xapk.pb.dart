///
//  Generated code. Do not modify.
//  source: manifest_xapk.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'manifest_xapk.pbenum.dart';

export 'manifest_xapk.pbenum.dart';

class ManifestXapk_ApkFile extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ManifestXapk.ApkFile', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'proto'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'file')
    ..hasRequiredFields = false
  ;

  ManifestXapk_ApkFile._() : super();
  factory ManifestXapk_ApkFile({
    $core.String? id,
    $core.String? file,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (file != null) {
      _result.file = file;
    }
    return _result;
  }
  factory ManifestXapk_ApkFile.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ManifestXapk_ApkFile.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ManifestXapk_ApkFile clone() => ManifestXapk_ApkFile()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ManifestXapk_ApkFile copyWith(void Function(ManifestXapk_ApkFile) updates) => super.copyWith((message) => updates(message as ManifestXapk_ApkFile)) as ManifestXapk_ApkFile; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ManifestXapk_ApkFile create() => ManifestXapk_ApkFile._();
  ManifestXapk_ApkFile createEmptyInstance() => create();
  static $pb.PbList<ManifestXapk_ApkFile> createRepeated() => $pb.PbList<ManifestXapk_ApkFile>();
  @$core.pragma('dart2js:noInline')
  static ManifestXapk_ApkFile getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ManifestXapk_ApkFile>(create);
  static ManifestXapk_ApkFile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get file => $_getSZ(1);
  @$pb.TagNumber(2)
  set file($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFile() => $_has(1);
  @$pb.TagNumber(2)
  void clearFile() => clearField(2);
}

class ManifestXapk_ApkExpansion extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ManifestXapk.ApkExpansion', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'proto'), createEmptyInstance: create)
    ..e<ManifestXapk_InstallDir>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'installLocation', $pb.PbFieldType.OE, defaultOrMaker: ManifestXapk_InstallDir.EXTERNAL_STORAGE, valueOf: ManifestXapk_InstallDir.valueOf, enumValues: ManifestXapk_InstallDir.values)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'file')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'installPath')
    ..hasRequiredFields = false
  ;

  ManifestXapk_ApkExpansion._() : super();
  factory ManifestXapk_ApkExpansion({
    ManifestXapk_InstallDir? installLocation,
    $core.String? file,
    $core.String? installPath,
  }) {
    final _result = create();
    if (installLocation != null) {
      _result.installLocation = installLocation;
    }
    if (file != null) {
      _result.file = file;
    }
    if (installPath != null) {
      _result.installPath = installPath;
    }
    return _result;
  }
  factory ManifestXapk_ApkExpansion.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ManifestXapk_ApkExpansion.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ManifestXapk_ApkExpansion clone() => ManifestXapk_ApkExpansion()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ManifestXapk_ApkExpansion copyWith(void Function(ManifestXapk_ApkExpansion) updates) => super.copyWith((message) => updates(message as ManifestXapk_ApkExpansion)) as ManifestXapk_ApkExpansion; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ManifestXapk_ApkExpansion create() => ManifestXapk_ApkExpansion._();
  ManifestXapk_ApkExpansion createEmptyInstance() => create();
  static $pb.PbList<ManifestXapk_ApkExpansion> createRepeated() => $pb.PbList<ManifestXapk_ApkExpansion>();
  @$core.pragma('dart2js:noInline')
  static ManifestXapk_ApkExpansion getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ManifestXapk_ApkExpansion>(create);
  static ManifestXapk_ApkExpansion? _defaultInstance;

  @$pb.TagNumber(1)
  ManifestXapk_InstallDir get installLocation => $_getN(0);
  @$pb.TagNumber(1)
  set installLocation(ManifestXapk_InstallDir v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasInstallLocation() => $_has(0);
  @$pb.TagNumber(1)
  void clearInstallLocation() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get file => $_getSZ(1);
  @$pb.TagNumber(2)
  set file($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFile() => $_has(1);
  @$pb.TagNumber(2)
  void clearFile() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get installPath => $_getSZ(2);
  @$pb.TagNumber(3)
  set installPath($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasInstallPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearInstallPath() => clearField(3);
}

class ManifestXapk extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ManifestXapk', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'proto'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'xapkVersion', $pb.PbFieldType.OU3, defaultOrMaker: 1)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'packageName')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..m<$core.String, $core.String>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'localesName', entryClassName: 'ManifestXapk.LocalesNameEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('proto'))
    ..a<$core.int>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'versionCode', $pb.PbFieldType.OU3)
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'versionName')
    ..a<$core.int>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'minSdkVersion', $pb.PbFieldType.OU3)
    ..a<$core.int>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'targetSdkVersion', $pb.PbFieldType.OU3)
    ..pPS(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'permissions')
    ..pPS(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'splitConfigs')
    ..a<$core.int>(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'totalSize', $pb.PbFieldType.OU3)
    ..aOS(12, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'icon')
    ..pc<ManifestXapk_ApkFile>(13, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'splitApks', $pb.PbFieldType.PM, subBuilder: ManifestXapk_ApkFile.create)
    ..pc<ManifestXapk_ApkExpansion>(14, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'expansions', $pb.PbFieldType.PM, subBuilder: ManifestXapk_ApkExpansion.create)
    ..hasRequiredFields = false
  ;

  ManifestXapk._() : super();
  factory ManifestXapk({
    $core.int? xapkVersion,
    $core.String? packageName,
    $core.String? name,
    $core.Map<$core.String, $core.String>? localesName,
    $core.int? versionCode,
    $core.String? versionName,
    $core.int? minSdkVersion,
    $core.int? targetSdkVersion,
    $core.Iterable<$core.String>? permissions,
    $core.Iterable<$core.String>? splitConfigs,
    $core.int? totalSize,
    $core.String? icon,
    $core.Iterable<ManifestXapk_ApkFile>? splitApks,
    $core.Iterable<ManifestXapk_ApkExpansion>? expansions,
  }) {
    final _result = create();
    if (xapkVersion != null) {
      _result.xapkVersion = xapkVersion;
    }
    if (packageName != null) {
      _result.packageName = packageName;
    }
    if (name != null) {
      _result.name = name;
    }
    if (localesName != null) {
      _result.localesName.addAll(localesName);
    }
    if (versionCode != null) {
      _result.versionCode = versionCode;
    }
    if (versionName != null) {
      _result.versionName = versionName;
    }
    if (minSdkVersion != null) {
      _result.minSdkVersion = minSdkVersion;
    }
    if (targetSdkVersion != null) {
      _result.targetSdkVersion = targetSdkVersion;
    }
    if (permissions != null) {
      _result.permissions.addAll(permissions);
    }
    if (splitConfigs != null) {
      _result.splitConfigs.addAll(splitConfigs);
    }
    if (totalSize != null) {
      _result.totalSize = totalSize;
    }
    if (icon != null) {
      _result.icon = icon;
    }
    if (splitApks != null) {
      _result.splitApks.addAll(splitApks);
    }
    if (expansions != null) {
      _result.expansions.addAll(expansions);
    }
    return _result;
  }
  factory ManifestXapk.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ManifestXapk.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ManifestXapk clone() => ManifestXapk()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ManifestXapk copyWith(void Function(ManifestXapk) updates) => super.copyWith((message) => updates(message as ManifestXapk)) as ManifestXapk; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ManifestXapk create() => ManifestXapk._();
  ManifestXapk createEmptyInstance() => create();
  static $pb.PbList<ManifestXapk> createRepeated() => $pb.PbList<ManifestXapk>();
  @$core.pragma('dart2js:noInline')
  static ManifestXapk getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ManifestXapk>(create);
  static ManifestXapk? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get xapkVersion => $_getI(0, 1);
  @$pb.TagNumber(1)
  set xapkVersion($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasXapkVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearXapkVersion() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get packageName => $_getSZ(1);
  @$pb.TagNumber(2)
  set packageName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPackageName() => $_has(1);
  @$pb.TagNumber(2)
  void clearPackageName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $core.Map<$core.String, $core.String> get localesName => $_getMap(3);

  @$pb.TagNumber(5)
  $core.int get versionCode => $_getIZ(4);
  @$pb.TagNumber(5)
  set versionCode($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasVersionCode() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersionCode() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get versionName => $_getSZ(5);
  @$pb.TagNumber(6)
  set versionName($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasVersionName() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersionName() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get minSdkVersion => $_getIZ(6);
  @$pb.TagNumber(7)
  set minSdkVersion($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMinSdkVersion() => $_has(6);
  @$pb.TagNumber(7)
  void clearMinSdkVersion() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get targetSdkVersion => $_getIZ(7);
  @$pb.TagNumber(8)
  set targetSdkVersion($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasTargetSdkVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearTargetSdkVersion() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<$core.String> get permissions => $_getList(8);

  @$pb.TagNumber(10)
  $core.List<$core.String> get splitConfigs => $_getList(9);

  @$pb.TagNumber(11)
  $core.int get totalSize => $_getIZ(10);
  @$pb.TagNumber(11)
  set totalSize($core.int v) { $_setUnsignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasTotalSize() => $_has(10);
  @$pb.TagNumber(11)
  void clearTotalSize() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get icon => $_getSZ(11);
  @$pb.TagNumber(12)
  set icon($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasIcon() => $_has(11);
  @$pb.TagNumber(12)
  void clearIcon() => clearField(12);

  @$pb.TagNumber(13)
  $core.List<ManifestXapk_ApkFile> get splitApks => $_getList(12);

  @$pb.TagNumber(14)
  $core.List<ManifestXapk_ApkExpansion> get expansions => $_getList(13);
}

