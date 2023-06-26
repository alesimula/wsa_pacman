import 'package:fluent_ui/fluent_ui.dart';

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

  T? _getPropertyFromTitle<T>([dynamic def]) {
    if (title is Text) {
      final title = this.title as Text;
      switch (T) {
        case String:
          return (title.data ?? title.textSpan?.toPlainText()) as T?;
        case InlineSpan:
          return (title.textSpan ??
              TextSpan(
                text: title.data ?? '',
                style: _getPropertyFromTitle<TextStyle>()
                        ?.merge(def as TextStyle?) ??
                    def as TextStyle?,
              )) as T?;
        case TextStyle:
          return title.style as T?;
        case TextAlign:
          return title.textAlign as T?;
        case TextHeightBehavior:
          return title.textHeightBehavior as T?;
        case TextWidthBasis:
          return title.textWidthBasis as T?;
      }
    } else if (title is RichText) {
      final title = this.title as RichText;
      switch (T) {
        case String:
          return title.text.toPlainText() as T?;
        case InlineSpan:
          if (T is InlineSpan) {
            final span = title.text;
            span.style?.merge(def as TextStyle?);
            return span as T;
          }
          return title.text as T;
        case TextStyle:
          return (title.text.style as T?) ?? def as T?;
        case TextAlign:
          return title.textAlign as T?;
        case TextHeightBehavior:
          return title.textHeightBehavior as T?;
        case TextWidthBasis:
          return title.textWidthBasis as T?;
      }
    } else if (title is Icon) {
      final title = this.title as Icon;
      switch (T) {
        case String:
          if (title.icon?.codePoint == null) return null;
          return String.fromCharCode(title.icon!.codePoint) as T?;
        case InlineSpan:
          return TextSpan(
            text: String.fromCharCode(title.icon!.codePoint),
            style: _getPropertyFromTitle<TextStyle>(),
          ) as T?;
        case TextStyle:
          return TextStyle(
            color: title.color,
            fontSize: title.size,
            fontFamily: title.icon?.fontFamily,
            package: title.icon?.fontPackage,
          ) as T?;
        case TextAlign:
          return null;
        case TextHeightBehavior:
          return null;
        case TextWidthBasis:
          return null;
      }
    }
    return null;
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
    final maybeBody = InheritedNavigationView.maybeOf(context);
    final PaneDisplayMode mode = forceDisplayMode ??  displayMode ??
        PaneDisplayMode.minimal;
    assert(mode != PaneDisplayMode.auto);

    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));

    final direction = Directionality.of(context);

    final NavigationPaneThemeData theme = NavigationPaneTheme.of(context);
    final String titleText = _getPropertyFromTitle<String>() ?? '';

    final TextStyle baseStyle =
        _getPropertyFromTitle<TextStyle>() ?? const TextStyle();

    final bool isTop = mode == PaneDisplayMode.top;
    final bool isCompact = mode == PaneDisplayMode.compact;

    final button = HoverButton(
      autofocus: autofocus ?? this.autofocus,
      focusNode: focusNode,
      onPressed: onPressed,
      cursor: mouseCursor,
      builder: (context, states) {
        TextStyle textStyle = baseStyle.merge(
          selected
              ? theme.selectedTextStyle?.resolve(states)
              : theme.unselectedTextStyle?.resolve(states),
        );
        if (isTop && states.isPressing) {
          textStyle = textStyle.copyWith(
            color: textStyle.color?.withOpacity(0.75),
          );
        }
        final textResult = titleText.isNotEmpty
            ? Padding(
                padding: theme.labelPadding ?? EdgeInsets.zero,
                child: RichText(
                  text: _getPropertyFromTitle<InlineSpan>(textStyle)!,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign:
                      _getPropertyFromTitle<TextAlign>() ?? TextAlign.start,
                  textHeightBehavior:
                      _getPropertyFromTitle<TextHeightBehavior>(),
                  textWidthBasis: _getPropertyFromTitle<TextWidthBasis>() ??
                      TextWidthBasis.parent,
                ),
              )
            : const SizedBox.shrink();
        Widget result() {
          switch (mode) {
            case PaneDisplayMode.compact:
              return Container(
                key: itemKey,
                height: 36.0,
                alignment: Alignment.center,
                child: Padding(
                  padding: theme.iconPadding ?? EdgeInsets.zero,
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: (selected
                              ? theme.selectedIconColor?.resolve(states)
                              : theme.unselectedIconColor?.resolve(states)) ??
                          textStyle.color,
                      size: 16.0,
                    ),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: () {
                          if (infoBadge != null) {
                            return Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                icon,
                                Positioned(
                                  right: -8,
                                  top: -8,
                                  child: infoBadge!,
                                ),
                              ],
                            );
                          }
                          return icon;
                        }()),
                  ),
                ),
              );
            case PaneDisplayMode.minimal:
            case PaneDisplayMode.open:
              return SizedBox(
                key: itemKey,
                height: 36.0,
                child: Row(children: [
                  Padding(
                    padding: theme.iconPadding ?? EdgeInsets.zero,
                    child: IconTheme.merge(
                      data: IconThemeData(
                        color: (selected
                                ? theme.selectedIconColor?.resolve(states)
                                : theme.unselectedIconColor?.resolve(states)) ??
                            textStyle.color,
                        size: 16.0,
                      ),
                      child: Center(child: icon),
                    ),
                  ),
                  Expanded(child: textResult),
                  if (infoBadge != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8.0),
                      child: infoBadge!,
                    ),
                ]),
              );
            case PaneDisplayMode.top:
              Widget result = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: theme.iconPadding ?? EdgeInsets.zero,
                    child: IconTheme.merge(
                      data: IconThemeData(
                        color: (selected
                                ? theme.selectedIconColor?.resolve(states)
                                : theme.unselectedIconColor?.resolve(states)) ??
                            textStyle.color,
                        size: 16.0,
                      ),
                      child: Center(child: icon),
                    ),
                  ),
                  if (showTextOnTop) textResult,
                ],
              );
              if (infoBadge != null) {
                return Stack(
                  key: itemKey,
                  clipBehavior: Clip.none,
                  children: [
                    result,
                    if (infoBadge != null)
                      Positioned.directional(
                        textDirection: direction,
                        end: -3,
                        top: 3,
                        child: infoBadge!,
                      ),
                  ],
                );
              }
              return KeyedSubtree(key: itemKey, child: result);
            default:
              throw '$mode is not a supported type';
          }
        }

        return Semantics(
          label: titleText.isEmpty ? null : titleText,
          selected: selected,
          child: AnimatedContainer(
            duration: theme.animationDuration ?? Duration(seconds: 2),
            curve: theme.animationCurve ?? standardCurve,
            margin: const EdgeInsets.only(right: 6.0, left: 6.0),
            decoration: BoxDecoration(
              color: () {
                final ButtonState<Color?> tileColor = this.tileColor ??
                    theme.tileColor ??
                    ButtonState.resolveWith((states) {
                      if (isTop && !topHoverEffect) return Colors.transparent;
                      return translucent ? uncheckedInputAlphaColor(FluentTheme.of(context), states) :
                        ButtonThemeData.uncheckedInputColor(FluentTheme.of(context), states);
                    });
                final newStates = states.toSet()..remove(ButtonStates.disabled);
                if (selected && selectedTileColor != null) {
                  return selectedTileColor!.resolve(newStates);
                }
                return tileColor.resolve(
                  (selected && !isTop) ? {states.isHovering ? ButtonStates.pressing : ButtonStates.hovering} : newStates,
                );
              }(),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: FocusBorder(
              focused: states.isFocused,
              renderOutside: false,
              child: () {
                final showTooltip = ((isTop && !showTextOnTop) || isCompact) &&
                    titleText.isNotEmpty &&
                    !states.isDisabled;

                if (showTooltip) {
                  return Tooltip(
                    richMessage: _getPropertyFromTitle<InlineSpan>(),
                    style: TooltipThemeData(textStyle: baseStyle),
                    child: result(),
                  );
                }

                return result();
              }(),
            ),
          ),
        );
      },
    );

    final int? index = () {
      if (maybeBody?.pane?.indicator != null) {
        return maybeBody!.pane!.effectiveIndexOf(this);
      }
    }();

    dynamic paneItemKeys = maybeBody?.child; // type: _PaneItemKeys
    late final GlobalKey? key;
    // ignore: curly_braces_in_flow_control_structures
    if (index != null) try {
      key = paneItemKeys.keys[index];
    } catch (_) {
      key = null;
    } else {
      key = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: () {
        // If there is an indicator and the item is an effective item
        if (maybeBody?.pane?.indicator != null && index != -1) {
          return Stack(children: [
            button,
            Positioned.fill(
              child: InheritedNavigationView.merge(
                currentItemIndex: index,
                child: KeyedSubtree(
                  key: index != null ? key : null,
                  child: maybeBody!.pane!.indicator!,
                ),
              ),
            ),
          ]);
        }

        return button;
      }(),
    );
  }
}