import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incite/api_controller/blog_controller.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import '../../api_controller/app_provider.dart';
import '../../api_controller/manage_local.dart';
import '../../main.dart';
import '../../model/blog.dart';
import '../../splash_screen.dart';
import '../../urls/url.dart';
import '../../utils/image_util.dart';
import 'blog.dart';
import 'blog_wrap.dart';
import 'home.dart';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.index = 0});
  final int index;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with AutomaticKeepAliveClientMixin {
  late PageController controller;
  PreloadPageController preloadPageController = PreloadPageController();
  bool data = true;
  int currIndex = 0;
  UserProvider user = UserProvider();
  int curr = 0;

  @override
  void initState() {
    //  user.checkSettingUpdate(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var provider = Provider.of<AppProvider>(context, listen: false);
      if (currentUser.value.id != null) {
        if (!prefs!.containsKey('isBookmark')) {
          provider.getAllBookmarks().then((DataModel? value) {});
        } else {
          provider.setAllBookmarks();
        }
      }

      notificationListener = (manageNotifications);
      if (appLaunchResult != null) {
        manageNotifications(appLaunchResult!).then((v) {
        });
      }
    });

    controller = PageController(initialPage: widget.index);
    super.initState();
  }

  updateLocals(String url) async {
    var result = await http.get(
      Uri.parse(url),
    );
    log("Got info....     ${result.body}");
    ManageLocalData.saveToLocal(key: url, value: result.body);
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
        if(localNewsData != null){
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
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                navkey.currentState!.pushNamed('/BlogWrap',
                    arguments: [0, false, PreloadPageController(), "noti${list.id}", BlogOptionType.bookmark, true]);
              });
            } else if (buttons.isNotEmpty && action == 'Share') {
              updateBlogList(list, provider);
              provider.setNotificationLoading(false);
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                navkey.currentState!.pushNamed('/BlogWrap',
                    arguments: [0, false, PreloadPageController(), "noti${list.id}", BlogOptionType.share, true]);
              });
            } else {
              // ignore: use_build_context_synchronously
              updateBlogList(list, provider);
              provider.setNotificationLoading(false);
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                navkey.currentState!.pushNamed('/BlogWrap',
                    arguments: [0, false, PreloadPageController(), "noti${list.id}", null, true]);
              });
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder(
        valueListenable: allSettings,
        builder: (context, value, child) {
          return value.enableMaintainanceMode == '1'
              ? WillPopScope(
                  onWillPop: () async {
                    showCustomDialog(
                        context: context,
                        title: allMessages.value.confirmExitTitle ??
                            "Exit Application",
                        text: allMessages.value.confirmExitApp ??
                            'Do you want to exit from app ?',
                        onTap: () {
                          var provider =
                              Provider.of<AppProvider>(context, listen: false);
                          var end = DateTime.now();
                          provider.addAppTimeSpent(
                              startTime: provider.appStartTime, endTime: end);
                          provider.getAnalyticData();
                          Future.delayed(const Duration(milliseconds: 300));
                          exit(0);
                        },
                        isTwoButton: true);
                    return false;
                  },
                  child: Material(
                    child: SizedBox(
                      width: size(context).width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Image.asset(Img.logo,width: 100, height: 100),
                            Stack(children: [
                              Image.asset('assets/images/maintain.png',
                                  width: 200, height: 200),
                              Positioned(
                                  top: kToolbarHeight,
                                  right: 50,
                                  child: Image.asset(Img.logo,
                                      width: 30, height: 30))
                            ]),
                            Text(value.maintainanceTitle.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Text(value.maintainanceShortText.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : WillPopScope(
                  onWillPop: () async {
                    if (MediaQuery.of(context).orientation ==
                        Orientation.landscape) {
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                          overlays: [
                            SystemUiOverlay.top,
                            SystemUiOverlay.bottom
                          ]);
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                      ]);
                    } else if (isDrawerOpened) {
                      Navigator.pop(context);
                    } else if ((currIndex == 1 || currIndex == 0) &&
                        MediaQuery.of(context).orientation ==
                            Orientation.portrait) {
                      controller.animateToPage(0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeIn);
                    } else {
                      showCustomDialog(
                          context: context,
                          title: allMessages.value.confirmExitTitle ??
                              "Exit Application",
                          text: allMessages.value.confirmExitApp ??
                              'Do you want to exit from app ?',
                          onTap: () {
                            var provider = Provider.of<AppProvider>(context,
                                listen: false);
                            var end = DateTime.now();
                            provider.addAppTimeSpent(
                                startTime: provider.appStartTime, endTime: end);
                            provider.getAnalyticData();
                            Future.delayed(const Duration(milliseconds: 300));
                            exit(0);
                          },
                          isTwoButton: true);
                    }
                    return false;
                  },
                  child: AnnotatedRegion(
                    value: SystemUiOverlayStyle(
                        statusBarIconBrightness:
                            dark(context) ? Brightness.light : Brightness.dark,
                        statusBarColor: Colors.transparent),
                    child: Scaffold(
                      body: PageView(
                        physics: currentUser.value.isNewUser == true
                            ? const NeverScrollableScrollPhysics()
                            : MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                ? const NeverScrollableScrollPhysics()
                                : null,
                        controller: controller,
                        onPageChanged: (value) {
                          currIndex = value;
                          setState(() {});
                        },
                        children: [
                          HomePage(onChanged: (int value) async {
                            data = false;
                            curr = value;
                            if (preloadPageController.hasClients) {
                              preloadPageController.jumpToPage(curr);
                            }
                            controller.animateToPage(1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                            setState(() {});
                          }),
                          Stack(
                            children: [
                              BlogWrapPage(
                                  key: ValueKey(
                                      "${blogListHolder.blogType}$curr"),
                                  preloadPageController: preloadPageController,
                                  index: curr,
                                  onChanged: (value) {
                                    controller.animateToPage(0,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeIn);
                                  }),
                              currentUser.value.isNewUser == true
                                  ? Positioned.fill(
                                      child: GestureDetector(
                                      onTap: () {
                                        currentUser.value.isNewUser = false;
                                        setState(() {});
                                      },
                                      child: Container(
                                        width: size(context).width,
                                        height: size(context).height,
                                        color: Colors.black.withOpacity(0.86),
                                        child: Image.asset(
                                            'assets/images/instruct.png',
                                            fit: BoxFit.contain),
                                      ),
                                    ))
                                  : const SizedBox(),
                            ],
                          ),
                          //  if(blogListHolder.getList().blogs.isNotEmpty && blogListHolder.getList().blogs[blogListHolder.getIndex()].sourceLink !=null)
                          //    CustomWebView(url: blogListHolder.getList().blogs[blogListHolder.getIndex()].sourceLink.toString())
                        ],
                      ),
                    ),
                  ),
                );
        });
  }

  @override
  bool get wantKeepAlive => data;
}
