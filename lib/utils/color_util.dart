 import 'package:flutter/material.dart';

import 'theme_util.dart';


 class ColorUtil {

static const Color textblack = Color.fromRGBO(12, 12, 12,1);
static const Color textgrey = Color.fromRGBO(97, 97, 97,1);
static const Color textgrey2 = Color.fromRGBO(191, 191, 191,1); 
//static Color primary1 = allSettings.value.primaryColor != null ? hexToRgb(allSettings.value.primaryColor.toString()) : const Color.fromRGBO(255, 134, 44,1);
//static Color primary2 = allSettings.value.secondaryColor != null ? hexToRgb(allSettings.value.secondaryColor.toString()) :const Color.fromRGBO(255, 79, 60,1);
static const Color blogBackColor = Color.fromRGBO(30, 30, 30, 1);
static const Color whiteGrey = Color.fromRGBO(240, 240, 242,1);
static const Color blackGrey = Color.fromRGBO(40, 40, 42, 1);

static const Color white = Color.fromRGBO(255, 255, 255,1);
static const Color shadowColor = Color.fromRGBO(0, 4, 36,0.1);
static const Color lightGrey = Color.fromRGBO(191, 191, 191,1);
// static  LinearGradient primaryGradient = LinearGradient(
//   begin: Alignment.topCenter,
//   end: Alignment.bottomCenter,
//   colors: [
//  primary1, primary2
// ]);

LinearGradient darkPrimaryGradient (context)=> LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
              Colors.white, 
              Theme.of(context).cardColor
    ]);
    
static const LinearGradient textGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
   Color.fromARGB(1, 0, 40, 0), Color.fromRGBO(1, 0, 32, 0),Color.fromRGBO(1, 0, 38, 0.7)
]);

}

LinearGradient primaryGradient (context)=> LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
              Theme.of(context).primaryColor, 
              Theme.of(context).colorScheme.secondary
    ]);

    LinearGradient darkPrimaryGradient (context)=> LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
             isBlack(Theme.of(context).primaryColor) && dark(context) ? Colors.white :  Theme.of(context).primaryColor, 
             isBlack(Theme.of(context).primaryColor) && dark(context) ?  Colors.white24  :  Theme.of(context).colorScheme.secondary
    ]);


bool isBlack(Color color){
  return color.red <=  80 &&  color.blue <= 80 && color.green <= 80;
}