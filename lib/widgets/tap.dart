import 'package:flutter/material.dart';

class TapInk extends StatelessWidget {
  const TapInk({super.key,this.radius,this.pad,this.splash,required this.child,required this.onTap});
  final Widget child;
  final double? pad;
  final VoidCallback onTap;
  final Color? splash;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(radius ?? 0),
      color: Colors.transparent ,
      child:  Ink(
        child: InkWell(  
           radius:radius!=null ? radius!*1.5 : radius,
            highlightColor:splash!=null ? splash!.withOpacity(0.3) : null,
            splashColor:splash!=null ? splash!.withOpacity(0.1 ) : null,
            borderRadius: BorderRadius.circular(radius ?? 0),
           onTap: onTap,
          child:Padding(
        padding: EdgeInsets.all(pad ?? 0),
          child: child,
          ),
        ),
      ),
    );
  }
}