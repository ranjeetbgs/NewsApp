import 'package:flutter/material.dart';
import 'package:incite/utils/color_util.dart';

bool dark(BuildContext context){
  return Theme.of(context).brightness == Brightness.dark;
}

Color textColor(BuildContext context){
  return dark(context) ? ColorUtil.white : ColorUtil.textblack;
}

Size size(BuildContext context){
  return MediaQuery.of(context).size;
}

double height10(BuildContext context){
 return size(context).height*0.01233;
}