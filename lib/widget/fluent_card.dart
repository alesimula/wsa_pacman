import 'package:fluent_ui/fluent_ui.dart';

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
    this.direction = ExpanderDirection.down,
    this.initiallyExpanded = false,
    this.onPressed,
    this.onStateChanged,
    this.headerHeight = 68.5,
    this.headerBackgroundColor,
    this.contentBackgroundColor,
  }) : super(key: key);

  static Color backgroundColor(ThemeData style, Set<ButtonStates> states, [bool isClickable = true]) {
    if (style.brightness == Brightness.light) {
      if (states.isDisabled) return style.disabledColor;
      if (isClickable && states.isPressing) return const Color(0xFFf9f9f9).withOpacity(0.2);
      if (isClickable && states.isHovering) return const Color(0xFFf9f9f9).withOpacity(0.4);
      return Colors.white.withOpacity(0.7);
    } else {
      if (states.isDisabled) return style.disabledColor;
      if (isClickable && states.isPressing) return Colors.white.withOpacity(0.03);
      if (isClickable && states.isHovering) return Colors.white.withOpacity(0.082);
      return Colors.white.withOpacity(0.05);
    }
  }

  static Color borderColor(ThemeData style, Set<ButtonStates> states, [bool isClickable = true]) {
    if (style.brightness == Brightness.light) {
      if (isClickable && states.isHovering && !states.isPressing) return const Color(0xFF212121).withOpacity(0.22);
      return const Color(0xFF212121).withOpacity(0.17);
    } else {
      if (isClickable && states.isPressing) return Colors.white.withOpacity(0.062);
      if (isClickable && states.isHovering) return Colors.white.withOpacity(0.02);
      return Colors.black.withOpacity(0.52);
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

  /// The expand direction. Defaults to [ExpanderDirection.down]
  final ExpanderDirection direction;

  /// Whether the [FluentCard] is initially expanded. Defaults to `false`
  final bool initiallyExpanded;

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

  late bool _open;
  bool get open => _open;
  set open(bool value) {
    if (_open != value) _handlePressed();
  }

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _open = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration ?? const Duration(milliseconds: 150),
    );
  }

  void _handlePressed() {
    if (open) {
      _controller.animateTo(
        0.0,
        duration: widget.animationDuration ?? theme.fastAnimationDuration,
        curve: widget.animationCurve ?? theme.animationCurve,
      );
      _open = false;
    } else {
      _controller.animateTo(
        1.0,
        duration: widget.animationDuration ?? theme.fastAnimationDuration,
        curve: widget.animationCurve ?? theme.animationCurve,
      );
      _open = true;
    }
    widget.onStateChanged?.call(open);
    if (mounted) setState(() {});
  }

  bool get _isDown => widget.direction == ExpanderDirection.down;

  static const double borderSize = 0.5;
  static final Color darkBorderColor = Colors.black.withOpacity(0.8);

  static const Duration expanderAnimationDuration = Duration(milliseconds: 70);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    theme = FluentTheme.of(context);
    bool isDark = theme.brightness == Brightness.dark;

    final children = [
      HoverButton(
        onPressed: _handlePressed,
        builder: (context, states) {
          return AnimatedContainer(
            duration: expanderAnimationDuration,
            height: widget.headerHeight,
            decoration: BoxDecoration(
              color: FluentCard.backgroundColor(theme, states, widget.onPressed != null),
              border: Border.all(
                width: borderSize,
                color: FluentCard.borderColor(theme, states, widget.onPressed != null),
              ),
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(4.0),
                bottom: Radius.circular(open ? 0.0 : 4.0),
              ),
            ),
            padding: const EdgeInsets.only(left: 16.0),
            alignment: Alignment.centerLeft,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (widget.leading != null) Padding(
                padding: const EdgeInsets.only(right: 17.0),
                child: widget.leading!,
              ),
              Expanded(child: widget.content),
              if (widget.trailing != null) Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 13.5),
                child: widget.trailing!,
              )
            ]),
          );
        },
      )
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _isDown ? children : children.reversed.toList(),
    );
  }
}
