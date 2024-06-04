import 'package:flutter/cupertino.dart';

class PagingTransform extends PageRouteBuilder {
  final Widget widget;
  final double dx, dy;
  final int? duration;
  final bool slideUp, isReverseSlide;

  PagingTransform(
      {required this.widget,
      this.duration,
      this.slideUp = false,
      this.isReverseSlide = false,
      isScale = false,
      this.dy = 0,
      this.dx = 1})
      : super(
            transitionDuration: Duration(milliseconds: duration ?? 400),
            reverseTransitionDuration: Duration(milliseconds: duration ?? 400),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secAnimation,
                Widget child) {
              return AnimatedSwitcher(
                  key: ValueKey(animation),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  duration: Duration(milliseconds: duration ?? 250),
                  child: isScale == true
                      ? ScaleTransition(
                          scale: animation,
                          child: child,
                        )
                      : animation.status == AnimationStatus.reverse &&
                              isReverseSlide == true
                          ? SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(-dx, -dy),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            )
                          : SlideTransition(
                              position: Tween<Offset>(
                                begin: slideUp == true
                                    ? Offset(0, dy)
                                    : Offset(dx, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                  opacity: animation, child: child),
                            ));
            },
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secAnimation) {
              return widget;
            },
            opaque: false);
}
