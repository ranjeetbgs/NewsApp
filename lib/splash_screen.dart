import 'package:cached_network_image/cached_network_image.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incite/utils/image_util.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/anim_util.dart';
import 'package:provider/provider.dart';
import 'api_controller/app_provider.dart';

SharedPreferences? prefs;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  UserProvider user = UserProvider();

  @override
  void initState() {
    // WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) async{

    startCall();
    prefs!.remove('data');
    // });
    super.initState();
  }

  Future startCall() async {
    var of = Provider.of<AppProvider>(context, listen: false);
    user.adBlogs();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      of.setAnalyticData();
    });
    if (!prefs!.containsKey('local_data')) {
      //  user.checkSettingUpdate();
      if (allSettings.value.enableMaintainanceMode != '1') {
        user.getLanguageFromServer(context).then((value) async {
          if (currentUser.value.id != null) {
            of.getCategory(allowUpdate: false).whenComplete(switchToPage);
          } else {
            switchToPage();
          }
        });
      }
    } else {
      // user.checkSettingUpdate();
      //  if (currentUser.value.id != null) {
      // if(allSettings.value.enableMaintainanceMode != '1'){
      of.getCategory(allowUpdate: false).then((value) {
        switchToPage();
      });
      // }
      // } else {
      //    Future.delayed(const Duration(milliseconds: 2500),() {
      //    switchToPage();
      //  });
      // }
    }
  }

  FutureOr<void> switchToPage() {
    //   if (prefs!.containsKey('maintain') && prefs!.getBool('maintain') == false) {
    if (currentUser.value.id != null) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/MainPage', arguments: 1, (route) => false);
    } else {
      // if (!prefs!.containsKey('local_data')) {
      //      Navigator.pushNamedAndRemoveUntil(context, '/GetStarted',(route) => false);
      //   }else{
      Navigator.pushNamedAndRemoveUntil(
          context, '/LoginPage', (route) => false);
      // }
    }

    //}
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: ValueListenableBuilder(
          valueListenable: allSettings,
          key: ValueKey(allSettings.value.enableMaintainanceMode),
          builder: (context, value, child) {
            return AnnotatedRegion(
              value: SystemUiOverlayStyle(
                  statusBarIconBrightness:
                      dark(context) ? Brightness.light : Brightness.dark,
                  statusBarColor: Colors.transparent),
              child: Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: AnimationFadeScale(
                          duration: 600,
                          child: AnimationFadeSlide(
                              duration: 700,
                              dy: 0.5,
                              child: value.appSplashScreen == null
                                  ? Image.asset(
                                      Img.logo,
                                      width: 100,
                                      height: 100,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl:
                                          "${value.baseImageUrl}/${value.appSplashScreen.toString()}",
                                      width: 100,
                                      height: 100,
                                      errorWidget: (context, url, error) {
                                        return Image.asset(Img.logo,
                                            width: 100, height: 100);
                                      }))),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
