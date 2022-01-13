import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/src/controls/form/selection_controls.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/services.dart';
import 'package:wsa_pacman/utils/misc_utils.dart';


class _TextBoxSelectionGestureDetectorBuilder extends TextSelectionGestureDetectorBuilder {
  _TextBoxSelectionGestureDetectorBuilder({required _TextBoxState state})  : _state = state, super(delegate: state);
  final _TextBoxState _state;

  @override void onDragSelectionEnd(DragEndDetails details) => _state._requestKeyboard();
  @override void onSingleTapUp(TapUpDetails details) {
    if (_state._clearGlobalKey.currentContext != null) {
      final RenderBox renderBox = _state._clearGlobalKey.currentContext!.findRenderObject() as RenderBox;
      final Offset localOffset = renderBox.globalToLocal(details.globalPosition);
      if (renderBox.hitTest(BoxHitTestResult(), position: localOffset)) return;
    }
    super.onSingleTapUp(details);
    _state._requestKeyboard();
    if (_state.widget.onTap != null) _state.widget.onTap!();
  }
}

class FluentTextBox extends StatefulWidget {
  const FluentTextBox({Key? key, this.controller, this.focusNode, this.padding = kTextBoxPadding, this.clipBehavior = Clip.antiAlias,
    this.placeholder, this.placeholderStyle, this.prefix, this.outsidePrefix, this.prefixMode = OverlayVisibilityMode.always,
    this.outsidePrefixMode = OverlayVisibilityMode.always, this.suffix, this.outsideSuffix, this.suffixMode = OverlayVisibilityMode.always,
    this.outsideSuffixMode = OverlayVisibilityMode.always, TextInputType? keyboardType, this.textInputAction, this.style, this.strutStyle,
    this.textAlign = TextAlign.start, this.textAlignVertical, this.readOnly = false, ToolbarOptions? toolbarOptions, this.showCursor,
    this.autofocus = false, this.obscuringCharacter = '•', this.obscureText = false, this.autocorrect = true, SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType, this.enableSuggestions = true, this.maxLines = 1, this.minLines, this.minHeight, this.expands = false,
    this.maxLength, this.maxLengthEnforced = true, this.onChanged, this.onEditingComplete, this.onSubmitted, this.inputFormatters, this.enabled,
    this.cursorWidth = 1.5, this.cursorHeight, this.cursorRadius = const Radius.circular(2.0), this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight, this.selectionWidthStyle = ui.BoxWidthStyle.tight, this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0), this.dragStartBehavior = DragStartBehavior.start, this.enableInteractiveSelection = true,
    this.onTap, this.scrollController, this.scrollPhysics, this.autofillHints, this.restorationId,
    this.textCapitalization = TextCapitalization.none, this.header, this.headerStyle, this.iconButtonThemeData,
  }) : assert(obscuringCharacter.length == 1),
        smartDashesType = smartDashesType ?? (obscureText ? SmartDashesType.disabled : SmartDashesType.enabled),
        smartQuotesType = smartQuotesType ?? (obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled),
        assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        assert((maxLines == null) || (minLines == null) || (maxLines >= minLines), "minLines can't be greater than maxLines"),
        assert(!expands || (maxLines == null && minLines == null), 'minLines and maxLines must be null when expands is true.'),
        assert(!obscureText || maxLines == 1, 'Obscured fields cannot be multiline.'),
        assert(maxLength == null || maxLength > 0),
        assert(!identical(textInputAction, TextInputAction.newline) || maxLines == 1 || !identical(keyboardType, TextInputType.text),
            'Use keyboardType TextInputType.multiline when using TextInputAction.newline on a multiline TextField.'),
        keyboardType = keyboardType ?? (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
        toolbarOptions = toolbarOptions ?? (obscureText ? const ToolbarOptions(selectAll: true, paste: true)
            : const ToolbarOptions(copy: true, cut: true, selectAll: true, paste: true)),
        super(key: key);

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;
  final String? placeholder;
  final TextStyle? placeholderStyle;
  final String? header;
  final TextStyle? headerStyle;
  final Widget? outsidePrefix;
  final Widget? prefix;
  final OverlayVisibilityMode prefixMode;
  final OverlayVisibilityMode outsidePrefixMode;
  final Widget? outsideSuffix;
  final Widget? suffix;
  final OverlayVisibilityMode suffixMode;
  final OverlayVisibilityMode outsideSuffixMode;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final ToolbarOptions toolbarOptions;
  final TextAlignVertical? textAlignVertical;
  final bool readOnly;
  final bool? showCursor;
  final bool autofocus;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType smartDashesType;
  final SmartQuotesType smartQuotesType;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final double? minHeight;
  final bool expands;
  final int? maxLength;
  final bool maxLengthEnforced;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius cursorRadius;
  final Color? cursorColor;
  final ui.BoxHeightStyle selectionHeightStyle;
  final ui.BoxWidthStyle selectionWidthStyle;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool enableInteractiveSelection;
  final DragStartBehavior dragStartBehavior;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  bool get selectionEnabled => enableInteractiveSelection;
  final GestureTapCallback? onTap;
  final Iterable<String>? autofillHints;
  final String? restorationId;
  final ButtonThemeData? iconButtonThemeData;

  @override _TextBoxState createState() => _TextBoxState();
  @override void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TextEditingController>('controller', controller,
          defaultValue: null))
      ..add(DiagnosticsProperty<FocusNode>('focusNode', focusNode,
          defaultValue: null))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding))
      ..add(StringProperty('placeholder', placeholder))
      ..add(
          DiagnosticsProperty<TextStyle>('placeholderStyle', placeholderStyle))
      ..add(DiagnosticsProperty<OverlayVisibilityMode>(
          'prefix', prefix == null ? null : prefixMode))
      ..add(DiagnosticsProperty<OverlayVisibilityMode>(
          'suffix', suffix == null ? null : suffixMode))
      ..add(DiagnosticsProperty<TextInputType>('keyboardType', keyboardType,
          defaultValue: TextInputType.text))
      ..add(DiagnosticsProperty<TextStyle>('style', style, defaultValue: null))
      ..add(FlagProperty('autofocus',
          value: autofocus, ifFalse: 'manual focus', defaultValue: false))
      ..add(StringProperty('obscuringCharacter', obscuringCharacter,
          defaultValue: '•'))
      ..add(DiagnosticsProperty<bool>('obscureText', obscureText,
          defaultValue: false))
      ..add(DiagnosticsProperty<bool>('autocorrect', autocorrect,
          defaultValue: true))
      ..add(EnumProperty<SmartDashesType>('smartDashesType', smartDashesType,
          defaultValue:
              obscureText ? SmartDashesType.disabled : SmartDashesType.enabled))
      ..add(EnumProperty<SmartQuotesType>('smartQuotesType', smartQuotesType,
          defaultValue:
              obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled))
      ..add(DiagnosticsProperty<bool>('enableSuggestions', enableSuggestions,
          defaultValue: true))
      ..add(IntProperty('maxLines', maxLines, defaultValue: 1))
      ..add(IntProperty('minLines', minLines, defaultValue: null))
      ..add(DiagnosticsProperty<bool>('expands', expands, defaultValue: false))
      ..add(IntProperty('maxLength', maxLength, defaultValue: null))
      ..add(FlagProperty('maxLengthEnforced',
          value: maxLengthEnforced, ifTrue: 'max length enforced'))
      ..add(DoubleProperty('cursorWidth', cursorWidth, defaultValue: 2.0))
      ..add(DoubleProperty('cursorHeight', cursorHeight, defaultValue: null))
      ..add(DiagnosticsProperty<Radius>('cursorRadius', cursorRadius,
          defaultValue: null))
      ..add(FlagProperty(
        'selectionEnabled',
        value: selectionEnabled,
        defaultValue: true,
        ifFalse: 'selection disabled',
      ))
      ..add(DiagnosticsProperty<ScrollController>(
        'scrollController',
        scrollController,
        defaultValue: null,
      ))
      ..add(DiagnosticsProperty<ScrollPhysics>(
        'scrollPhysics',
        scrollPhysics,
        defaultValue: null,
      ))
      ..add(EnumProperty<TextAlign>('textAlign', textAlign,
          defaultValue: TextAlign.start))
      ..add(DiagnosticsProperty<TextAlignVertical>(
        'textAlignVertical',
        textAlignVertical,
        defaultValue: null,
      ));
  }
}

class _TextBoxState extends State<FluentTextBox>
    with RestorationMixin, AutomaticKeepAliveClientMixin
    implements TextSelectionGestureDetectorBuilderDelegate {
  final GlobalKey _clearGlobalKey = GlobalKey();

  RestorableTextEditingController? _controller;
  TextEditingController get _effectiveController =>
      widget.controller ?? _controller!.value;

  FocusNode? _focusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());

  bool _showSelectionHandles = false;

  late _TextBoxSelectionGestureDetectorBuilder _selectionGestureDetectorBuilder;

  @override
  bool get forcePressEnabled => true;

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get selectionEnabled => widget.selectionEnabled;

  bool get enabled => widget.enabled ?? true;

  @override
  void initState() {
    super.initState();
    _selectionGestureDetectorBuilder =
        _TextBoxSelectionGestureDetectorBuilder(state: this);
    if (widget.controller == null) {
      _createLocalController();
    }
    _effectiveFocusNode.addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    if (!enabled && _effectiveFocusNode.hasPrimaryFocus) {
      _effectiveFocusNode.nextFocus();
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(FluentTextBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null) {
      _createLocalController(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      unregisterFromRestoration(_controller!);
      _controller!.dispose();
      _controller = null;
    }
    final bool isEnabled = widget.enabled ?? true;
    final bool wasEnabled = oldWidget.enabled ?? true;
    if (wasEnabled && !isEnabled) {
      _effectiveFocusNode.unfocus();
    }
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) {
      _registerController();
    }
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
    _controller!.value.addListener(updateKeepAlive);
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? RestorableTextEditingController()
        : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  @override
  String? get restorationId => widget.restorationId;

  bool get showActiveBorder => _effectiveFocusNode.hasFocus;

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChanged);
    _focusNode?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  EditableTextState? get _editableText => editableTextKey.currentState;

  void _requestKeyboard() {
    _editableText?.requestKeyboard();
  }

  bool _shouldShowSelectionHandles(SelectionChangedCause? cause) {
    if (!_selectionGestureDetectorBuilder.shouldShowSelectionToolbar) {
      return false;
    }

    if (_effectiveController.selection.isCollapsed) return false;

    if (cause == SelectionChangedCause.keyboard) return false;

    if (_effectiveController.text.isNotEmpty) return true;

    return false;
  }

  void _handleSelectionChanged(
      TextSelection selection, SelectionChangedCause? cause) {
    if (cause == SelectionChangedCause.longPress) {
      _editableText?.bringIntoView(selection.base);
    }
    final bool willShowSelectionHandles = _shouldShowSelectionHandles(cause);
    if (willShowSelectionHandles != _showSelectionHandles) {
      setState(() {
        _showSelectionHandles = willShowSelectionHandles;
      });
    }
  }

  @override
  bool get wantKeepAlive => _controller?.value.text.isNotEmpty == true;

  bool _shouldShowAttachment({
    required OverlayVisibilityMode attachment,
    required bool hasText,
  }) {
    switch (attachment) {
      case OverlayVisibilityMode.never:
        return false;
      case OverlayVisibilityMode.always:
        return true;
      case OverlayVisibilityMode.editing:
        return hasText;
      case OverlayVisibilityMode.notEditing:
        return !hasText;
    }
  }

  bool _showOutsidePrefixWidget(TextEditingValue text) {
    return widget.outsidePrefix != null &&
        _shouldShowAttachment(
          attachment: widget.outsidePrefixMode,
          hasText: text.text.isNotEmpty,
        );
  }

  bool _showPrefixWidget(TextEditingValue text) {
    return widget.prefix != null &&
        _shouldShowAttachment(
          attachment: widget.prefixMode,
          hasText: text.text.isNotEmpty,
        );
  }

  bool _showSuffixWidget(TextEditingValue text) {
    return widget.suffix != null &&
        _shouldShowAttachment(
          attachment: widget.suffixMode,
          hasText: text.text.isNotEmpty,
        );
  }

  bool _showOutsideSuffixWidget(TextEditingValue text) {
    return widget.outsideSuffix != null &&
        _shouldShowAttachment(
          attachment: widget.outsideSuffixMode,
          hasText: text.text.isNotEmpty,
        );
  }

  bool get _hasDecoration {
    return widget.placeholder != null ||
        widget.prefix != null ||
        widget.suffix != null;
  }

  TextAlignVertical get _textAlignVertical {
    return widget.textAlignVertical ?? TextAlignVertical.top;
  }

  Widget _addTextDependentAttachments(
    Widget editableText,
    TextStyle textStyle,
    TextStyle placeholderStyle,
  ) {
    if (!_hasDecoration) {
      return editableText;
    }

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _effectiveController,
      child: editableText,
      builder: (BuildContext context, TextEditingValue text, Widget? child) {
        final result = Stack(children: <Widget>[
          if (widget.placeholder != null && text.text.isEmpty)
            Container(
              width: double.infinity,
              padding: widget.padding,
              child: Text(
                widget.placeholder!,
                maxLines: widget.maxLines,
                overflow: TextOverflow.ellipsis,
                style: placeholderStyle,
                textAlign: widget.textAlign,
              ),
            ),
          if (child != null) child,
        ]);
        // if (!_showPrefixWidget(text) && !_showSuffixWidget(text)) return result;
        return Row(children: <Widget>[
          if (_showPrefixWidget(text)) widget.prefix!,
          Expanded(child: result),
          if (_showSuffixWidget(text))
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: widget.suffix!,
            ),
        ]);
      },
    );
  }

  static Color fluentComboBoxColor(bool isDark, bool focus) => isDark ? 
      focus ? const ColorConst.withOpacity(0x202020, 0.4) : const ColorConst.withOpacity(0x888888, 0.1) :
      focus ? const ColorConst.withOpacity(0xFFFFFF, 0.8) : const ColorConst.withOpacity(0xfafafa, 0.2);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    assert(debugCheckHasDirectionality(context));
    assert(debugCheckHasFluentTheme(context));
    final ThemeData theme = FluentTheme.of(context);
    final TextEditingController controller = _effectiveController;
    final List<TextInputFormatter> formatters =
        widget.inputFormatters ?? <TextInputFormatter>[];
    const Offset cursorOffset = Offset(0, -1);
    if (widget.maxLength != null && widget.maxLengthEnforced) {
      formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));
    }

    final TextStyle textStyle = TextStyle(
      color: enabled ? theme.inactiveColor : theme.disabledColor,
    );

    final Brightness keyboardAppearance =
        widget.keyboardAppearance ?? theme.brightness;
    final Color cursorColor = theme.inactiveColor;
    final Color disabledColor = theme.disabledColor;
    final Color backgroundColor = fluentComboBoxColor(theme.brightness.isDark, _effectiveFocusNode.hasFocus);

    final TextStyle placeholderStyle = widget.placeholderStyle ??
        textStyle.copyWith(
          color: !enabled
              ? theme.brightness.isLight
                  ? const Color.fromRGBO(0, 0, 0, 0.3614)
                  : const Color.fromRGBO(255, 255, 255, 0.3628)
              : theme.brightness.isLight
                  ? const Color.fromRGBO(0, 0, 0, 0.6063)
                  : const Color.fromRGBO(255, 255, 255, 0.786),
          fontWeight: FontWeight.w400,
        );

    final Color selectionColor = theme.accentColor.withOpacity(0.2);

    final Widget paddedEditable = Padding(
      padding: widget.padding,
      child: RepaintBoundary(
        child: UnmanagedRestorationScope(
          bucket: bucket,
          child: EditableText(
            key: editableTextKey,
            controller: controller,
            readOnly: widget.readOnly,
            toolbarOptions: widget.toolbarOptions,
            showCursor: widget.showCursor,
            showSelectionHandles: _showSelectionHandles,
            focusNode: _effectiveFocusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            style: textStyle,
            strutStyle: widget.strutStyle,
            textAlign: widget.textAlign,
            autofocus: widget.autofocus,
            obscuringCharacter: widget.obscuringCharacter,
            obscureText: widget.obscureText,
            autocorrect: widget.autocorrect,
            smartDashesType: widget.smartDashesType,
            smartQuotesType: widget.smartQuotesType,
            enableSuggestions: widget.enableSuggestions,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            expands: widget.expands,
            selectionColor: selectionColor,
            onChanged: widget.onChanged,
            onSelectionChanged: _handleSelectionChanged,
            onEditingComplete: widget.onEditingComplete,
            onSubmitted: widget.onSubmitted,
            inputFormatters: formatters,
            rendererIgnoresPointer: true,
            cursorWidth: widget.cursorWidth,
            cursorHeight: widget.cursorHeight,
            cursorRadius: widget.cursorRadius,
            cursorColor: cursorColor,
            cursorOpacityAnimates: true,
            cursorOffset: cursorOffset,
            paintCursorAboveText: false,
            autocorrectionTextRectColor: selectionColor,
            backgroundCursorColor: disabledColor,
            selectionHeightStyle: widget.selectionHeightStyle,
            selectionWidthStyle: widget.selectionWidthStyle,
            scrollPadding: widget.scrollPadding,
            keyboardAppearance: keyboardAppearance,
            dragStartBehavior: widget.dragStartBehavior,
            scrollController: widget.scrollController,
            scrollPhysics: widget.scrollPhysics,
            enableInteractiveSelection: widget.enableInteractiveSelection,
            autofillHints: widget.autofillHints,
            restorationId: 'editable',
            selectionControls: fluentTextSelectionControls,
          ),
        ),
      ),
    );

    final radius = BorderRadius.circular(4.0);
    final child = Semantics(
      enabled: enabled,
      onTap: !enabled
          ? null
          : () {
              if (!controller.selection.isValid) {
                controller.selection =
                    TextSelection.collapsed(offset: controller.text.length);
              }
              _requestKeyboard();
            },
      child: IgnorePointer(
        ignoring: !enabled,
        child: AnimatedContainer(
          duration: theme.fasterAnimationDuration,
          curve: theme.animationCurve,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
                width: 1,
                color: theme.brightness.isLight
                    ? const Color.fromRGBO(0, 0, 0, 0.08)
                    : const Color.fromRGBO(255, 255, 255, 0.07)),
            color: enabled
                ? backgroundColor
                : theme.brightness.isLight
                    ? const Color.fromRGBO(249, 249, 249, 0.3)
                    : const Color.fromRGBO(255, 255, 255, 0.04),
          ),
          foregroundDecoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _effectiveFocusNode.hasFocus
                    ? theme.accentColor
                    : !enabled
                        ? Colors.transparent
                        : theme.brightness.isLight
                            ? const Color.fromRGBO(0, 0, 0, 0.45)
                            : const Color.fromRGBO(255, 255, 255, 0.54),
                width: _effectiveFocusNode.hasFocus ? 2 : 0,
              ),
            ),
          ),
          constraints: BoxConstraints(minHeight: widget.minHeight ?? 0),
          child: _selectionGestureDetectorBuilder.buildGestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Align(
              alignment: AlignmentDirectional(-1.0, _textAlignVertical.y),
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: _addTextDependentAttachments(
                paddedEditable,
                textStyle,
                placeholderStyle,
              ),
            ),
          ),
        ),
      ),
    );

    Widget listener = ValueListenableBuilder<TextEditingValue>(
      valueListenable: _effectiveController,
      child: () {
        /// This has to be done this way because [ClipRRect] doesn't allow
        /// [Clip.none] as a value to [clipBehavior]
        if (widget.clipBehavior == Clip.none) return child;
        return ClipRRect(
          clipBehavior: widget.clipBehavior,
          borderRadius: radius,
          child: child,
        );
      }(),
      builder: (context, text, child) {
        if (!_showOutsidePrefixWidget(text) &&
            !_showOutsideSuffixWidget(text)) {
          return child!;
        }
        return Row(children: [
          if (_showOutsidePrefixWidget(text)) widget.outsidePrefix!,
          Expanded(child: child!),
          if (_showOutsideSuffixWidget(text)) widget.outsideSuffix!,
        ]);
      },
    );

    return ButtonTheme.merge(
      data: widget.iconButtonThemeData ?? const ButtonThemeData(),
      child: IconTheme.merge(
        data: const IconThemeData(size: 14),
        child: SmallIconButton(
          child: () {
            if (widget.header != null) {
              return InfoLabel(
                child: listener,
                label: widget.header!,
                labelStyle: widget.headerStyle,
              );
            }
            return listener;
          }(),
        ),
      ),
    );
  }
}