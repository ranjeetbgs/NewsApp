import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incite/api_controller/blog_controller.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import '../../api_controller/app_provider.dart';
import '../../model/blog.dart';
import '../../splash_screen.dart';
import '../../utils/image_util.dart';
import 'blog.dart';
import 'blog_wrap.dart';
import 'home.dart';

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
    });

    controller = PageController(initialPage: widget.index);
    super.initState();
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
