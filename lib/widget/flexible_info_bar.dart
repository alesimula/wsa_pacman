import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:wsa_pacman/widget/fluent_info_bar.dart';
import 'package:wsa_pacman/widget/smooth_list_view.dart';

class FlexibleInfoBar extends StatelessWidget {

  const FlexibleInfoBar({
    Key? key,
    required this.title,
    this.content,
    this.action,
    this.severity = InfoBarSeverity.info,
    this.style,
    this.onClose,
  }) : super(key: key);

  final InfoBarSeverity severity;
  final InfoBarThemeData? style;
  final Widget title;
  final Widget? content;
  final Widget? action;
  final void Function()? onClose;

  @override
  Widget build(BuildContext context) {
    return Flexible(child: LayoutBuilder(
      builder: (context, BoxConstraints constraints) {
        return FluentInfoBar(
          title: SizedBox(
            height: (constraints.maxHeight-25),// - (constraints.maxHeight-constr.maxHeight),
            child: material.Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _PaddedTitle(DefaultTextStyle(
                style: FluentTheme.of(context).typography.bodyStrong ?? const TextStyle(),
                child: title,
              )),
              body: (content != null) ? SmoothListView(children: [DefaultTextStyle(
                style: FluentTheme.of(context).typography.body ?? const TextStyle(),
                child: content!,
                softWrap: true,
              )]) : null
            )
          ),
          isLong: true,
          severity: severity,
          style: style,
          action: action,
          onClose: onClose,
        );
      }
    ));
  }
}


class _PaddedTitle extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;

  const _PaddedTitle(this.child);

  @override
  Widget build(BuildContext context) {
    double? infoBarPadding = InfoBarTheme.of(context).padding?.vertical;
    if (infoBarPadding != null) infoBarPadding /= 2;
    return Padding(padding: EdgeInsets.only(bottom: infoBarPadding ?? 10), child: child);
  }

  @override
  Size get preferredSize => const Size.fromHeight(double.maxFinite);
}