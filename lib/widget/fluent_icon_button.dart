// ignore_for_file: constant_identifier_names

import 'package:fluent_ui/fluent_ui.dart';

enum IconButtonMode {
  TINY, SMALL, LARGE
}

class FluentIconButton extends BaseButton {
  const FluentIconButton({
    Key? key,
    required Widget icon,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    FocusNode? focusNode,
    bool autofocus = false,
    ButtonStyle? style,
    this.iconButtonMode,
  }) : super(
          key: key,
          child: icon,
          focusNode: focusNode,
          autofocus: autofocus,
          onLongPress: onLongPress,
          onPressed: onPressed,
          style: style,
        );

  final IconButtonMode? iconButtonMode;

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final isIconSmall = iconButtonMode == IconButtonMode.TINY;
    final isSmall = iconButtonMode != null ? iconButtonMode != IconButtonMode.LARGE : SmallIconButton.of(context) != null;
    return ButtonStyle(
      iconSize: ButtonState.all(isIconSmall ? 12.0 : null),
      padding: ButtonState.all(isSmall
          ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0)
          : const EdgeInsets.all(8.0)),
      backgroundColor: ButtonState.resolveWith((states) {
        return states.isDisabled
            ? ButtonThemeData.buttonColor(theme.brightness, states)
            : ButtonThemeData.uncheckedInputColor(theme, states);
      }),
      foregroundColor: ButtonState.resolveWith((states) {
        if (states.isDisabled) return theme.disabledColor;
      }),
      shape: ButtonState.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      )),
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ButtonTheme.of(context).iconButtonStyle;
  }
}