import 'package:fluent_ui/fluent_ui.dart';
import 'package:wsa_pacman/utils/misc_utils.dart';

class FluentCard extends StatefulWidget {
  /// Creates an expander
  const FluentCard({
    Key? key,
    this.leading,
    required this.content,
    this.icon,
    this.trailing,
    this.animationCurve,
    this.animationDuration,
    this.onPressed,
    this.onStateChanged,
    this.isButton = false,
    this.isInner = false,
    this.headerHeight = 68.5,
    this.headerBackgroundColor,
    this.contentBackgroundColor,
  }) : super(key: key);

  static Color backgroundColor(ThemeData style, Set<ButtonStates> states, [bool isClickable = true]) {
    if (style.brightness == Brightness.light) {
      if (!states.isDisabled && isClickable) {
        if (states.isPressing) return const ColorConst.withOpacity(0xf9f9f9, 0.2);
        if (states.isHovering) return const ColorConst.withOpacity(0xf9f9f9, 0.4);
      }
      return const ColorConst.withOpacity(0xFFFFFF, 0.7);
    } else {
      if (!states.isDisabled && isClickable) {
        if (states.isPressing) return const ColorConst.withOpacity(0xFFFFFF, 0.03);
        if (states.isHovering) return const ColorConst.withOpacity(0xFFFFFF, 0.082);
      }
      return const ColorConst.withOpacity(0xFFFFFF, 0.05);
    }
  }

  static Color borderColor(ThemeData style, Set<ButtonStates> states, [bool isInner = false, bool isClickable = true]) {
    if (style.brightness == Brightness.light) {
      if (isClickable && states.isHovering && !states.isPressing) return const Color(0xFF212121).withOpacity(0.22);
      return const Color(0xFF212121).withOpacity(isInner ? 0.25 : 0.17);
    } else {
      if (isClickable && states.isPressing) return Colors.white.withOpacity(0.062);
      if (isClickable && states.isHovering) return Colors.white.withOpacity(0.02);
      return isInner ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.52);
    }
  }

  /// The leading widget.
  ///
  /// See also:
  ///
  ///  * [Icon]
  ///  * [RadioButton]
  ///  * [Checkbox]
  final Widget? leading;

  /// The card content
  ///
  /// Usually a [Text]
  final Widget content;

  /// The icon of the toggle button.
  final Widget? icon;

  /// Disable when onPressed is null, always show chevron icon in the right
  final bool isButton;

  /// Enable when the card should be viewed inside another card; changes border colors
  final bool isInner;

  /// The trailing widget. It's positioned at the right of [content]
  /// and at the left of [icon].
  ///
  /// See also:
  ///
  ///  * [ToggleSwitch]
  final Widget? trailing;

  /// Makes the card clickable
  /// is null by default
  final VoidCallback? onPressed;

  /// The expand-collapse animation duration. If null, defaults to
  /// [FluentTheme.fastAnimationDuration]
  final Duration? animationDuration;

  /// The expand-collapse animation curve. If null, defaults to
  /// [FluentTheme.animationCurve]
  final Curve? animationCurve;

  /// A callback called when the current state is changed. `true` when
  /// open and `false` when closed.
  final ValueChanged<bool>? onStateChanged;

  /// The height of the header.
  /// 
  /// Defaults to 48.0
  final double headerHeight;

  /// The background color of the header. If null, [ThemeData.scaffoldBackgroundColor]
  /// is used
  final Color? headerBackgroundColor;
  
  /// The content color of the header. If null, [ThemeData.acrylicBackgroundColor]
  /// is used
  final Color? contentBackgroundColor;

  @override
  FluentCardState createState() => FluentCardState();
}

class FluentCardState extends State<FluentCard>
    with SingleTickerProviderStateMixin {
  late ThemeData theme;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration ?? const Duration(milliseconds: 150),
    );
  }

  static void emptyPressMethod() {}
  static const double borderSize = 0.5;
  static final Color darkBorderColor = Colors.black.withOpacity(0.8);

  static const Duration expanderAnimationDuration = Duration(milliseconds: 70);

  /// If this widget acts as a button and is disabled, gray out all text and icons
  Widget buttonStyled(Widget child) => !widget.isButton || widget.onPressed != null ? child : IconTheme.merge(
    data: IconThemeData(color: theme.disabledColor), 
    child: DefaultTextStyle.merge(style: TextStyle(color: theme.disabledColor), child: child)
  );

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    theme = FluentTheme.of(context);
    bool isDark = theme.brightness == Brightness.dark;

    return buttonStyled(HoverButton(
      onPressed: widget.onPressed ?? (widget.isButton ? null : emptyPressMethod),
      builder: (context, states) {
        return AnimatedContainer(
          duration: expanderAnimationDuration,
          height: widget.headerHeight,
          decoration: BoxDecoration(
            color: FluentCard.backgroundColor(theme, states, widget.onPressed != null),
            border: Border.all(
              width: borderSize,
              color: FluentCard.borderColor(theme, states, widget.isInner, widget.onPressed != null),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          ),
          padding: const EdgeInsetsDirectional.only(start: 16.0),
          alignment: Alignment.centerLeft,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (widget.leading != null) Padding(
              padding: const EdgeInsetsDirectional.only(end: 17.0),
              child: widget.leading!,
            ),
            Expanded(child: (widget.trailing == null && !widget.isButton) ? Padding(
              padding: const EdgeInsetsDirectional.only(end: 17),
              child: widget.content,
            ): widget.content),
            if (widget.trailing != null) Padding(
              padding: const EdgeInsetsDirectional.only(start: 20.0, end: 13.5),
              child: widget.trailing!,
            ),
            if (widget.icon != null || widget.isButton) Container(
              margin: EdgeInsetsDirectional.only(
                start: widget.trailing != null ? 8.0 : 20.0,
                end: 8.0,
                top: 8.0,
                bottom: 8.0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              alignment: Alignment.center,
              child: widget.icon ?? Icon(isLtr ? isDark ? FluentIcons.chevron_right : FluentIcons.chevron_right_med :
                  isDark ? FluentIcons.chevron_left : FluentIcons.chevron_left_med, size: 11),
            ),
          ]),
        );
      },
    ));
  }
}
