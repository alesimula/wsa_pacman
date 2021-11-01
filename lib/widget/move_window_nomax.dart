// ignore_for_file: camel_case_types

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/widgets.dart';

///The double click gesture detector adds a time overhead on any widget's click actions, this class only implements window dragging
class _MoveWindowNoMaximize extends StatelessWidget {
  final bool dragBlocker;
  final Widget child;
  const _MoveWindowNoMaximize(this.dragBlocker, {Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) => GestureDetector(
    child: child,
    behavior: dragBlocker ? HitTestBehavior.opaque : HitTestBehavior.translucent, 
    onPanStart: dragBlocker ? (_){} : (_){appWindow.startDragging();}
  );
}

class moveWindow extends _MoveWindowNoMaximize {
  ///Makes the window draggable on dragging the child view
  const moveWindow(Widget child, {Key? key}) : super(false, child: child, key: key);
}

class noMoveWindow extends _MoveWindowNoMaximize {
  ///Creates a non-draggable zone inside a draggable window
  const noMoveWindow(Widget child, {Key? key}) : super(true, child: child, key: key);
}
