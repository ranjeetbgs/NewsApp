import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:incite/model/home.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/widgets/anim_util.dart';
import 'package:incite/widgets/drawer.dart';
import 'package:incite/widgets/tap.dart';

import '../../../api_controller/user_controller.dart';
import '../../../utils/theme_util.dart';
import '../../main/home.dart';
class ListSettingWrap extends StatelessWidget {

  const ListSettingWrap({super.key,this.model,this.pos=1,this.isOn=false,this.onTap});
  final HomeModel? model;
  final int pos;
  final bool isOn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return  Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TapInk(
        radius: 20,
        onTap: onTap ?? () {
          
        },
        child: AnimationFadeSlide(
           dx: 0.3*pos,
           duration: 100*pos,
          child: Container(
            decoration: BoxDecoration(
              color:dark(context) ? Theme.of(context).cardColor : ColorUtil.whiteGrey,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(15),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CirlceDot(radius: 40,
                border: Border.all(width: 1,color: ColorUtil.textgrey2),
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                  child: SvgPicture.asset(model!.image.toString(),
                  width: 20,height: 20,
                  color: dark(context)? ColorUtil.white: ColorUtil.textblack,),
                ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model!.title ?? 'Notificatin',style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w600
                      )),
                      const SizedBox(height: 4),
                     model!.subtitle!=null ? Text(model!.subtitle.toString(),style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                      )) :const SizedBox()
                    ],
                  ),
                ),
                 model!.isToggle==true ?  ToggleButton(isON: isOn) : const SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FontWrap extends StatefulWidget {

  const FontWrap({super.key,this.model,this.pos=1,this.isOn=false,this.onTap});
  final HomeModel? model;
  final bool isOn;
  final int pos;
  final VoidCallback? onTap;

  @override
  State<FontWrap> createState() => _FontWrapState();
}

class _FontWrapState extends State<FontWrap> {
  double slideValue1=0.0;

  @override
  Widget build(BuildContext context) {
    return  Container(
          margin: const EdgeInsets.only(bottom: 15),
          child:
        TapInk(
            radius: 20,
            onTap: widget.onTap ?? () {
              
            },
            child: AnimationFadeSlide(
               dx: 0.3*widget.pos,
               duration: 300*widget.pos,
              child: Container(
                decoration: BoxDecoration(
                  color: dark(context) ? Theme.of(context).cardColor : ColorUtil.whiteGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(15),
                child:  Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CirlceDot(radius: 40,
                        border: Border.all(width: 1,color: ColorUtil.textgrey2),
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                          child: SvgPicture.asset(widget.model!.image.toString(),
                          width: 20,height: 20,
                          color:dark(context)? ColorUtil.white: ColorUtil.textblack,),
                        ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.model!.title ?? 'Notificatin',style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.w600
                              )),
                              const SizedBox(height: 4),
                             widget.model!.subtitle!=null ? Text(widget.model!.subtitle.toString(),style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12,
                              )) :const SizedBox()
                            ],
                          ),
                        ),
                         widget.model!.isToggle==true ?  ToggleButton(isON: widget.isOn) : const SizedBox()
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: size(context).width,
                      child: Row(
                        children: [
                          const Text('A',style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20,
                            fontWeight: FontWeight.w500
                           )),
                          Expanded(
                            child:SizedBox(
                              height: 30,
                              child: MediaQuery.removePadding(
                               context: context,     
                                removeLeft: true,
                                 child: Slider(
                                  min: 16,
                                  max: 18,
                                  divisions: 6,
                                  inactiveColor:ColorUtil.white,
                                  thumbColor:Colors.black,
                                  overlayColor:const MaterialStatePropertyAll( Colors.white),
                                  activeColor: Colors.black,
                                  secondaryActiveColor: dark(context) ? Colors.grey.shade700 : Colors.white,
                                  onChanged: (value) {
                                    setState(() {
                                      defaultFontSize.value = value;
                                    });
                                  },
                                  value: defaultFontSize.value,
                                ),
                              ),
                            ),
                          ),
                           const Text('A',style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 32,
                            fontWeight: FontWeight.w500
                           )),
                        ],
                      ),
                    ),
                  ValueListenableBuilder(
                  valueListenable: defaultFontSize,
                    builder: (context,val,child) {
                      return Container(
                      height: 90,
                      alignment: Alignment.center,
                        child: Text('This is the post body dolor sit amet, consecte vitae cursus elit bibendum.',
                        maxLines: 2,
                        style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize:val
                        )),
                      );
                    }
                  )
                  ],
                ),
              ),
            ),
          ),

      
        );
  }
}

class RowDot extends StatelessWidget {
  const RowDot({super.key,this.title,this.pos=1,required this.onTap});
  final String? title;
  final int pos;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 24),
        child: AnimationFadeSlide(
           dx: 0.3*pos,
           duration: 100*pos,
          child: Row(
            children: [
              CirlceDot(radius: 8,color: textColor(context)),
             const SizedBox(width: 8),
              Text(title ?? 'Join Us',style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                      )),
            ],
          ),
        ),
      ),
    );
  }
}