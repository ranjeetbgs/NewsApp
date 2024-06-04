import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:incite/api_controller/blog_controller.dart';
import 'package:incite/api_controller/repository.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:http/http.dart' as http;
import 'package:incite/model/blog.dart';
import 'package:incite/pages/main/blog.dart';
import 'package:incite/urls/url.dart';
import 'package:incite/utils/app_theme.dart';
import 'package:incite/utils/app_util.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/utils/navigate_util.dart';
import 'package:incite/utils/rgbo_to_hex.dart';
import 'package:incite/utils/route_util.dart';
import 'package:incite/utils/shared_util.dart';
import 'package:incite/widgets/button.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_controller/app_provider.dart';
import 'model/lang.dart';
import 'splash_screen.dart';

//InciteHttp? httpClient;
GlobalKey<NavigatorState> navkey = GlobalKey<NavigatorState>();
PendingDynamicLinkData? initialLink;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  OneSignal.initialize("4e94725e-4369-4386-bf67-b9c16ad99abe");
  await MobileAds.instance.initialize();
  // initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  // httpClient =  InciteHttp();
  FacebookAudienceNetwork.init(
      testingId: "37b1da9d-b48c-4103-a393-2e095e734bd6", //optional
      iOSAdvertiserTrackingEnabled: true //default false
      );

  try {
    prefs = await SharedPreferences.getInstance();
    GetIt.instance.registerSingleton<SharedPreferencesUtils>(
        await SharedPreferencesUtils.getInstance() as SharedPreferencesUtils);
    await getDataFromSharedPrefs();
    await getMessageAndSetting();
    await getCurrentUser();
  } catch (e) {
    prefs = await SharedPreferences.getInstance();
    GetIt.instance.registerSingleton<SharedPreferencesUtils>(
        await SharedPreferencesUtils.getInstance() as SharedPreferencesUtils);
    await getCurrentUser();
    await getDataFromSharedPrefs();
    await getMessageAndSetting();
    debugPrint('error happened $e');
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // This widget is the root of your application.
  UserProvider userProvider = UserProvider();
  late DateTime startTime;
  DateTime? endTime;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer!.cancel();
    super.dispose();
  }

  final StreamController<String> _controller = StreamController<String>();
  Timer? timer;
  Stream<String> get myStream => _controller.stream;
  UserProvider user = UserProvider();

  void _fetchData({DateTime? end}) {
    var provider = Provider.of<AppProvider>(context, listen: false);

    if (end != null) {
      provider.addAppTimeSpent(startTime: startTime, endTime: end);
    }
    var store = provider.getAnalyticData();
    debugPrint(store.toString());
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
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // userProvider.checkSettingUpdate().whenComplete(() {
    getDataFromSharedPrefs();
    //  WidgetsBinding.instance.addPostFrameCallback((timeStamp)async {
    //    await initDynamicLinks(context);
    //     setState(() { });
    //  });
    OneSignal.Notifications.requestPermission(false).then((accepted) async {
      final String? osUserID = OneSignal.User.pushSubscription.id;
      if (osUserID != null) {
        debugPrint('-----------  Player ID ------------ ');
        debugPrint(osUserID);
        await setOnesignalUserId(osUserID.toString());
        if (prefs!.containsKey('player_id')) {
          debugPrint('----------- set Player ID ------------ ');
          currentUser.value.deviceToken = osUserID.toString();
          updateToken(currentUser.value, getOnesignalUserId().toString());
        }
        debugPrint(currentUser.value.deviceToken);
      }
    });
    // ------------------ app Id --------------------
    // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt.
    //We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.User.pushSubscription
        .addObserver((OSPushSubscriptionChangedState changes) async {
      final String? osUserID = OneSignal.User.pushSubscription.id;

      if (osUserID != null) {
        await setOnesignalUserId(osUserID.toString());
        if (prefs!.containsKey('player_id')) {
          debugPrint('----------- set Player ID ------------ ');
          currentUser.value.deviceToken = osUserID.toString();
          updateToken(currentUser.value, getOnesignalUserId().toString());
        }
      }
    });

    OneSignal.Notifications.addForegroundWillDisplayListener(
        (OSNotificationWillDisplayEvent event) {
      // Will be called whenever a notification is received in foreground
      // Display Notification, pass null param for not displaying the notification
    });
    // bool loading = false;
    OneSignal.Notifications.removeClickListener((event) {});
    OneSignal.Notifications.addClickListener(
        (OSNotificationClickEvent result) async {
      if (appLoaded == false) {
        await Future.delayed(const Duration(seconds: 5));
      }
      final blog =
          json.decode(result.notification.rawPayload!['custom'].toString())['a']
              ['blog'];
      final buttons = result.notification.buttons!.toList();
      final action = result.notification.rawPayload!['actionId'];
      //  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var provider =
          // ignore: use_build_context_synchronously
          Provider.of<AppProvider>(navkey.currentState!.context, listen: false);

      if (blog != null) {
        // loading = true;
        // Future.delayed(const Duration(seconds: 5)).then((value) {
        //   loading = false;
        // });
        try {
          var url = "${Urls.baseUrl}blog-detail/$blog";
          var result = await http.get(
            Uri.parse(url),
          );
          Map data = await json.decode(result.body);
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
              setState(() {});
              SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
                navkey.currentState!.pushNamed('/BlogWrap', arguments: [
                  0,
                  false,
                  PreloadPageController(),
                  "noti${list.id}",
                  action == 'Share' ? BlogOptionType.share : null,
                  true
                ]);
              });
            } else {
              if (list.images!.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
                  await precacheImage(
                      CachedNetworkImageProvider(list.images![0]), context);
                });
              }
              if (buttons.isNotEmpty && action == 'Bookmark') {
                updateBlogList(list, provider);
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  navkey.currentState!.pushNamed('/BlogWrap', arguments: [
                    0,
                    false,
                    PreloadPageController(),
                    "noti${list.id}",
                    BlogOptionType.bookmark,
                    true
                  ]);
                });
              } else if (buttons.isNotEmpty && action == 'Share') {
                updateBlogList(list, provider);
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  navkey.currentState!.pushNamed('/BlogWrap', arguments: [
                    0,
                    false,
                    PreloadPageController(),
                    "noti${list.id}",
                    BlogOptionType.share,
                    true
                  ]);
                });
              } else {
                // ignore: use_build_context_synchronously
                updateBlogList(list, provider);
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  navkey.currentState!.pushNamed('/BlogWrap', arguments: [
                    0,
                    false,
                    PreloadPageController(),
                    "noti${list.id}",
                    null,
                    true
                  ]);
                });
              }
            }
          }
        } on Exception catch (e) {
          print(e.toString());
        }
      }
    });
    // OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
    //   // Will be called whenever the permission changes
    //   // (ie. user taps Allow on the permission prompt in iOS)
    // });

    //  OneSignal.shared.setEmailSubscriptionObserver((OSEmailSubscriptionStateChanges emailChanges) {
    //   // Will be called whenever then user's email subscription changes
    //   // (ie. OneSignal.setEmail(email) is called and the user gets registered
    //  });

    startTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var provider = Provider.of<AppProvider>(context, listen: false);
      provider.appTime(startTime);
      user.checkSettingUpdate(context);
      setState(() {});
    });
    timer = Timer.periodic(const Duration(minutes: 10), (timer) {
      _fetchData();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle the lifecycle state change
    switch (state) {
      case AppLifecycleState.resumed:
        timer = Timer.periodic(const Duration(minutes: 10), (timer) {
          if (WidgetsBinding.instance.lifecycleState ==
              AppLifecycleState.resumed) {
            _fetchData();
            debugPrint('-------------- Data is resumed ------------------');
          }
        });
        break;

      case AppLifecycleState.paused:
        timer?.cancel();
        _fetchData();
        debugPrint('-------------- Data is paused ------------------');
        setState(() {});

        debugPrint(startTime.toIso8601String());
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        endTime = DateTime.now();
        prefs!.remove('isBookmark');
        _fetchData(end: endTime);
        debugPrint('-------------- Data is detached ------------------');

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: allSettings,
        builder: (context, setting, child) {
          return ValueListenableBuilder(
              valueListenable: appThemeModel,
              builder: (context, AppModel value, child) {
                return ValueListenableBuilder(
                    valueListenable: languageCode,
                    builder: (context, Language lang, child) {
                      return AnnotatedRegion<SystemUiOverlayStyle>(
                          value: SystemUiOverlayStyle(
                            systemNavigationBarIconBrightness:
                                appThemeModel.value.isDarkModeEnabled.value
                                    ? Brightness.light
                                    : Brightness.dark,
                            systemNavigationBarColor:
                                appThemeModel.value.isDarkModeEnabled.value
                                    ? ColorUtil.textblack
                                    : Colors.white,
                          ),
                          child: MaterialApp(
                            navigatorObservers: [NavigateUtil()],
                            navigatorKey: navkey,
                            title: setting.appName ?? 'NewsPepper',
                            initialRoute: '/SplashScreen',
                            debugShowCheckedModeBanner: false,
                            builder: (context, child) {
                              child = Directionality(
                                textDirection: lang.pos == 'rtl'
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                child: child as Widget,
                              ); //do something
                              return child;
                            },
                            onGenerateRoute: RouteGenerator.generateRoute,
                            theme: value.isDarkModeEnabled.value
                                ? getDarkThemeData(
                                    hexToRgb(setting.primaryColor),
                                    hexToRgb(setting.secondaryColor))
                                : getLightThemeData(
                                    hexToRgb(setting.primaryColor),
                                    hexToRgb(setting.secondaryColor)),
                          ));
                    });
              });
        });
  }
}

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  //the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // box-shadow: 0px -10px 70px rgba(0, 0, 0, 0.2);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/Spalsh.png', fit: BoxFit.cover),
          Positioned(
            bottom: 0,
            child: Container(
              width: size.width,
              height: 250,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, -70),
                      blurRadius: 70,
                      color: Color.fromRGBO(0, 0, 0, 0.2))
                ],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 30, right: 30, top: 32, bottom: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'News from around the world for you',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: ColorUtil.textblack),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Best time to read, take your time to read a little more of this world',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: ColorUtil.textgrey),
                    ),
                    const SizedBox(height: 18),
                    ElevateButton(onTap: () {
                      Navigator.pushNamed(context, '/LoginPage');
                    })
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

bool appLoaded = false;
PageTransition customPageTransisition(Widget widget, {bool reverse = false}) {
  return PageTransition(
      type: reverse
          ? PageTransitionType.leftToRight
          : PageTransitionType.rightToLeft,
      duration: const Duration(milliseconds: 250),
      child: widget);
}
