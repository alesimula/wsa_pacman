import 'dart:math' hide log;
import 'package:fluent_ui/fluent_ui.dart';

//Display an Android adaptive icon
//TODO not immutable
class AdaptiveIcon extends StatelessWidget {
  static const double _scale = 1.5;
  final double radius;
  Color? backColor;
  Widget? background;
  Widget? foreground;

  AdaptiveIcon({Key? key, this.radius = 0.6, this.background, this.foreground, this.backColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FractionallySizedBox(
        heightFactor: 1,
        widthFactor: 1,
        child: LayoutBuilder(
          builder: (context, BoxConstraints constraints) {
            final borderRadius = min(constraints.maxWidth, constraints.maxHeight) * radius/2;
            return Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: AspectRatio (
                    aspectRatio: 1,
                    child:  ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: (background != null) ?
                        FractionallySizedBox(heightFactor: _scale, widthFactor: _scale, child: background) :
                        DecoratedBox(decoration: BoxDecoration(color: backColor ?? Colors.white)),
                    ),
                  )
                ),
                Center(
                  child: AspectRatio (
                    aspectRatio: 1,
                    child:  ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: FractionallySizedBox(heightFactor: _scale, widthFactor: _scale, child: foreground),
                    ),
                  )
                )
                /*child: Transform.scale(
                    alignment: Alignment.center,
                    scale: 1.5,*/
              ],
            );
          }
        ),
      )
    );
  }
}