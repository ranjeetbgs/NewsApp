import 'package:flutter/material.dart';
import 'anim_util.dart';

class DoneAnimatedIcon extends StatelessWidget {
  const DoneAnimatedIcon({super.key,this.size,this.icon,this.color});
  final double? size;
  final Widget? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AnimationFadeScale(
      child: CircleAvatar(
        radius:size ?? 12,
        backgroundColor: color ?? Colors.green,
        child:icon  ??  const Icon(
          Icons.done,
          size: 16.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
