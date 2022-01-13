import 'dart:ui' as ui;
import 'package:fluent_ui/fluent_ui.dart';
import '../utils/misc_utils.dart';

const double _kCompactNavigationPanelWidth = 50.0;

class ThemablePaneItem extends PaneItem {

  final MouseCursor? mouseCursor;
  final PaneDisplayMode? forceDisplayMode;
  final bool translucent;
  final bool topHoverEffect;

  /// Creates a pane item.
  ThemablePaneItem({
    required Widget icon,
    Widget? title,
    InfoBadge? infoBadge,
    FocusNode? focusNode,
    this.forceDisplayMode,
    bool autofocus = false,
    this.mouseCursor,
    this.topHoverEffect = true,
    this.translucent = false
  }) : super(icon: icon, title: title, infoBadge: infoBadge, focusNode: focusNode, autofocus: autofocus, mouseCursor: mouseCursor);

  static Color uncheckedInputAlphaColor(ThemeData style, Set<ButtonStates> states) {
    // The opacity is 0 because, when transitioning between [Colors.transparent]
    // and the actual color gives a weird effect
    if (style.brightness == Brightness.light) {
      if (states.isDisabled) return style.disabledColor;
      if (states.isPressing) return const Color(0xFF221D08).withOpacity(0.255);
      if (states.isHovering) return const Color(0xFF221D08).withOpacity(0.075);
      return Colors.transparent;
    } else {
      if (states.isDisabled) return style.disabledColor;
      if (states.isPressing) return const Color(0xFFFFF3E8).withOpacity(0.285);
      if (states.isHovering) return const Color(0xFFFFF3E8).withOpacity(0.12);
      return Colors.transparent;
    }
  }
  
  @override
  Widget build(
    BuildContext context,
    bool selected,
    VoidCallback? onPressed, {
    PaneDisplayMode? displayMode,
    bool showTextOnTop = true,
    bool? autofocus,
  }) {
    final PaneDisplayMode mode = forceDisplayMode ?? displayMode ??
        //_NavigationBody.maybeOf(context)?.displayMode ??
        PaneDisplayMode.minimal;
    assert(displayMode != PaneDisplayMode.auto);
    final bool isTop = mode == PaneDisplayMode.top;
    final bool isCompact = mode == PaneDisplayMode.compact;
    final bool isOpen =
        [PaneDisplayMode.open, PaneDisplayMode.minimal].contains(mode);
    final NavigationPaneThemeData theme = NavigationPaneTheme.of(context);

    final String titleText =
        title != null && title is Text ? (title! as Text).data ?? '' : '';

    return Container(
      key: itemKey,
      height: !isTop ? 36.0 : null,
      width: isCompact ? _kCompactNavigationPanelWidth : null,
      margin: const EdgeInsets.only(right: 6.0, left: 6.0, bottom: 4.0),
      alignment: Alignment.center,
      child: HoverButton(
        autofocus: autofocus ?? this.autofocus,
        focusNode: focusNode,
        onPressed: onPressed,
        cursor: mouseCursor,
        builder: (context, states) {
          final isLtr = Directionality.of(context) == TextDirection.ltr;
          final textStyle = selected
              ? theme.selectedTextStyle?.resolve(states)
              : theme.unselectedTextStyle?.resolve(states);
          final textResult = titleText.isNotEmpty
              ? Padding(
                  padding: theme.labelPadding?.directional() ?? EdgeInsets.zero,
                  child: Text(titleText, style: textStyle),
                )
              : const SizedBox.shrink();
          
          final icon = Padding(
            padding: theme.iconPadding?.directional() ?? EdgeInsets.zero,
            child: IconTheme.merge(
              data: IconThemeData(
                color: (selected ? theme.selectedIconColor?.resolve(states) : theme.unselectedIconColor?.resolve(states)) ?? textStyle?.color,
                size: 16.0,
              ),
              child: Center(
                child: Stack(clipBehavior: Clip.none, children: [
                  this.icon,
                  // Show here if it's not on top and not open
                  if (infoBadge != null && !isTop && !isOpen) Positioned(right: -8, top: -8, child: infoBadge!),
                ]),
              ),
            ),
          );
          
          Widget child = Flex(
            direction: isTop ? Axis.vertical : Axis.horizontal,
            textDirection: isTop ? ui.TextDirection.ltr : ui.TextDirection.rtl,
            mainAxisAlignment: isTop || !isOpen
                ? MainAxisAlignment.center
                : MainAxisAlignment.end,
            children: [
              if (isOpen && infoBadge != null) Padding(
                padding: const EdgeInsetsDirectional.only(end: 6.0),
                child: infoBadge!,
              ),
              if (!isLtr) icon,
              if (isOpen) Expanded(child: textResult),
              if (isLtr) icon,
            ],
          );
          if (isTop && showTextOnTop) {
            child = Row(mainAxisSize: MainAxisSize.min, children: [
              child,
              textResult,
            ]);
          }
          if (isTop && infoBadge != null) {
            child = Stack(children: [
              child,
              Positioned(
                top: 0,
                right: 0,
                child: infoBadge!,
              ),
            ]);
          }
          child = AnimatedContainer(
            duration: theme.animationDuration ?? Duration.zero,
            curve: theme.animationCurve ?? standartCurve,
            decoration: BoxDecoration(
              color: () {
                final ButtonState<Color?> tileColor = theme.tileColor ??
                    ButtonState.resolveWith((states) {
                      if (isTop && !topHoverEffect) return Colors.transparent;
                      return translucent ? uncheckedInputAlphaColor(FluentTheme.of(context), states) :
                        ButtonThemeData.uncheckedInputColor(FluentTheme.of(context), states);
                    });
                final newStates = states.toSet()..remove(ButtonStates.disabled);
                return tileColor.resolve(
                  (selected && !isTop) ? {ButtonStates.hovering} : newStates,
                );
              }(),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: child,
          );
          child = Semantics(
            label: title == null ? null : titleText,
            selected: selected,
            child: FocusBorder(
              child: child,
              focused: states.isFocused,
              renderOutside: false,
            ),
          );
          if (((isTop && !showTextOnTop) || isCompact) &&
              titleText.isNotEmpty &&
              !states.isDisabled) {
            return Tooltip(
              message: titleText,
              style: TooltipThemeData(
                textStyle: title is Text ? (title as Text).style : null,
              ),
              child: child,
            );
          }
          return child;
        },
      ),
    );
  }
}