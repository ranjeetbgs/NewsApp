import 'package:flutter/cupertino.dart';

class AnimateIcon extends StatefulWidget {
  const AnimateIcon({Key? key, this.curve, required this.child, this.duration})
      : super(key: key);
  final Widget child;
  final Curve? curve;
  final Duration? duration;
  @override
  State<AnimateIcon> createState() => _AnimateIconState();
}

class _AnimateIconState extends State<AnimateIcon> {
  Widget defaultLayoutBuilder(
      Widget currentChild, List<Widget> previousChildren) {
    List<Widget> children = previousChildren;
    children = children.toList()..add(currentChild);
    return Stack(alignment: Alignment.center, children: children);
  }

  // static bool canUpdate(Widget oldWidget, Widget newWidget) {
  //   return oldWidget.runtimeType == newWidget.runtimeType &&
  //       oldWidget.key == newWidget.key;
  // }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      switchInCurve: widget.curve ?? const Interval(0.65, 1),
      duration: widget.duration ?? const Duration(milliseconds: 150),
      child: widget.child,
      layoutBuilder: (currentChild, previousChildren) {
        return defaultLayoutBuilder(currentChild!, previousChildren);
      },
      transitionBuilder: (child, animation) {
        // final offsetAnimation = Tween<Offset>(
        //         begin: const Offset(0.0, 0.0), end: const Offset(0.0, -1.0))
        //     .animate(animation);
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}
