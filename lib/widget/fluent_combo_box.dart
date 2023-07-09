// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:math' as math;
import 'dart:ui' show window;

import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:fluent_ui/fluent_ui.dart';
// ignore: implementation_imports
import 'package:fluent_ui/src/controls/form/pickers/pickers.dart';
import 'package:wsa_pacman/utils/misc_utils.dart';
import 'package:wsa_pacman/widget/smooth_list_view.dart';

const Duration _kComboboxMenuDuration = Duration(milliseconds: 300);
const double _kMenuItemHeight = kPickerHeight;
const EdgeInsets _kMenuItemPadding = EdgeInsets.symmetric(horizontal: 12.0);
const EdgeInsetsGeometry _kAlignedButtonPadding = EdgeInsets.only(
  top: 4.0,
  bottom: 4.0,
  right: 8.0,
  left: 12.0,
);
const EdgeInsets _kAlignedMenuMargin = EdgeInsets.zero;
const EdgeInsets _kListPadding = EdgeInsets.symmetric(vertical: 8.0);
const double kMinInteractiveDimension = 48.0;
typedef FluentComboboxBuilder = List<Widget> Function(BuildContext context);

class _ComboboxMenuPainter extends CustomPainter {
  _ComboboxMenuPainter({
    this.selectedIndex,
    required this.resize,
    required this.getSelectedItemOffset,
  })  : _painter = BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(width: 0.5, color: const ColorConst.withOpacity(0x000000, 0.5)),
        ).createBoxPainter(),
        super(repaint: resize);

  final int? selectedIndex;
  final Animation<double> resize;
  final ValueGetter<double> getSelectedItemOffset;
  final BoxPainter _painter;

  @override
  void paint(Canvas canvas, Size size) {
    final double selectedItemOffset = getSelectedItemOffset();
    final Tween<double> top = Tween<double>(
      begin: selectedItemOffset.clamp(0.0, size.height - _kMenuItemHeight),
      end: 0.0,
    );

    final Tween<double> bottom = Tween<double>(
      begin:
          (top.begin! + _kMenuItemHeight).clamp(_kMenuItemHeight, size.height),
      end: size.height,
    );

    final Rect rect = Rect.fromLTRB(
        0.0, top.evaluate(resize), size.width, bottom.evaluate(resize));

    _painter.paint(canvas, rect.topLeft, ImageConfiguration(size: rect.size));
  }

  @override
  bool shouldRepaint(_ComboboxMenuPainter oldPainter) {
    return oldPainter.selectedIndex != selectedIndex ||
        oldPainter.resize != resize;
  }
}

class _ComboboxScrollBehavior extends ScrollBehavior {
  const _ComboboxScrollBehavior();

  @override
  TargetPlatform getPlatform(BuildContext context) => defaultTargetPlatform;

  @override
  Widget buildViewportChrome(
          BuildContext context, Widget child, AxisDirection axisDirection) =>
      child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

class _ComboboxItemButton<T> extends StatefulWidget {
  const _ComboboxItemButton({
    Key? key,
    this.padding,
    required this.route,
    required this.buttonRect,
    required this.constraints,
    required this.itemIndex,
  }) : super(key: key);

  final _ComboboxRoute<T> route;
  final EdgeInsets? padding;
  final Rect buttonRect;
  final BoxConstraints constraints;
  final int itemIndex;

  @override
  _ComboboxItemButtonState<T> createState() => _ComboboxItemButtonState<T>();
}

class _ComboboxItemButtonState<T> extends State<_ComboboxItemButton<T>> {
  void _handleFocusChange(bool focused) {
    final bool inTraditionalMode;
    switch (FocusManager.instance.highlightMode) {
      case FocusHighlightMode.touch:
        inTraditionalMode = false;
        break;
      case FocusHighlightMode.traditional:
        inTraditionalMode = true;
        break;
    }

    if (focused && inTraditionalMode) {
      final _MenuLimits menuLimits = widget.route.getMenuLimits(
          widget.buttonRect, widget.constraints.maxHeight, widget.itemIndex);
      /*widget.route.scrollController!.animateTo(
        menuLimits.scrollOffset,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 100),
      );*/
    }
  }

  void _handleOnTap() {
    final ComboboxItem<T> comboboxMenuItem =
        widget.route.items[widget.itemIndex].item!;

    if (comboboxMenuItem.onTap != null) {
      comboboxMenuItem.onTap!();
    }

    Navigator.pop(
      context,
      _ComboboxRouteResult<T>(comboboxMenuItem.value),
    );
  }

  static final Map<LogicalKeySet, Intent> _webShortcuts =
      <LogicalKeySet, Intent>{
    LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
  };

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final CurvedAnimation opacity;
    final double unit = 0.5 / (widget.route.items.length + 1.5);
    if (widget.itemIndex == widget.route.selectedIndex) {
      opacity = CurvedAnimation(
          parent: widget.route.animation!, curve: const Threshold(0.0));
    } else {
      final double start =
          (0.5 + (widget.itemIndex + 1) * unit).clamp(0.0, 1.0);
      final double end = (start + 1.5 * unit).clamp(0.0, 1.0);
      opacity = CurvedAnimation(
          parent: widget.route.animation!, curve: Interval(start, end));
    }
    Widget child = FadeTransition(
      opacity: opacity,
      child: HoverButton(
        autofocus: widget.itemIndex == widget.route.selectedIndex,
        builder: (context, states) {
          final theme = FluentTheme.of(context);
          return Padding(
            padding: const EdgeInsets.only(right: 6.0, left: 6.0, bottom: 4.0),
            child: Stack(fit: StackFit.loose, children: [
              Container(
                decoration: BoxDecoration(
                  color: () {
                    if (states.isFocused) {
                      return ButtonThemeData.uncheckedInputColor(
                        theme,
                        {ButtonStates.hovering},
                      );
                    }
                    return ButtonThemeData.uncheckedInputColor(theme, states);
                  }(),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                padding: widget.padding,
                child: widget.route.items[widget.itemIndex],
              ),
              if (states.isFocused)
                AnimatedPositioned(
                  duration: theme.fastAnimationDuration,
                  curve: theme.animationCurve,
                  top: states.isPressing ? 10.0 : 8.0,
                  bottom: states.isPressing ? 10.0 : 8.0,
                  child: Container(
                    width: 3.0,
                    decoration: BoxDecoration(
                      color: theme.accentColor
                          .resolveFromReverseBrightness(theme.brightness),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                ),
            ]),
          );
        },
        onPressed: _handleOnTap,
        onFocusChange: _handleFocusChange,
      ),
    );
    if (kIsWeb) {
      child = Shortcuts(
        shortcuts: _webShortcuts,
        child: child,
      );
    }
    return child;
  }
}

class _ComboboxMenu<T> extends StatefulWidget {
  const _ComboboxMenu({
    Key? key,
    this.padding,
    required this.route,
    required this.buttonRect,
    required this.constraints,
    this.comboboxColor,
  }) : super(key: key);

  final _ComboboxRoute<T> route;
  final EdgeInsets? padding;
  final Rect buttonRect;
  final BoxConstraints constraints;
  final Color? comboboxColor;

  @override
  _ComboboxMenuState<T> createState() => _ComboboxMenuState<T>();
}

class _ComboboxMenuState<T> extends State<_ComboboxMenu<T>> {
  late CurvedAnimation _fadeOpacity;
  late CurvedAnimation _resize;

  @override
  void initState() {
    super.initState();
    _fadeOpacity = CurvedAnimation(
      parent: widget.route.animation!,
      curve: const Interval(0.0, 0.25),
      reverseCurve: const Interval(0.75, 1.0),
    );
    _resize = CurvedAnimation(
      parent: widget.route.animation!,
      curve: const Interval(0.25, 0.5),
      reverseCurve: const Threshold(0.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _ComboboxRoute<T> route = widget.route;
    final List<Widget> children = <Widget>[
      for (int itemIndex = 0; itemIndex < route.items.length; ++itemIndex)
        _ComboboxItemButton<T>(
          route: widget.route,
          padding: widget.padding,
          buttonRect: widget.buttonRect,
          constraints: widget.constraints,
          itemIndex: itemIndex,
        ),
    ];

    return FadeTransition(
      opacity: _fadeOpacity,
      child: Acrylic(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
        elevation: route.elevation.toDouble(),
        child: CustomPaint(
          painter: _ComboboxMenuPainter(
            selectedIndex: route.selectedIndex,
            resize: _resize,
            getSelectedItemOffset: () =>
                route.getItemOffset(route.selectedIndex),
          ),
          child: Semantics(
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            child: DefaultTextStyle(
              style: route.style,
              child: ScrollConfiguration(
                behavior: const FluentScrollBehavior(),
                child: DynMouseScroll(builder: (context, controller, physics) => PrimaryScrollController(
                  controller: widget.route.scrollController = controller,
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return Scrollbar(
                        timeToFade: const Duration(milliseconds: 600),
                        controller: controller,
                        //sAlwaysShown: isScrollable,
                        child: ListView(
                          padding: _kListPadding,
                          shrinkWrap: true,
                          controller: controller,
                          physics: physics,
                          children: children,
                        ),
                      );
                    },
                  ),
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ComboboxMenuRouteLayout<T> extends SingleChildLayoutDelegate {
  _ComboboxMenuRouteLayout({
    required this.buttonRect,
    required this.route,
    required this.textDirection,
  });

  final Rect buttonRect;
  final _ComboboxRoute<T> route;
  final TextDirection? textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double maxHeight =
        math.max(0.0, constraints.maxHeight - 2 * _kMenuItemHeight);
    final double width = math.min(constraints.maxWidth, buttonRect.width);
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      minHeight: 0.0,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final _MenuLimits menuLimits =
        route.getMenuLimits(buttonRect, size.height, route.selectedIndex);

    assert(() {
      final Rect container = Offset.zero & size;
      if (container.intersect(buttonRect) == buttonRect) {
        assert(menuLimits.top >= 0.0);
        assert(menuLimits.top + menuLimits.height <= size.height);
      }
      return true;
    }());
    assert(textDirection != null);
    final double left;
    switch (textDirection!) {
      case TextDirection.rtl:
        left = buttonRect.right.clamp(0.0, size.width) - childSize.width;
        break;
      case TextDirection.ltr:
        left = buttonRect.left.clamp(0.0, size.width - childSize.width);
        break;
    }

    return Offset(left, menuLimits.top);
  }

  @override
  bool shouldRelayout(_ComboboxMenuRouteLayout<T> oldDelegate) {
    return buttonRect != oldDelegate.buttonRect ||
        textDirection != oldDelegate.textDirection;
  }
}

@immutable
class _ComboboxRouteResult<T> {
  const _ComboboxRouteResult(this.result);

  final T? result;

  @override
  bool operator ==(Object other) {
    return other is _ComboboxRouteResult<T> && other.result == result;
  }

  @override
  int get hashCode => result.hashCode;
}

class _MenuLimits {
  const _MenuLimits(this.top, this.bottom, this.height, this.scrollOffset);
  final double top;
  final double bottom;
  final double height;
  final double scrollOffset;
}

class _ComboboxRoute<T> extends PopupRoute<_ComboboxRouteResult<T>> {
  _ComboboxRoute({required this.items, required this.padding, required this.buttonRect, required this.selectedIndex, this.elevation = 16,
    required this.capturedThemes, required this.style, required this.acrylicEnabled, this.barrierLabel, this.itemHeight, this.comboboxColor}) 
      : itemHeights = List<double>.filled(items.length, itemHeight ?? kMinInteractiveDimension);

  final List<_MenuItem<T>> items;
  final EdgeInsetsGeometry padding;
  final Rect buttonRect;
  final int selectedIndex;
  final int elevation;
  final CapturedThemes capturedThemes;
  final TextStyle style;
  final double? itemHeight;
  final Color? comboboxColor;
  final bool acrylicEnabled;

  final List<double> itemHeights;
  ScrollController? scrollController;

  @override Duration get transitionDuration => _kComboboxMenuDuration;
  @override bool get barrierDismissible => true;
  @override Color? get barrierColor => null;
  @override final String? barrierLabel;

  @override
  Widget buildPage(context, animation, secondaryAnimation) {
    return LayoutBuilder(builder: (context, constraints) {
      final page = _ComboboxRoutePage<T>(route: this, constraints: constraints, items: items, padding: padding, buttonRect: buttonRect,
        selectedIndex: selectedIndex, elevation: elevation, capturedThemes: capturedThemes, style: style, comboboxColor: comboboxColor);
      if (acrylicEnabled) return page;
      return DisableAcrylic(child: page);
    });
  }

  void _dismiss() {
    if (isActive) {
      navigator?.removeRoute(this);
    }
  }

  double getItemOffset(int index) {
    double offset = _kListPadding.top;
    if (items.isNotEmpty && index > 0) {
      assert(items.length == itemHeights.length);
      offset += itemHeights
          .sublist(0, index)
          .reduce((double total, double height) => total + height);
    }
    return offset;
  }
  
  _MenuLimits getMenuLimits(
      Rect buttonRect, double availableHeight, int index) {
    final double maxMenuHeight = availableHeight - 2.0 * _kMenuItemHeight;
    final double buttonTop = buttonRect.top;
    final double buttonBottom = math.min(buttonRect.bottom, availableHeight);
    final double selectedItemOffset = getItemOffset(index);
    final double topLimit = math.min(_kMenuItemHeight, buttonTop);
    final double bottomLimit =
        math.max(availableHeight - _kMenuItemHeight, buttonBottom);

    double menuTop = (buttonTop - selectedItemOffset) -
        (itemHeights[selectedIndex] - buttonRect.height) / 2.0;
    double preferredMenuHeight = _kListPadding.vertical;
    if (items.isNotEmpty) {
      preferredMenuHeight +=
          itemHeights.reduce((double total, double height) => total + height);
    }

    final double menuHeight = math.min(maxMenuHeight, preferredMenuHeight);
    double menuBottom = menuTop + menuHeight;

    if (menuTop < topLimit) menuTop = math.min(buttonTop, topLimit);

    if (menuBottom > bottomLimit) {
      menuBottom = math.max(buttonBottom, bottomLimit);
      menuTop = menuBottom - menuHeight;
    }

    double scrollOffset = 0;

    if (preferredMenuHeight > maxMenuHeight) {
      scrollOffset = math.max(0.0, selectedItemOffset - (buttonTop - menuTop));
      scrollOffset = math.min(scrollOffset, preferredMenuHeight - menuHeight);
    }

    return _MenuLimits(menuTop, menuBottom, menuHeight, scrollOffset);
  }
}

class _ComboboxRoutePage<T> extends StatelessWidget {
  const _ComboboxRoutePage({
    Key? key,
    required this.route,
    required this.constraints,
    this.items,
    required this.padding,
    required this.buttonRect,
    required this.selectedIndex,
    this.elevation = 8,
    required this.capturedThemes,
    this.style,
    required this.comboboxColor,
  }) : super(key: key);

  final _ComboboxRoute<T> route;
  final BoxConstraints constraints;
  final List<_MenuItem<T>>? items;
  final EdgeInsetsGeometry padding;
  final Rect buttonRect;
  final int selectedIndex;
  final int elevation;
  final CapturedThemes capturedThemes;
  final TextStyle? style;
  final Color? comboboxColor;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));

    if (route.scrollController == null) {
      final _MenuLimits menuLimits =
          route.getMenuLimits(buttonRect, constraints.maxHeight, selectedIndex);
      route.scrollController =
          ScrollController(initialScrollOffset: menuLimits.scrollOffset);
    }

    final TextDirection? textDirection = Directionality.maybeOf(context);
    final Widget menu = _ComboboxMenu<T>(
      route: route,
      padding: padding.resolve(textDirection),
      buttonRect: buttonRect,
      constraints: constraints,
      comboboxColor: comboboxColor,
    );

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Builder(
        builder: (BuildContext context) {
          return CustomSingleChildLayout(
            delegate: _ComboboxMenuRouteLayout<T>(
              buttonRect: buttonRect,
              route: route,
              textDirection: textDirection,
            ),
            child: capturedThemes.wrap(menu),
          );
        },
      ),
    );
  }
}

class _MenuItem<T> extends SingleChildRenderObjectWidget {
  const _MenuItem({
    Key? key,
    required this.onLayout,
    required this.item,
  }) : super(key: key, child: item);

  final ValueChanged<Size> onLayout;
  final ComboboxItem<T>? item;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMenuItem(onLayout);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderMenuItem renderObject) {
    renderObject.onLayout = onLayout;
  }
}

class _RenderMenuItem extends RenderProxyBox {
  _RenderMenuItem(this.onLayout, [RenderBox? child]) : super(child);

  ValueChanged<Size> onLayout;

  @override
  void performLayout() {
    super.performLayout();
    onLayout(size);
  }
}

// The container widget for a menu item created by a [Combobox]. It
// provides the default configuration for [ComboboxItem]s, as well as a
// [Combobox]'s placeholder and disabledHint widgets.
class _ComboboxItemContainer extends StatelessWidget {
  /// Creates an item for a combobox menu.
  ///
  /// The [child] argument is required.
  const _ComboboxItemContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: _kMenuItemHeight),
      alignment: AlignmentDirectional.centerStart,
      child: child,
    );
  }
}

class FluentCombobox<T> extends StatefulWidget {
  FluentCombobox({
    Key? key,
    required this.items,
    this.allowUnknown = false,
    this.selectedItemBuilder,
    this.value,
    this.placeholder,
    this.disabledHint,
    this.onChanged,
    this.onTap,
    this.elevation = 8,
    this.style,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 10.0,
    this.isExpanded = false,
    this.itemHeight = kMinInteractiveDimension,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.comboboxColor,
  }) : assert(allowUnknown || items == null || items.isEmpty || value == null || items.where((item) => item.value == value).length == 1,
          "There should be exactly one item with [Combobox]'s value: $value. \n"
          'Either zero or 2 or more [ComboboxItem]s were detected with the same value'),
        assert(itemHeight == null || itemHeight >= kMinInteractiveDimension),
        super(key: key);

  final bool allowUnknown;
  final List<ComboboxItem<T>>? items;
  final T? value;
  final Widget? placeholder;
  final Widget? disabledHint;
  final ValueChanged<T?>? onChanged;
  final VoidCallback? onTap;
  final FluentComboboxBuilder? selectedItemBuilder;
  final int elevation;
  final TextStyle? style;
  final Widget? icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double iconSize;
  final bool isExpanded;
  final double? itemHeight;
  final Color? focusColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? comboboxColor;

  @override
  _FluentComboboxState<T> createState() => _FluentComboboxState<T>();
}

class _FluentComboboxState<T> extends State<FluentCombobox<T>> with WidgetsBindingObserver {
  int? _selectedIndex;
  _ComboboxRoute<T>? _comboboxRoute;
  Orientation? _lastOrientation;
  FocusNode? _internalNode;
  FocusNode? get focusNode => widget.focusNode ?? _internalNode;
  bool _hasPrimaryFocus = false;
  late Map<Type, Action<Intent>> _actionMap;
  late FocusHighlightMode _focusHighlightMode;

  // Only used if needed to create _internalNode.
  FocusNode _createFocusNode() {
    return FocusNode(debugLabel: '${widget.runtimeType}');
  }

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
    if (widget.focusNode == null) {
      _internalNode ??= _createFocusNode();
    }
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (ActivateIntent intent) => _handleTap(),
      ),
      ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
        onInvoke: (ButtonActivateIntent intent) => _handleTap(),
      ),
    };
    focusNode!.addListener(_handleFocusChanged);
    final FocusManager focusManager = WidgetsBinding.instance.focusManager;
    _focusHighlightMode = focusManager.highlightMode;
    focusManager.addHighlightModeListener(_handleFocusHighlightModeChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeComboboxRoute();
    WidgetsBinding.instance.focusManager
        .removeHighlightModeListener(_handleFocusHighlightModeChange);
    focusNode!.removeListener(_handleFocusChanged);
    _internalNode?.dispose();
    super.dispose();
  }

  void _removeComboboxRoute() {
    _comboboxRoute?._dismiss();
    _comboboxRoute = null;
    _lastOrientation = null;
  }

  void _handleFocusChanged() {
    if (_hasPrimaryFocus != focusNode!.hasPrimaryFocus) {
      setState(() {
        _hasPrimaryFocus = focusNode!.hasPrimaryFocus;
      });
    }
  }

  void _handleFocusHighlightModeChange(FocusHighlightMode mode) {
    if (!mounted) {
      return;
    }
    setState(() {
      _focusHighlightMode = mode;
    });
  }

  @override
  void didUpdateWidget(FluentCombobox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      if (widget.focusNode == null) {
        _internalNode ??= _createFocusNode();
      }
      _hasPrimaryFocus = focusNode!.hasPrimaryFocus;
      focusNode!.addListener(_handleFocusChanged);
    }
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    if (widget.value == null || widget.items == null || widget.items!.isEmpty) {
      _selectedIndex = null;
      return;
    }
    
    for (int itemIndex = 0; itemIndex < widget.items!.length; itemIndex++) {
      if (widget.items![itemIndex].value == widget.value) {
        _selectedIndex = itemIndex;
        return;
      }
    }
    assert(widget.allowUnknown);
    _selectedIndex = null;
  }

  TextStyle? get _textStyle =>
      widget.style ?? FluentTheme.of(context).typography.body;

  void _handleTap() {
    final TextDirection? textDirection = Directionality.maybeOf(context);
    const EdgeInsetsGeometry menuMargin = _kAlignedMenuMargin;

    final List<_MenuItem<T>> menuItems = <_MenuItem<T>>[
      for (int index = 0; index < widget.items!.length; index += 1)
        _MenuItem<T>(
          item: widget.items![index],
          onLayout: (Size size) {
            if (_comboboxRoute == null) return;

            _comboboxRoute!.itemHeights[index] = size.height;
          },
        )
    ];

    final NavigatorState navigator = Navigator.of(context);
    assert(_comboboxRoute == null);
    final RenderBox itemBox = context.findRenderObject()! as RenderBox;
    final Rect itemRect = itemBox.localToGlobal(Offset.zero,
            ancestor: navigator.context.findRenderObject()) &
        itemBox.size;
    _comboboxRoute = _ComboboxRoute<T>(
      acrylicEnabled: DisableAcrylic.of(context) != null,
      items: menuItems,
      buttonRect: menuMargin.resolve(textDirection).inflateRect(itemRect),
      padding: _kMenuItemPadding.resolve(textDirection),
      selectedIndex: _selectedIndex ?? 0,
      elevation: widget.elevation,
      capturedThemes:
          InheritedTheme.capture(from: context, to: navigator.context),
      style: _textStyle!,
      barrierLabel: FluentLocalizations.of(context).modalBarrierDismissLabel,
      itemHeight: widget.itemHeight,
      comboboxColor: widget.comboboxColor,
    );

    navigator
        .push(_comboboxRoute!)
        .then<void>((_ComboboxRouteResult<T>? newValue) {
      _removeComboboxRoute();
      if (!mounted || newValue == null) return;
      if (widget.onChanged != null) widget.onChanged!(newValue.result);
    });

    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  Color get _iconColor {
    // These colors are not defined in the Material Design spec.
    if (_enabled) {
      if (widget.iconEnabledColor != null) return widget.iconEnabledColor!;

      switch (FluentTheme.of(context).brightness) {
        case Brightness.light:
          return Colors.grey[190];
        case Brightness.dark:
          return Colors.white.withOpacity(0.7);
      }
    } else {
      if (widget.iconDisabledColor != null) return widget.iconDisabledColor!;

      switch (FluentTheme.of(context).brightness) {
        case Brightness.light:
          return Colors.grey[150];
        case Brightness.dark:
          return Colors.white.withOpacity(0.10);
      }
    }
  }

  bool get _enabled =>
      widget.items != null &&
      widget.items!.isNotEmpty &&
      widget.onChanged != null;

  Orientation _getOrientation(BuildContext context) {
    Orientation? result = MediaQuery.maybeOf(context)?.orientation;
    if (result == null) {
      // If there's no MediaQuery, then use the window aspect to determine
      // orientation.
      final Size size = window.physicalSize;
      result = size.width > size.height
          ? Orientation.landscape
          : Orientation.portrait;
    }
    return result;
  }

  bool get _showHighlight {
    switch (_focusHighlightMode) {
      case FocusHighlightMode.touch:
        return false;
      case FocusHighlightMode.traditional:
        return _hasPrimaryFocus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Orientation newOrientation = _getOrientation(context);
    _lastOrientation ??= newOrientation;
    if (newOrientation != _lastOrientation) {
      _removeComboboxRoute();
      _lastOrientation = newOrientation;
    }
    
    final List<Widget> items = widget.selectedItemBuilder == null
        ? (widget.items != null ? List<Widget>.from(widget.items!) : <Widget>[])
        : List<Widget>.from(widget.selectedItemBuilder!(context));

    int? placeholderIndex;
    if (widget.placeholder != null ||
        (!_enabled && widget.disabledHint != null)) {
      Widget displayedHint = _enabled
          ? widget.placeholder!
          : widget.disabledHint ?? widget.placeholder!;
      if (widget.selectedItemBuilder == null) {
        displayedHint = _ComboboxItemContainer(child: displayedHint);
      }

      placeholderIndex = items.length;
      items.add(DefaultTextStyle(
        style:
            _textStyle!.copyWith(color: FluentTheme.of(context).disabledColor),
        child: IgnorePointer(
          ignoringSemantics: false,
          child: displayedHint,
        ),
      ));
    }

    const EdgeInsetsGeometry padding = _kAlignedButtonPadding;

    // If value is null (then _selectedIndex is null) then we
    // display the placeholder or nothing at all.
    final Widget innerItemsWidget;
    if (items.isEmpty) {
      innerItemsWidget = Container();
    } else {
      innerItemsWidget = IndexedStack(
        index: _selectedIndex ?? placeholderIndex,
        alignment: AlignmentDirectional.centerStart,
        children: items.map((Widget item) {
          return widget.itemHeight != null
              ? SizedBox(height: widget.itemHeight, child: item)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[item],
                );
        }).toList(),
      );
    }

    const Icon defaultIcon = Icon(FluentIcons.chevron_down);

    Widget result = DefaultTextStyle(
      style: _enabled
          ? _textStyle!
          : _textStyle!.copyWith(color: FluentTheme.of(context).disabledColor),
      child: Container(
        padding: padding.resolve(Directionality.of(context)),
        height: kPickerHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.isExpanded)
              Expanded(child: innerItemsWidget)
            else
              innerItemsWidget,
            IconTheme.merge(
              data: IconThemeData(color: _iconColor, size: widget.iconSize),
              child: widget.icon ?? defaultIcon,
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      child: Actions(
        actions: _actionMap,
        child: HoverButton(
          focusNode: focusNode,
          autofocus: widget.autofocus,
          onPressed: _enabled ? _handleTap : null,
          builder: (context, states) {
            return Container(
              decoration: fluentComboBoxDecorationBuilder(context, () {
                if (_showHighlight) {
                  return {ButtonStates.focused};
                } else if (states.isFocused) {
                  return <ButtonStates>{};
                }
                return states;
              }()),
              child: result,
            );
          },
        ),
      ),
    );
  }
}

BorderSide fluentComboBoxBorderColor(bool isDark, Set<ButtonStates> states) {
  if (isDark) {
    if (states.isDisabled) return const BorderSide(width: 0.5, color: ColorConst.withOpacity(0xf0f0f0, 0.05));
    if (states.isNone || (states.isHovering && !states.isPressing)) return const BorderSide(width: 0.5, color: ColorConst.withOpacity(0xf0f0f0, 0.035));
    else return const BorderSide(width: 0.5, color: ColorConst.withOpacity(0xf0f0f0, 0.07));
  }
  else {
    if (states.isDisabled) return const BorderSide(width: 0.5, color: ColorConst.withOpacity(0x212121, 0.12));
    if (states.isNone || (states.isHovering && !states.isDisabled && !states.isPressing)) return const BorderSide(width: 0.5, color: ColorConst.withOpacity(0x212121, 0.22));
    else return const BorderSide(width: 0.5, color: ColorConst.withOpacity(0x212121, 0.07));
  }
}

Color fluentComboBoxColor(bool isDark, Set<ButtonStates> states) {
  if (isDark) {
    if (states.isDisabled) return const ColorConst.withOpacity(0xFFFFFF, 0.045);
    if (states.isPressing) return const ColorConst.withOpacity(0xFFFFFF, 0.03);
    if (states.isHovering) return const ColorConst.withOpacity(0xFFFFFF, 0.08);
    return const ColorConst.withOpacity(0xFFFFFF, 0.055);
  }
  else {
    if (states.isDisabled) return const ColorConst.withOpacity(0xf9f9f9, 0.045);
    if (states.isPressing) return const ColorConst.withOpacity(0xf0f0f0, 0.4);
    if (states.isHovering) return const ColorConst.withOpacity(0xf9f9f9, 0.65);
    return const ColorConst.withOpacity(0xFFFFFF, 0.8);
  }
}

Decoration fluentComboBoxDecorationBuilder(
    BuildContext context, Set<ButtonStates> states) {
  assert(debugCheckHasFluentTheme(context));
  final theme = FluentTheme.of(context);
  return BoxDecoration(
    borderRadius: BorderRadius.circular(4.0),
    border: Border.fromBorderSide(fluentComboBoxBorderColor(theme.brightness.isDark, states)),
    color: fluentComboBoxColor(theme.brightness.isDark, states),
  );
}
