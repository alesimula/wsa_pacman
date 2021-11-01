///
//  Generated code. Do not modify.
//  source: options.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class Options_Theme extends $pb.ProtobufEnum {
  static const Options_Theme SYSTEM = Options_Theme._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SYSTEM');
  static const Options_Theme LIGHT = Options_Theme._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'LIGHT');
  static const Options_Theme DARK = Options_Theme._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'DARK');

  static const $core.List<Options_Theme> values = <Options_Theme> [
    SYSTEM,
    LIGHT,
    DARK,
  ];

  static final $core.Map<$core.int, Options_Theme> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Options_Theme? valueOf($core.int value) => _byValue[value];

  const Options_Theme._($core.int v, $core.String n) : super(v, n);
}

