import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/utils/image_util.dart';
import 'package:incite/utils/theme_util.dart';

import '../utils/color_util.dart';
class CustomLoader extends StatefulWidget {
  const CustomLoader({super.key,this.color,this.opacity,this.isLoading=false,required this.child});
  final Color? color;
  final Widget child;
  final double? opacity;
  final bool isLoading;

  @override
  // ignore: library_private_types_in_public_api
  _CustomLoaderState createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>{
 
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
       widget.child,
       widget.isLoading==false ? const SizedBox() :  Stack(children: <Widget>[
                Opacity(
                  opacity: widget.opacity ?? 0.6,
                  child: ModalBarrier(
                    dismissible: false,
                    color: dark(context) ? widget.color ?? Colors.grey.shade800 : ColorUtil.blackGrey,
                  ),
                ),
               const Center(child: MotionLogo(),
            ),
          ],
        ),
      ],
    );
  }
}

class MotionLogo extends StatefulWidget {
  const MotionLogo({
    super.key,
    this.decochild,
  }) ;  
 final Widget? decochild;

  @override
  State<MotionLogo> createState() => _MotionLogoState();
}

class _MotionLogoState extends State<MotionLogo>  with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _animation2;
  @override
  void initState() {
    super.initState();

    // Configure the animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    // Configure the animation
    _animation = Tween<double>(begin:widget.decochild != null  ? 0.5 : 0.0, end: 1.0).animate(_animationController);
     _animation2 = Tween<double>(begin:widget.decochild != null  ? 0.94 : 0.85, end: 1.0).animate(_animationController);
  }

   @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
     animation: _animation,
     builder: (context, child) {
       return ScaleTransition(   
         scale: _animation2,
         child: Container(
           width: widget.decochild != null  ? 50: 90,
           height: widget.decochild != null  ? 50: 90, 
           decoration: BoxDecoration(
               color:Colors.white,
               // Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor :
              //  Theme.of(context).primaryColor,
             borderRadius: BorderRadius.circular(widget.decochild != null  ?16 :100.0),
            //  border: Border.all(
            //    color: Theme.of(context).primaryColor.withOpacity(0.5),
            //    width: lerpDouble(2.0, 4.0, _animation.value)!,
            //  ),
           ),
           child: Center(
             child:Container(
                      width:widget.decochild != null  ? 50: 70,
                      height: widget.decochild != null  ? 50:70,
                      decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(widget.decochild != null  ? 16 :100.0),
             border: Border.all(
               color: Theme.of(context).primaryColor.withOpacity(0.7),
               width: lerpDouble(1.0, 2.0, _animation.value)!,
             ),
             ),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: ClipRRect(
                   borderRadius: BorderRadius.circular(widget.decochild != null  ? 16 :100.0),
                  child: widget.decochild ?? (allSettings.value.baseImageUrl != null && allSettings.value.appLogo != null ?
                   CachedNetworkImage(
                    imageUrl: "${allSettings.value.baseImageUrl}/${allSettings.value.appLogo}")
                  : Image.asset(Img.logo)),
                ),
              )
            )
           ),
         ),
       );
     },
   );
  }
}
