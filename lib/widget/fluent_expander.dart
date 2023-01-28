import 'package:fluent_ui/fluent_ui.dart';
import 'package:wsa_pacman/widget/fluent_card.dart';
import 'package:wsa_pacman/widget/themed_pane_item.dart';

class ExpanderWin11 extends StatefulWidget {
  /// Creates an expander
  const ExpanderWin11({
    Key? key,
    this.leading,
    required this.header,
    required this.content,
    this.icon,
    this.trailing,
    this.animationCurve,
    this.animationDuration,
    this.direction = ExpanderDirection.down,
    this.initiallyExpanded = false,
    this.onStateChanged,
    this.headerHeight = 68.5,
    this.headerBackgroundColor,
    this.contentBackgroundColor,
  }) : super(key: key);

  /// The leading widget.
  ///
  /// See also:
  ///
  ///  * [Icon]
  ///  * [RadioButton]
  ///  * [Checkbox]
  final Widget? leading;

  /// The expander header
  ///
  /// Usually a [Text]
  final Widget header;

  /// The expander content
  ///
  /// You can use complex, interactive UI as the content of the
  /// Expander, including nested Expander controls in the content
  /// of a parent Expander as shown here.
  ///
  /// ![Expander Nested Content](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/expander-nested.png)
  final Widget content;

  /// The icon of the toggle button.
  final Widget? icon;

  /// The trailing widget. It's positioned at the right of [header]
  /// and at the left of [icon].
  ///
  /// See also:
  ///
  ///  * [ToggleSwitch]
  final Widget? trailing;

  /// The expand-collapse animation duration. If null, defaults to
  /// [FluentTheme.fastAnimationDuration]
  final Duration? animationDuration;

  /// The expand-collapse animation curve. If null, defaults to
  /// [FluentTheme.animationCurve]
  final Curve? animationCurve;

  /// The expand direction. Defaults to [ExpanderDirection.down]
  final ExpanderDirection direction;

  /// Whether the [ExpanderWin11] is initially expanded. Defaults to `false`
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
  ExpanderWin11State createState() => ExpanderWin11State();
}

class ExpanderWin11State extends State<ExpanderWin11>
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
              color: FluentCard.backgroundColor(theme, states, true),
              border: Border.all(
                width: borderSize,
                color: FluentCard.borderColor(theme, states, false, true),
              ),
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(4.0),
                bottom: Radius.circular(open ? 0.0 : 4.0),
              ),
            ),
            padding: const EdgeInsetsDirectional.only(start: 16.0),
            alignment: Alignment.centerLeft,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (widget.leading != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 17.0),
                  child: widget.leading!,
                ),
              Expanded(child: widget.header),
              if (widget.trailing != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 20.0),
                  child: widget.trailing!,
                ),
              Container(
                margin: EdgeInsetsDirectional.only(
                  start: widget.trailing != null ? 8.0 : 20.0,
                  end: 8.0,
                  top: 8.0,
                  bottom: 8.0,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                /*decoration: BoxDecoration(
                  color: ButtonThemeData.uncheckedInputColor(theme, states),
                  borderRadius: BorderRadius.circular(4.0),
                ),*/
                alignment: Alignment.center,
                child: widget.icon ??
                    RotationTransition(
                      turns: Tween<double>(begin: 0, end: 0.5)
                          .animate(_controller),
                      child: Icon(
                        _isDown
                            ? isDark ? FluentIcons.chevron_down : FluentIcons.chevron_down_med
                            : isDark ? FluentIcons.chevron_up : FluentIcons.chevron_up_med,
                        size: 11,
                      ),
                    ),
              ),
            ]),
          );
        },
      ),
      SizeTransition(
        sizeFactor: _controller,
        // Eliminates double border
        // this is not possible by only setting left, right and bottom borders if borderRadius is enabled
        // see issue https://github.com/flutter/flutter/issues/12583
        child: Transform.translate(offset: const Offset(0, -borderSize), child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(width: borderSize, color: FluentCard.borderColor(theme, {ButtonStates.none}, false, false)),
            color: FluentCard.backgroundColor(theme, {ButtonStates.none}, false),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4.0)),
          ),
          child: widget.content,
        )),
      ),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _isDown ? children : children.reversed.toList(),
    );
  }
}
