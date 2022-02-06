import 'dart:math' hide log;
import 'package:fluent_ui/fluent_ui.dart';

//Display an Android adaptive icon
//TODO not immutable
class AdaptiveIcon extends StatelessWidget {
  final double _scale;
  final double radius;
  Color? backColor;
  Widget? background;
  Widget? foreground;

  AdaptiveIcon({Key? key, this.radius = 0.6, this.background, this.foreground, this.backColor, bool noScale = false}) : _scale = noScale ? 1 : 1.5 ,super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FractionallySizedBox(
        heightFactor: 1,
        widthFactor: 1,
        child: LayoutBuilder(
          builder: (context, BoxConstraints constraints) {
            final borderRadius = min(constraints.maxWidth, constraints.maxHeight) * radius/2;
            return Center(
              child: AspectRatio (
                aspectRatio: 1,
                child:  ClipRRect(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Transform.scale(scale: _scale, child: Stack(fit: StackFit.expand, children: [
                    background ?? DecoratedBox(decoration: BoxDecoration(color: backColor ?? Colors.white)),
                    foreground ?? const SizedBox(width: 0)
                  ],))
                ),
              )
            );
          }
        ),
      )
    );
  }
}