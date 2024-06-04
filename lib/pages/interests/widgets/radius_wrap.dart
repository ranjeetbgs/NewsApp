import 'package:flutter/material.dart'; 
import 'package:incite/utils/color_util.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/anim_util.dart';
import 'package:incite/widgets/tap.dart';
import '../../../widgets/anim.dart';

class RadiusBox extends StatelessWidget {
  const RadiusBox({super.key,required this.title,this.isGradient=false,this.dur=100,this.padding,this.onTap,this.isSelected=false,this.color,this.index=1});
  final String title;
  final bool isSelected,isGradient;
   final int index,dur;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap; 
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return    AnimationFadeSlide(
      duration: dur*index,
      child: AnimatedContainer(
          duration:const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected  ? ColorUtil.textblack :  dark(context) ? Theme.of(context).cardColor :  ColorUtil.whiteGrey,
            borderRadius: BorderRadius.circular(100),
            
            gradient: isGradient  ? LinearGradient(
              begin: Alignment.topLeft,
             end: Alignment.bottomRight,
             stops: const [0.0000000001,1],
              colors: [
               dark(context) ? isSelected ?  color != null ?  generateShades(color ?? Colors.white, 2) : 
               Theme.of(context).colorScheme.secondary:ColorUtil.blackGrey :
                isSelected ?  color != null ? color!.withOpacity(0.4) : Theme.of(context).primaryColor :Colors.white,
                isSelected ? color ?? Theme.of(context).primaryColor : dark(context) ? ColorUtil.blackGrey : ColorUtil.white
             ]) : null
          ),
          child: TapInk(
            radius : 100,
            onTap : onTap ?? () {
          
           },
            child:Padding(
            padding: padding   ?? const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  // shadows: const [
                  //   BoxShadow(
                  //     offset: Offset(0, 0.2),
                  //     spreadRadius: -4,
                  //     blurRadius: 14,
                  //     color: Colors.black26
                  //   )
                  // ],
                  color: isSelected==false ?  dark(context) ? ColorUtil.white  : ColorUtil.textblack : Colors.white,
                ),),
                const SizedBox(width: 6),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 1,color: 
                  isSelected ?Colors.white : ColorUtil.textgrey)
                  ),
                  child: AnimateIcon(
                    child: isSelected==false ? const Icon( null,key:ValueKey(67) ): Icon(Icons.done_rounded,
                    key:const ValueKey(76),
                    size: 12,
                    color: isSelected ? Colors.white : ColorUtil.textgrey),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  } 

Color generateShades(Color color, int steps) {
  final List<Color> shades = [];

  for (int i = 1; i <= steps; i++) {
    final double fraction = i / steps;
    final Color? shadeColor = Color.lerp(Colors.white, color, fraction);

    shades.add(shadeColor!);
  }

  return shades.first;
}
}