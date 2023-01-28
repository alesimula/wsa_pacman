///
//  Generated code. Do not modify.
//  source: options.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'options.pbenum.dart';

export 'options.pbenum.dart';

class Options extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Options', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'proto'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ipAddress', $pb.PbFieldType.OU3, protoName: 'ipAddress', defaultOrMaker: 2130706433)
    ..a<$core.int>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'port', $pb.PbFieldType.OU3, defaultOrMaker: 58526)
    ..e<Options_Theme>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'theme', $pb.PbFieldType.OE, defaultOrMaker: Options_Theme.SYSTEM, valueOf: Options_Theme.valueOf, enumValues: Options_Theme.values)
    ..aOB(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'legacyIcons', protoName: 'legacyIcons')
    ..aOB(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'systemAccent', protoName: 'systemAccent')
    ..e<Options_IconShape>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'iconShape', $pb.PbFieldType.OE, protoName: 'iconShape', defaultOrMaker: Options_IconShape.SQUIRCLE, valueOf: Options_IconShape.valueOf, enumValues: Options_IconShape.values)
    ..e<Options_Mica>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mica', $pb.PbFieldType.OE, defaultOrMaker: Options_Mica.FULL, valueOf: Options_Mica.valueOf, enumValues: Options_Mica.values)
    ..aOB(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'autostart')
    ..a<$core.int>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'locale', $pb.PbFieldType.OU3)
    ..a<$core.int>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'timeout', $pb.PbFieldType.OU3, defaultOrMaker: 30)
    ..hasRequiredFields = false
  ;

  Options._() : super();
  factory Options({
    $core.int? ipAddress,
    $core.int? port,
    Options_Theme? theme,
    $core.bool? legacyIcons,
    $core.bool? systemAccent,
    Options_IconShape? iconShape,
    Options_Mica? mica,
    $core.bool? autostart,
    $core.int? locale,
    $core.int? timeout,
  }) {
    final _result = create();
    if (ipAddress != null) {
      _result.ipAddress = ipAddress;
    }
    if (port != null) {
      _result.port = port;
    }
    if (theme != null) {
      _result.theme = theme;
    }
    if (legacyIcons != null) {
      _result.legacyIcons = legacyIcons;
    }
    if (systemAccent != null) {
      _result.systemAccent = systemAccent;
    }
    if (iconShape != null) {
      _result.iconShape = iconShape;
    }
    if (mica != null) {
      _result.mica = mica;
    }
    if (autostart != null) {
      _result.autostart = autostart;
    }
    if (locale != null) {
      _result.locale = locale;
    }
    if (timeout != null) {
      _result.timeout = timeout;
    }
    return _result;
  }
  factory Options.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Options.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Options clone() => Options()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Options copyWith(void Function(Options) updates) => super.copyWith((message) => updates(message as Options)) as Options; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Options create() => Options._();
  Options createEmptyInstance() => create();
  static $pb.PbList<Options> createRepeated() => $pb.PbList<Options>();
  @$core.pragma('dart2js:noInline')
  static Options getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Options>(create);
  static Options? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get ipAddress => $_getI(0, 2130706433);
  @$pb.TagNumber(1)
  set ipAddress($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIpAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearIpAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get port => $_getI(1, 58526);
  @$pb.TagNumber(2)
  set port($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPort() => $_has(1);
  @$pb.TagNumber(2)
  void clearPort() => clearField(2);

  @$pb.TagNumber(3)
  Options_Theme get theme => $_getN(2);
  @$pb.TagNumber(3)
  set theme(Options_Theme v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasTheme() => $_has(2);
  @$pb.TagNumber(3)
  void clearTheme() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get legacyIcons => $_getBF(3);
  @$pb.TagNumber(4)
  set legacyIcons($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLegacyIcons() => $_has(3);
  @$pb.TagNumber(4)
  void clearLegacyIcons() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get systemAccent => $_getBF(4);
  @$pb.TagNumber(5)
  set systemAccent($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSystemAccent() => $_has(4);
  @$pb.TagNumber(5)
  void clearSystemAccent() => clearField(5);

  @$pb.TagNumber(6)
  Options_IconShape get iconShape => $_getN(5);
  @$pb.TagNumber(6)
  set iconShape(Options_IconShape v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasIconShape() => $_has(5);
  @$pb.TagNumber(6)
  void clearIconShape() => clearField(6);

  @$pb.TagNumber(7)
  Options_Mica get mica => $_getN(6);
  @$pb.TagNumber(7)
  set mica(Options_Mica v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasMica() => $_has(6);
  @$pb.TagNumber(7)
  void clearMica() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get autostart => $_getBF(7);
  @$pb.TagNumber(8)
  set autostart($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasAutostart() => $_has(7);
  @$pb.TagNumber(8)
  void clearAutostart() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get locale => $_getIZ(8);
  @$pb.TagNumber(9)
  set locale($core.int v) { $_setUnsignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasLocale() => $_has(8);
  @$pb.TagNumber(9)
  void clearLocale() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get timeout => $_getI(9, 30);
  @$pb.TagNumber(10)
  set timeout($core.int v) { $_setUnsignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasTimeout() => $_has(9);
  @$pb.TagNumber(10)
  void clearTimeout() => clearField(10);
}

