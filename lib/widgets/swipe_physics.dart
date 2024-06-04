
import 'package:flutter/material.dart';
import 'package:incite/api_controller/user_controller.dart';
class CustomScrollPhysics extends PageScrollPhysics {
  final double? dragStartDistanceMotionThres
  , minFlingVelo
  , minFlingDis
  , maxFlingVelo,ratio,mass,stiffness;

  const CustomScrollPhysics({ScrollPhysics? parent,
  required this.maxFlingVelo,
  required  this.minFlingDis,
  required this.minFlingVelo,
  required this.dragStartDistanceMotionThres,
  this.ratio,
  this.mass,
  this.stiffness,
}) : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(
      parent: buildParent(ancestor),
      maxFlingVelo: scrollConfig.value.maxFlingVelocity,
      minFlingDis: scrollConfig.value.minFlingDistance,
      minFlingVelo: scrollConfig.value.minFlingVelocity,
      dragStartDistanceMotionThres: scrollConfig.value.dragStartDistanceMotionThreshold
      );
  }

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
        mass:scrollConfig.value.mass ?? 0.5,
        stiffness: scrollConfig.value.stiffness ??100.0,
        ratio: scrollConfig.value.ratio ?? 0.8,
      );

  @override
  double get maxFlingVelocity => scrollConfig.value.maxFlingVelocity ?? 8000.0;
// Scroll fling velocity magnitudes will be clamped to this value.

  @override
  double get minFlingDistance => scrollConfig.value.minFlingDistance ??  25.0;
// The minimum distance an input pointer drag must have moved to be considered a scroll fling gesture.
// This value is typically compared with the distance traveled along the scrolling axis.

  @override
  double get minFlingVelocity => scrollConfig.value.minFlingVelocity ?? 400.0;
// The minimum velocity for an input pointer drag to be considered a scroll fling.
// This value is typically compared with the magnitude of fling gesture's velocity along the scrolling axis.
  @override
  double get dragStartDistanceMotionThreshold => scrollConfig.value.dragStartDistanceMotionThreshold ?? 5.5;
// The minimum amount of pixel distance drags must move by to start 
// motion the first time or after each time the drag motion stopped.
}

class CustomScrollPhysics2 extends PageScrollPhysics {
  const CustomScrollPhysics2({ScrollPhysics? parent}) : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(
      parent: buildParent(ancestor),
      maxFlingVelo: ancestor!.maxFlingVelocity,
      minFlingDis: ancestor.minFlingDistance,
      minFlingVelo: ancestor.minFlingVelocity,
      dragStartDistanceMotionThres: ancestor.dragStartDistanceMotionThreshold
      );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    } else if (value > position.pixels &&
        position.pixels >= position.maxScrollExtent) {
      return value - position.pixels;
    }
    if (value < position.minScrollExtent &&
        position.pixels <= position.minScrollExtent) {
      return value - position.minScrollExtent;
    } else if (value > position.maxScrollExtent &&
        position.pixels >= position.maxScrollExtent) {
      return value - position.maxScrollExtent;
    }
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity.abs() < tolerance.velocity) ||
        (velocity > 0.0 && position.pixels >= position.maxScrollExtent) ||
        (velocity < 0.0 && position.pixels <= position.minScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Simulation? simulation =
        super.createBallisticSimulation(position, velocity);
    final newPixels = simulation!.x(double.infinity);

    if (newPixels < position.minScrollExtent) {
      return ScrollSpringSimulation(
          spring, position.pixels, position.minScrollExtent, -velocity.abs());
    } else if (newPixels > position.maxScrollExtent) {
      return ScrollSpringSimulation(
          spring, position.pixels, position.maxScrollExtent, velocity.abs());
    }

    return simulation;
  }
}


class RangeMaintainingScrollPhysics extends ScrollPhysics {
  final double minScrollOffset;
  final double maxScrollOffset;

  const RangeMaintainingScrollPhysics({
    required this.minScrollOffset,
    required this.maxScrollOffset,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  RangeMaintainingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return RangeMaintainingScrollPhysics(
      minScrollOffset: minScrollOffset,
      maxScrollOffset: maxScrollOffset,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Apply any custom logic to adjust the scroll offset
    // based on user interaction, if needed
    final double newPosition = position.pixels + offset;

    if (newPosition < minScrollOffset) {
      return minScrollOffset - position.pixels;
    } else if (newPosition > maxScrollOffset) {
      return maxScrollOffset - position.pixels;
    }

    return offset;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Apply any custom boundary conditions to restrict
    // the scroll position, if needed
    return super.applyBoundaryConditions(position, value);
  }
}