import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/urls/url.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incite/utils/image_util.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/anim_util.dart';
import 'package:provider/provider.dart';
import 'api_controller/app_provider.dart';
import 'api_controller/blog_controller.dart';
import 'api_controller/manage_local.dart';
import 'main.dart';
import 'model/blog.dart';
import 'package:http/http.dart' as http;

import 'pages/main/blog.dart';
import 'pages/main/blog_wrap.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startCall();
    });
    // startCall();
    prefs!.remove('data');
    // });
    super.initState();
  }

  Future startCall() async {
    var of = Provider.of<AppProvider>(context, listen: false);
    user.adBlogs();
    of.setAnalyticData();
    log("local_data.....   ${prefs!.containsKey('local_data')}");
    if (!prefs!.containsKey('local_data')) {
      if (allSettings.value.enableMaintainanceMode != '1') {
        user.getLanguageFromServer(context).then((value) async {
          if (currentUser.value.id != null) {
            bool notificationPresent = appLaunchResult != null;
            of.getCategory(gotInfo: () {
              if (notificationPresent == false) {
                Future.delayed(const Duration(milliseconds: 1500)).then((v) {
                  if (appLaunchResult != null) {
                    manageNotifications(appLaunchResult!);
                  } else {
                    switchToPage();
                  }
                });
              }
            }).then((v) {
              if (appLaunchResult != null) {
                manageNotifications(appLaunchResult!);
              } else {
                switchToPage();
              }
            });
          } else {
            if (appLaunchResult != null) {
              manageNotifications(appLaunchResult!);
            } else {
              switchToPage();
            }
          }
        });
      }
    } else {
      bool notificationPresent = appLaunchResult != null;
      of.getCategory(gotInfo: () {
        if (notificationPresent == false) {
          Future.delayed(const Duration(milliseconds: 1500)).then((v) {
            if (appLaunchResult != null) {
              manageNotifications(appLaunchResult!);
            } else {
              switchToPage();
            }
          });
        }
      }).then((v) {
        if (appLaunchResult != null) {
          manageNotifications(appLaunchResult!);
        } else {
          switchToPage();
        }
      });
    }
  }

  Future manageNotifications(OSNotificationClickEvent result) async {
    log("Got Push Notification.........      ${result.notification.title}");
    log("Got Push Notification.........      ${result.notification.body}");
    log("Got Push Notification.........      ${result.notification.rawPayload}");
    log("Got Push Notification.........      ${result.notification.buttons}");
    final blog = json.decode(result.notification.rawPayload!['custom'].toString())['a']['blog'];
    final buttons = result.notification.buttons!.toList();
    final action = result.notification.rawPayload!['actionId'];
    //  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    var provider = Provider.of<AppProvider>(context, listen: false);

    if (blog != null) {
      try {
        provider.setNotificationLoading(true);

        String ress;
        var url = "${Urls.baseUrl}blog-detail/$blog";

        final localNewsData = await ManageLocalData.getFromLocal(url);
        if (localNewsData != null) {
          ress = localNewsData;
          updateLocals(url);
          log("Got From Local......  ");
        } else {
          var result = await http.get(
            Uri.parse(url),
          );
          log("Got info....     ${result.body}");
          ManageLocalData.saveToLocal(key: url, value: result.body);
          ress = result.body;
        }

        // var url = "${Urls.baseUrl}blog-detail/$blog";
        // var result = await http.get(
        //   Uri.parse(url),
        // );
        // log("Got info....     ${result.body}");
        // if(result.statusCode == 200) {
        //   ManageLocalData.saveToLocal(key: url, value: result.body);
        // }

        Map data = await json.decode(ress);
        if (data['success'] == true) {
          final list = Blog.fromJson(data['data'], isNotification: true);
          // print(list.type);

          if (list.type == 'quote') {
            var data = provider.allNews!.blogs;
            provider.allNews!.blogs = [];
            provider.allNews!.blogs.add(list);
            if (data.isNotEmpty && data.contains(list)) {
              data.remove(list);
            }
            provider.allNews!.blogs.addAll(data);
            blogListHolder.clearList();
            blogListHolder.setBlogType(BlogType.allnews);
            blogListHolder.setList(provider.allNews as DataModel);
            provider.updateUI();
            provider.setNotificationLoading(false);
            if (mounted) {
              setState(() {});
            }
            switchToPage();
            navkey.currentState!.pushNamed('/BlogWrap', arguments: [
              0,
              false,
              PreloadPageController(),
              "noti${list.id}",
              action == 'Share' ? BlogOptionType.share : null,
              true
            ]);
          } else {
            if (list.images!.isNotEmpty) {
              await precacheImage(CachedNetworkImageProvider(list.images![0]), context);
            }
            if (buttons.isNotEmpty && action == 'Bookmark') {
              updateBlogList(list, provider);
              provider.setNotificationLoading(false);
              switchToPage();
              navkey.currentState!.pushNamed('/BlogWrap',
                  arguments: [0, false, PreloadPageController(), "noti${list.id}", BlogOptionType.bookmark, true]);
            } else if (buttons.isNotEmpty && action == 'Share') {
              updateBlogList(list, provider);
              provider.setNotificationLoading(false);
              switchToPage();
              navkey.currentState!.pushNamed('/BlogWrap',
                  arguments: [0, false, PreloadPageController(), "noti${list.id}", BlogOptionType.share, true]);
            } else {
              // ignore: use_build_context_synchronously
              updateBlogList(list, provider);
              provider.setNotificationLoading(false);
              switchToPage();
              navkey.currentState!
                  .pushNamed('/BlogWrap', arguments: [0, false, PreloadPageController(), "noti${list.id}", null, true]);
            }
          }
        }

        provider.setNotificationLoading(false);
      } on Exception catch (e) {
        provider.setNotificationLoading(false);

        if (kDebugMode) {
          print(e.toString());
        }
      }
    }
  }

  updateLocals(String url) async {
    var result = await http.get(
      Uri.parse(url),
    );
    log("Got info....     ${result.body}");
    ManageLocalData.saveToLocal(key: url, value: result.body);
  }

  void updateBlogList(Blog newBlog, AppProvider provider) {
    var data = provider.allNews!.blogs;
    provider.allNews!.blogs = [];
    provider.allNews!.blogs.add(newBlog);
    if (data.isNotEmpty && data.contains(newBlog)) {
      data.remove(newBlog);
    }
    provider.allNews!.blogs.addAll(data);
    blogListHolder.clearList();
    blogListHolder.setList(provider.allNews as DataModel);
    blogListHolder.setBlogType(BlogType.allnews);
    provider.updateUI();
    setState(() {});
  }

  switchToPage() {
    //   if (prefs!.containsKey('maintain') && prefs!.getBool('maintain') == false) {
    if (currentUser.value.id != null) {
      Navigator.pushNamedAndRemoveUntil(context, '/MainPage', arguments: 1, (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/MainPage', (route) => false);
      //   // if (!prefs!.containsKey('local_data')) {
      //   //      Navigator.pushNamedAndRemoveUntil(context, '/GetStarted',(route) => false);
      //   //   }else{
      //   Navigator.pushNamedAndRemoveUntil(
      //       context, '/LoginPage', (route) => false);
      //   // }
      // }
    }
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
                  statusBarIconBrightness: dark(context) ? Brightness.light : Brightness.dark,
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
                                      imageUrl: "${value.baseImageUrl}/${value.appSplashScreen.toString()}",
                                      width: 100,
                                      height: 100,
                                      errorWidget: (context, url, error) {
                                        return Image.asset(Img.logo, width: 100, height: 100);
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
