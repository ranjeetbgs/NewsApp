import 'package:flutter/material.dart';

class SmoothPageScrollPhysics extends ScrollPhysics {
  const SmoothPageScrollPhysics({required ScrollPhysics parent}) : super(parent: parent);

  @override
  SmoothPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SmoothPageScrollPhysics(parent: buildParent(ancestor) as ScrollPhysics);
  }

  @override
  double get minFlingVelocity => 500.0;

  @override
  double get maxFlingVelocity => double.infinity;

  @override
  double get dragStartDistanceMotionThreshold => 3.5;

  @override
  bool get allowImplicitScrolling => true;

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    return value.clamp(position.minScrollExtent, position.maxScrollExtent);
  }
}
