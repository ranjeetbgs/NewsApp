import 'package:flutter/material.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/anim_util.dart';

class ElevateButton extends StatelessWidget {
  final VoidCallback onTap;
  final TextStyle? style;
  final double? width;
  final String text;
  final Color? color,splash;
  final Widget? leadIcon,widget;

  const ElevateButton({super.key,this.widget,this.width,this.splash,this.color,this.leadIcon,required this.onTap,this.text='Get Started',this.style});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AnimationFadeSlide(
       dy: 0.75,
       dx: 0,
      child: Material(
        color: Colors.transparent,
           borderRadius: BorderRadius.circular(32),
        elevation: isBlack(Theme.of(context).primaryColor) && dark(context)? 8:0,
        shadowColor: isBlack(Theme.of(context).primaryColor) && dark(context)? Colors.white12:Theme.of(context).primaryColor,
        child: InkWell(
          splashColor:splash ?? Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(32),
          onTap:onTap,
          child: Ink(
            width: width ?? size.width,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(32),
              gradient:color!=null  ? null  : LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
              Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary
              ])
            ),
            child:widget ?? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leadIcon ?? const SizedBox(),
                SizedBox(width: leadIcon != null ? 12 : 0),
                Text(text ,style: style ?? const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w400
                )),
              ],
            )
          ),
        ),
      ),
    );
  }
}


class IconTextButton extends StatelessWidget {
  final VoidCallback onTap;
  final TextStyle? style;
  final double? width;
  final String text;
  final Color? color,splash;
  final Widget? leadIcon,trailIcon;
  final EdgeInsetsGeometry? padding;

  const IconTextButton({super.key,
  this.trailIcon,
  this.width,
  this.padding,
  this.splash,
  this.color,
  this.leadIcon,
  required this.onTap,
  this.text='Get Started',
  this.style});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor:splash ?? Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(32),
        onTap:onTap,
        child: Ink(
          width: width,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(32),
            gradient:color!=null  ? null  : primaryGradient(context)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              leadIcon ?? const SizedBox(),
              SizedBox(width: leadIcon != null ? 12 : 0),
              Text(text ,style: style ?? const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w400
              )),
              SizedBox(width: trailIcon != null ? 12 : 0),
               trailIcon ?? const SizedBox(),
            ],
          )
        ),
      ),
    );
  }
}