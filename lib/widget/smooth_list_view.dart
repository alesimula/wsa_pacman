import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class SmoothListView extends DynMouseScroll {
  SmoothListView({
    // Dynamic mouse scroll params
    super.key,
    super.durationMS = 380,
    super.scrollSpeed = 2,
    super.animationCurve = Curves.easeOutQuart,
    // ListView params
    Key? innerListViewKey,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    bool? primary,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    double? itemExtent,
    Widget? prototypeItem,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? cacheExtent,
    List<Widget> children = const <Widget>[],
    int? semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    String? restorationId,
    Clip clipBehavior = Clip.hardEdge,
  }) : super(
    builder: (context, controller, physics) => ListView(
      key: innerListViewKey,
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap : shrinkWrap,
      padding: padding,
      itemExtent: itemExtent,
      prototypeItem: prototypeItem,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: cacheExtent,
      children: children,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior
    )
  );
}