 // ignore_for_file: library_private_types_in_public_api

 import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/utils/image_util.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/anim_util.dart';
import 'package:incite/widgets/tap.dart';
import '../api_controller/user_controller.dart';
import 'done.dart';

void showCustomToast(BuildContext context, String message,{String? text,VoidCallback? onTap,bool isSuccess = true,islogo = true}) {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: kToolbarHeight,
        height: 70,
        width: MediaQuery.of(context).size.width,
        child: CustomToast(
          message: message,
          buttonText: text,
          onPressed: onTap,
          isLogo: islogo,
          isSuccess :isSuccess,
          onDismiss: () {
            overlayEntry!.remove();
          },
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }


class CustomToast extends StatefulWidget {
  final String message;
  final String? buttonText;
  final VoidCallback onDismiss;
  final bool isSuccess;
  final VoidCallback? onPressed;
  final bool isLogo;

  const CustomToast({Key? key,
  required this.message,
  this.buttonText,
  this.onPressed,
  this.isLogo=true,
  required this.onDismiss,  
  this.isSuccess=false
  }) : super(key: key);

  @override
  State<CustomToast> createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      lowerBound: 0.5,
      upperBound: 1.0
    );
    _animation = CurvedAnimation(parent: _animationController, curve: const Cubic(0.2, 0.6, 0.1, 1));
    _animationController.forward();
    _animationController.addStatusListener((status) {
      statusListen(status);
    });
  }

  void statusListen(AnimationStatus status) {
    if (mounted) {
      if (status == AnimationStatus.completed) {
      Future.delayed(const Duration(seconds: 2)).whenComplete(() {
          _animationController.reverse().whenComplete(() {
          widget.onDismiss.call();
         });
      });
    }
    }
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(statusListen);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  AnimationFadeSlide(
        dy: -0.6,
        dx: 0,
        duration: 200,
        child: AnimationFadeScale(
        duration: 300,
        child:AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
         opacity:  _animation.value,
         curve: const Cubic(0.2, 0.6, 0.1, 1),
          //  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6.0),
          //  decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(0)
          //  ),
          child: Container(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () {
                _animationController.reverse().then((value) {
                  widget.onDismiss.call();
                });
              },
              child: Material(
                borderRadius:  BorderRadius.circular(100),
                elevation: 16.0,
                color: Theme.of(context).cardColor,
                shadowColor: ColorUtil.textblack.withOpacity(0.7),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       const SizedBox(width: 12),
                       if (widget.isLogo == true) 
                      allSettings.value.baseImageUrl != null && allSettings.value.appLogo != null ?
                   CachedNetworkImage(
                    imageUrl: "${allSettings.value.baseImageUrl}/${allSettings.value.appLogo}",
                    width: 20,height: 20,placeholder: (context, url) {
                      return Image.asset(Img.logo,width: 20,height: 20); 
                    },errorWidget: (context, url, error) {
                        return Image.asset(Img.logo,width: 20,height: 20); 
                    },)
                  : Image.asset(Img.logo,width: 20,height: 20)
                        else DoneAnimatedIcon(
                        color: widget.isSuccess ? Colors.green : Colors.red,
                        icon: widget.isSuccess ? null : const Icon(
                          Icons.close_rounded,
                          size: 16.0,
                          color: Colors.white,
                        ),
                      ),
                     const SizedBox(width: 8),
                      Text(
                        widget.message,
                        style:  TextStyle(fontSize: 13.0,
                        fontFamily: 'Roboto',
                        color: dark(context) ? ColorUtil.white : ColorUtil.textblack,
                        fontWeight: FontWeight.w500),
                      ),
                      widget.buttonText == null ?  const SizedBox() :  const SizedBox(width: 3),
                    widget.buttonText == null ?  const SizedBox() :
                     Expanded(
                       child: TapInk(onTap: () {
                         widget.onPressed!.call();
                         widget.onDismiss.call();
                       } , child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          child: Text(widget.buttonText ?? '',
                          style: const TextStyle(
                            fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Roboto'),),
                        )),
                     ),   const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}