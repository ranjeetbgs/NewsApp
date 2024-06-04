
import 'package:flutter/material.dart';
import 'package:incite/widgets/tap.dart';

import '../utils/color_util.dart';

class Backbut extends StatelessWidget {
  const Backbut({
    super.key,
    this.onTap,
    this.color,
    this.backColor,
  });

  final VoidCallback? onTap;
  final Color? backColor,color;

  @override
  Widget build(BuildContext context) {
    return TapInk(
     onTap: onTap ?? () {
       Navigator.pop(context);
     },
     pad: 4,
    radius: 100,
       child: CircleAvatar(
         radius: 20,
         backgroundColor: backColor ?? ColorUtil.whiteGrey,
         child: Icon(Icons.keyboard_arrow_left_rounded,
         size: 28,
         color: color ?? ColorUtil.textblack),
       ),
     );
  }
}