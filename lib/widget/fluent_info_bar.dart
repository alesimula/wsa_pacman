import 'dart:ui';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class FluentInfoBar extends StatelessWidget {
  /// Creates an info bar.
  const FluentInfoBar({
    Key? key,
    required this.title,
    this.content,
    this.action,
    this.severity = InfoBarSeverity.info,
    this.style,
    this.isLong = false,
    this.onClose,
  }) : super(key: key);

  /// The severity of this InfoBar. Defaults to [InfoBarSeverity.info]
  final InfoBarSeverity severity;

  /// The style applied to this info bar. If non-null, it's
  /// mescled with [ThemeData.infoBarThemeData]
  final InfoBarThemeData? style;

  final Widget title;
  final Widget? content;
  final Widget? action;

  /// Called when the close button is pressed. If this is null,
  /// there will be no close button
  final void Function()? onClose;

  /// If `true`, the info bar will be treated as long.
  ///
  /// ![Long InfoBar](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/infobar-success-content-wrapping.png)
  final bool isLong;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('long', value: isLong, ifFalse: 'short'))
      ..add(EnumProperty('severity', severity))
      ..add(ObjectFlagProperty.has('onClose', onClose))
      ..add(DiagnosticsProperty('style', style, ifNull: 'no style'));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));
    final localizations = FluentLocalizations.of(context);
    final style = InfoBarTheme.of(context).merge(this.style);
    final icon = style.icon?.call(severity);
    final closeIcon = style.closeIcon;
    final title = DefaultTextStyle(
      style: FluentTheme.of(context).typography.bodyStrong ?? const TextStyle(),
      child: this.title,
    );
    final content = () {
      if (this.content == null) return null;
      return DefaultTextStyle(
        style: FluentTheme.of(context).typography.body ?? const TextStyle(),
        child: this.content!,
        softWrap: true,
      );
    }();
    final action = () {
      if (this.action == null) return null;
      return ButtonTheme.merge(
        child: this.action!,
        data: ButtonThemeData.all(style.actionStyle),
      );
    }();
    return Container(
      decoration: style.decoration?.call(severity),
      padding: style.padding ?? const EdgeInsets.all(10),
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isLong ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 6.0),
              child: Icon(icon, color: style.iconColor?.call(severity)),
            ),
          if (isLong)
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (content != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: content,
                    ),
                  if (action != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: action,
                    ),
                ],
              ),
            )
          else
            Flexible(
              fit: FlexFit.loose,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  title,
                  if (content != null) content,
                  if (action != null) action,
                ],
              ),
            ),
          if (closeIcon != null && onClose != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 10.0),
              child: Tooltip(
                message: localizations.closeButtonLabel,
                child: IconButton(
                  icon: Icon(closeIcon, size: style.closeIconSize),
                  onPressed: onClose,
                  style: style.closeButtonStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}