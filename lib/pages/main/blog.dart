import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:html/parser.dart';
import 'package:incite/main.dart';
import 'package:incite/model/analytic.dart';
import 'package:incite/pages/main/dashboard.dart';
import 'package:incite/pages/main/web_view.dart';
import 'package:incite/pages/main/widgets/caurosal.dart';
import 'package:incite/pages/main/widgets/fullscreen.dart';
import 'package:incite/pages/main/widgets/poll.dart';
import 'package:incite/pages/main/widgets/share.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/utils/image_util.dart';
import 'package:incite/utils/nav_util.dart';
import 'package:incite/utils/rgbo_to_hex.dart';
import 'package:incite/widgets/back.dart';
import 'package:incite/widgets/loader.dart';
import 'package:incite/widgets/shimmer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../api_controller/app_provider.dart';
import '../../api_controller/user_controller.dart';
import '../../model/blog.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../utils/theme_util.dart';
import '../../utils/time_util.dart';
import '../../utils/tts.dart';
import '../../widgets/banner_ads.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/tap.dart';
import 'home.dart';
import 'package:just_audio/just_audio.dart' as just;
import 'widgets/text.dart';
import 'widgets/youtube_video.dart';

// GlobalKey previewContainer2 = GlobalKey();

// GlobalKey scaffKey = GlobalKey<ScaffoldState>();
bool isDrawerOpened = false;

enum TtsState { playing, stopped, paused, continued }

enum BlogOptionType { share, bookmark }

class BlogPage extends StatefulWidget {
  final bool isVoting, isSingle, isBackAllowed;
  final Blog? model;
  final Category? category;
  final BlogOptionType? type;
  final int index, currIndex;
  final VoidCallback? onTap;
  final ValueChanged? onChanged;

  const BlogPage(
      {super.key,
      this.model,
      this.type,
      this.onChanged,
      this.isBackAllowed = false,
      this.index = 0,
      this.isSingle = false,
      this.category,
      this.onTap,
      this.isVoting = false,
      required this.currIndex});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> with WidgetsBindingObserver {
  String? vote;

  bool isPlayerReady = false;

  GlobalKey previewContainer = GlobalKey();

  bool isExpand = true;
  bool isShare = false;
  final audioPlayer = AudioPlayer();
  just.AudioPlayer audioPlay = just.AudioPlayer();
  var previewContainer2 = GlobalKey<ScaffoldState>();
  AppProvider? provider;
  String startTime = '';
  late Map<String, dynamic> ttsData;
  var ttsState;

  FlutterTts flutterTts = FlutterTts();
  late DateTime blogStartTime;
  bool isVolume = false;
  Uint8List? audioLoad;

  bool isLeftSwipe = false;

  var admobFreq = int.parse(allSettings.value.admobFrequency.toString() == '0'
      ? '1'
      : allSettings.value.admobFrequency.toString());
  var fbadsFreq = int.parse(allSettings.value.fbAdsFrequency.toString() == '0'
      ? '1'
      : allSettings.value.fbAdsFrequency.toString());

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    blogStartTime = DateTime.now();
    initTTS();
    ttsData = {"id": widget.model!.id, "start_time": "", "end_time": ""};

    provider = Provider.of<AppProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      //  await precacheImage(CachedNetworkImageProvider(widget.model!.images![0]),context);
      if (widget.index == 0) {
        provider!.addviewData(widget.model!.id ?? 0);
      }
      if (widget.type != null && widget.type == BlogOptionType.share) {
        // SchedulerBinding.instance.addPostFrameCallback((timeStamp) async{
        Future.delayed(const Duration(milliseconds: 2000), () async {
          await captureScreenshot(previewContainer, isPost: true)
              .then((value) async {
            // isShare = true;
            // setState(() {   });
            if (value != null) {
              final data2 = await convertToXFile(value);
              Future.delayed(const Duration(milliseconds: 100));
              shareImage(data2);
              provider!.addShareData(widget.model!.id!.toInt());
              setState(() {});
            }
            //  isShare= false;
          });

          // });
        });
      } else if (widget.type != null &&
          widget.type == BlogOptionType.bookmark) {
        if (currentUser.value.id != null) {
          if (!provider!.permanentIds.contains(widget.model!.id)) {
            showCustomToast(
                context, allMessages.value.bookmarkSave ?? 'Bookmark Saved');
            provider!.addBookmarkData(widget.model!.id!.toInt());
          } else {
            showCustomToast(context,
                allMessages.value.bookmarkRemove ?? 'Bookmark Removed');
            provider!.removeBookmarkData(widget.model!.id!.toInt());
          }
          provider!.setBookmark(blog: widget.model as Blog);
          setState(() {});
        } else {
          Navigator.pushNamed(context, '/LoginPage');
        }
      }
      //  if (!prefs!.containsKey('isBookmark') && currentUser.value.id != null) {
      //     provider!.getAllBookmarks();
      // }
    });
  }

  Future<Uint8List?> speech(String text) async {
    final response = await generateSpeech(
        text, widget.model!.accentCode.toString(), 'en-GB-Neural2-A');
    setState(() {
      audioLoad = response;
      widget.model!.audioData = audioLoad;
    });
    return audioLoad;
    // playLocal(data);
  }

  Future<void> setSpeechRate(double rate) async {
    await flutterTts
        .setSpeechRate(rate); // Set the speech rate using the FlutterTts plugin
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App is resumed and visible
        break;
      case AppLifecycleState.inactive:
        // App is inactive and not receiving user input
        break;
      case AppLifecycleState.paused:
        stops();
        break;
      case AppLifecycleState.detached:
        // App is detached from any host and all resources have been released
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  Future playLocal(Uint8List audioData) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (Platform.isAndroid) {
      Source source = BytesSource(audioData);
      audioPlayer.setPlaybackRate(0.833);
      await audioPlayer.play(
        source,
        volume: 1.0,
        mode: PlayerMode.mediaPlayer,
      );
    } else {
      playLocalAudio(audioData);
    }
  }

  Future<void> playLocalAudio(Uint8List tts) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final filePath = "${appDocDir.path}/tts_audio.wav";
    //  final files = await getCurrentUrl(filePath);
    final file = File.fromUri(Uri.parse(filePath));
    await file.writeAsBytes(tts);
    just.AudioSource source = just.AudioSource.file(file.path);
    await audioPlay.setAudioSource(source);
    await audioPlay.setSpeed(0.3);
    await Future.delayed(const Duration(milliseconds: 100));
    if (file.existsSync()) {
      await audioPlay.play();
    } else {
      print('file not exists');
    }
  }

  UrlSource urlSourceFromBytes(Uint8List bytes,
      {String mimeType = "audio/wav"}) {
    return UrlSource(Uri.dataFromBytes(bytes, mimeType: mimeType).toString());
  }

  void stops() {
    setState(() {
      isVolume = false;
    });
    if (Platform.isIOS) {
      audioPlay.stop();
    } else {
      audioPlayer.stop();
    }
  }

  Future<void> init(String text) async {
    bool isLanguageFound = false;
    var filterText = text.replaceAll(RegExp(r'[^\w\s,.]'), '');
    flutterTts.getLanguages.then((value) async {
      Iterable it = value;

      for (var element in it) {
        if (element.toString().contains(widget.model!.accentCode.toString())) {
          flutterTts.setLanguage(element);
          setSpeechRate(0.33);
          _playVoice(filterText);
          isLanguageFound = true;
        }
      }
    });

    if (!isLanguageFound) {
      _playVoice(filterText);
    }
  }

  void audioListener() {
    audioPlayer.onPlayerStateChanged.listen(
      (it) {
        switch (it) {
          case PlayerState.completed:
            setState(() {
              isVolume = false;
              var endTime = DateTime.now().toIso8601String();
              ttsData = {
                "id": widget.model!.id,
                "start_time": startTime,
                "end_time": endTime
              };
              provider!.addTtsData(
                  ttsData['id'], ttsData['start_time'], ttsData['end_time']);
            });
            break;
          default:
            break;
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (ttsState == TtsState.stopped) {
        setState(() {
          isVolume = false;
        });
      }
      //  audioPlayer.onPlayerStateChanged.listen(
      //     (it) {
      //       switch (it) {
      //         case PlayerState.stopped:
      //           break;
      //         case PlayerState.completed:
      //           isVolume = true;
      //           setState(() {  });
      //           break;
      //         default:
      //           break;
      //       }
      //     },
      //);
    });
    super.didChangeDependencies();
  }

  _playVoice(text) async {
    setState(() {
      ttsState == TtsState.playing;
      flutterTts.speak(text).then((value) {
        initTTS();
      });

      isVolume = true;
    });
  }

  Future<void> initTTS() async {
    flutterTts = FlutterTts();

    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      stop();
      var endTime = DateTime.now().toIso8601String();
      ttsData = {
        "id": widget.model!.id,
        "start_time": startTime,
        "end_time": endTime
      };
      provider!.addTtsData(
          ttsData['id'], ttsData['start_time'], ttsData['end_time']);
      setState(() {});
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        ttsState = TtsState.continued;
      });
    });

// Replace all occurrences of the comma with an empty string
  }

  Future stop() async {
    setState(() {
      ttsState == TtsState.stopped;
      flutterTts.stop();
      isVolume = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    audioPlayer.stop();
    if (Platform.isIOS) {
      audioPlay.stop();
    }
    super.dispose();
  }

  String endTime = '';

  @override
  Widget build(BuildContext context) {
    var provider2 = Provider.of<AppProvider>(context, listen: false);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor:
            dark(context) ? ColorUtil.blogBackColor : Colors.white));

    var timeFormat2 = widget.model!.scheduleDate == null
        ? ''
        : timeFormat(
            DateTime.tryParse(widget.model!.scheduleDate!.toIso8601String()));
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(
            context,
            customPageTransisition(const DashboardPage(index: 0),
                reverse: true),
            (route) => false);
        return Future.value(false);
      },
      child: SizedBox(
        height: size(context).height,
        width: MediaQuery.of(context).size.width,
        child: CustomLoader(
            isLoading: isShare,
            child: Scaffold(
              // key: webViewScaffoldKey,
              drawerEdgeDragWidth: MediaQuery.of(context).size.width / 3,
              onEndDrawerChanged: (isOpened) {
                widget.onChanged!(isOpened);
                isLeftSwipe = isOpened;
                isDrawerOpened = isOpened;
                setState(() {});
              },
              endDrawer: widget.model!.sourceLink != ''
                  ? CustomWebView(url: widget.model!.sourceLink.toString())
                  : null,
              body: OrientationBuilder(builder: (context, orientation) {
                var rectangleLogo = allSettings.value.baseImageUrl![
                            allSettings.value.baseImageUrl!.length - 1] ==
                        '/'
                    ? "${allSettings.value.baseImageUrl}${allSettings.value.rectangualrAppLogo}"
                    : "${allSettings.value.baseImageUrl}/${allSettings.value.rectangualrAppLogo}";
                return SafeArea(
                  child: Stack(
                    children: [
                      Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: size(context).width,
                        height: size(context).height,
                        child: RepaintBoundary(
                          key: previewContainer2,
                          child: Container(
                            height: size(context).height,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: Column(
                              children: [
                                Expanded(
                                  child: RepaintBoundary(
                                    key: previewContainer,
                                    child: Container(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: orientation ==
                                                  Orientation.landscape
                                              ? 0
                                              : 20,
                                          vertical: orientation ==
                                                  Orientation.landscape
                                              ? 0
                                              : height10(context) + 2),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              widget.model!.videoUrl != ''
                                                  ? RepaintBoundary(
                                                      key: Key(
                                                          '${widget.model!.title}${widget.index}'),
                                                      child: YouTubeVideo(
                                                        isMute: true,
                                                        isPlay: false,
                                                        videoUrl: widget
                                                            .model!.videoUrl,
                                                        isFull: orientation ==
                                                            Orientation
                                                                .landscape,
                                                        height: orientation ==
                                                                Orientation
                                                                    .landscape
                                                            ? size(context)
                                                                .height
                                                            : height10(
                                                                    context) *
                                                                25,
                                                      ),
                                                    )
                                                  : widget.model!.images !=
                                                              null &&
                                                          widget.model!.images!
                                                                  .length >
                                                              1
                                                      ? CaurosalSlider(
                                                          model: widget.model
                                                              as Blog,
                                                        )
                                                      : GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                PagingTransform(
                                                                    widget:
                                                                        FullScreen(
                                                                      image: widget.model!.images != null &&
                                                                              widget
                                                                                  .model!.images!.isNotEmpty
                                                                          ? widget
                                                                              .model!
                                                                              .images![0]
                                                                              .toString()
                                                                          : rectangleLogo,
                                                                      index: widget
                                                                          .index,
                                                                      title: widget
                                                                          .model!
                                                                          .title
                                                                          .toString(),
                                                                    ),
                                                                    slideUp:
                                                                        true));
                                                          },
                                                          child: Hero(
                                                            tag: widget
                                                                    .model!
                                                                    .images!
                                                                    .isEmpty
                                                                ? '${widget.index}'
                                                                : '${widget.index}${widget.model!.images![0]}',
                                                            child: Container(
                                                              width:
                                                                  size(context)
                                                                      .width,
                                                              height: height10(
                                                                      context) *
                                                                  25,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .cardColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                                child: widget
                                                                        .model!
                                                                        .images!
                                                                        .isEmpty
                                                                    ? Image.asset(
                                                                        Img.logo)
                                                                    : CachedNetworkImage(
                                                                        // imageUrl: '',
                                                                        imageUrl: widget.model!.images !=
                                                                                null
                                                                            ? widget.model!.images![0]
                                                                            : '',
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        errorWidget: (context,
                                                                            url,
                                                                            error) {
                                                                          return const ShimmerLoader();
                                                                        },
                                                                        placeholder:
                                                                            (context,
                                                                                url) {
                                                                          return const ShimmerLoader();
                                                                        },
                                                                      ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                              orientation ==
                                                      Orientation.landscape
                                                  ? const SizedBox()
                                                  : Container(
                                                      padding: EdgeInsets.only(
                                                          top:
                                                              height10(context),
                                                          bottom: height10(
                                                              context)),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/playstore1.png',
                                                            width: 150,
                                                          ),
                                                          CachedNetworkImage(
                                                            imageUrl:
                                                                rectangleLogo,
                                                            width: 120,
                                                            height: 30,
                                                            errorWidget:
                                                                (context, con,
                                                                        dfg) =>
                                                                    Image.asset(
                                                              'assets/images/com_logo.png',
                                                              width: 120,
                                                              height: 30,
                                                            ),
                                                          )
                                                        ],
                                                      )),
                                            ],
                                          ),
                                          orientation == Orientation.landscape
                                              ? const SizedBox()
                                              : TitleWidget(
                                                  key: Key(
                                                      '${widget.model!.hashCode}'),
                                                  title: widget.model!.title
                                                      .toString()),
                                          // :SizedBox(key: Key('${ widget.index}')) ,
                                          // SizedBox(height: height10(context)),
                                          orientation == Orientation.landscape
                                              ? const SizedBox()
                                              : Expanded(
                                                  flex: 2,
                                                  // height: size(context).height*0.2875,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Description(
                                                            optionLength: widget
                                                                        .model!
                                                                        .question ==
                                                                    null
                                                                ? 0
                                                                : widget.model!.question!
                                                                            .options !=
                                                                        null
                                                                    ? widget
                                                                        .model!
                                                                        .question!
                                                                        .options!
                                                                        .length
                                                                    : 0,
                                                            model:
                                                                widget.model!,
                                                            isPoll: isExpand &&
                                                                widget.model!
                                                                        .question !=
                                                                    null &&
                                                                widget.model!
                                                                        .isVotingEnable ==
                                                                    1),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.only(top: 10),
                                                        child: RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              widget.model!.sourceLink == ''
                                                                  ? const WidgetSpan(
                                                                child: SizedBox(),
                                                              )
                                                                  : WidgetSpan(
                                                                child: TapInk(
                                                                  onTap: () {
                                                                    Navigator.push(
                                                                      context,
                                                                      CupertinoPageRoute(
                                                                        builder: (context) => CustomWebView(url: widget.model!.sourceLink.toString()),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                    '${widget.model!.sourceName}',
                                                                    style: TextStyle(
                                                                      decoration: TextDecoration.underline,
                                                                      fontFamily: 'Roboto',
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w300,
                                                                      color: dark(context) ? ColorUtil.white : ColorUtil.textgrey,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              WidgetSpan(
                                                                child: Text(widget.model!.sourceLink == '' ? timeFormat2 : " : $timeFormat2",
                                                                    style: TextStyle(
                                                                      fontFamily: 'Roboto',
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w300,
                                                                      color: dark(context) ? ColorUtil.white : ColorUtil.textgrey,
                                                                    ),),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),

                                                    ],
                                                  ),
                                                )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                //  SizedBox(height: height10(context)),
                                orientation == Orientation.landscape
                                    ? const SizedBox()
                                    : widget.model!.question != null &&
                                            widget.model!.isVotingEnable == 1
                                        ? BlogPoll(
                                            pollKey: previewContainer2,
                                            onChanged: (value) {
                                              isExpand = value;
                                              setState(() {});
                                            },
                                            model: widget.model,
                                          )
                                        : const SizedBox(),

                                orientation == Orientation.landscape
                                    ? const SizedBox()
                                    : allSettings.value.enableFbAds == '1' &&
                                            widget.model!.question == null &&
                                            widget.index >=
                                                int.parse(allSettings
                                                    .value.fbAdsFrequency
                                                    .toString()) &&
                                            widget.index % admobFreq +
                                                    fbadsFreq ==
                                                0
                                        ? Platform.isIOS &&
                                                allSettings.value
                                                        .fbAdsPlacementIdIos !=
                                                    null
                                            ? facebookads(context)
                                            : Platform.isAndroid &&
                                                    allSettings.value
                                                            .fbAdsPlacementIdAndroid !=
                                                        null
                                                ? facebookads(context)
                                                : const SizedBox()
                                        : const SizedBox(),

                                orientation == Orientation.landscape
                                    ? const SizedBox()
                                    : allSettings.value.enableAds == '1' &&
                                            widget.model!.question == null &&
                                            widget.index >=
                                                int.parse(allSettings
                                                    .value.admobFrequency
                                                    .toString()) &&
                                            widget.index % admobFreq == 0
                                        ? Platform.isIOS &&
                                                allSettings.value
                                                        .admobBannerIdIos !=
                                                    null
                                            ? bannerAdMob(context)
                                            : Platform.isAndroid &&
                                                    allSettings.value
                                                            .admobBannerIdAndroid !=
                                                        null
                                                ? bannerAdMob(context)
                                                : const SizedBox()
                                        : const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      orientation == Orientation.landscape
                          ? const SizedBox()
                          : Positioned(
                              top: height10(context) * 26.25,
                              child: Container(
                                width: size(context).width,
                                alignment: Alignment.center,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                padding: EdgeInsets.only(
                                    top: height10(context),
                                    bottom: height10(context),
                                    left: 24,
                                    right: 24),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: widget.model!.blogSubCategory !=
                                                  null &&
                                              widget.model!.blogSubCategory!
                                                  .isNotEmpty
                                          ? [
                                              ...widget.model!.blogSubCategory!
                                                  .take(1)
                                                  .map(
                                                    (e) => CategoryWrap(
                                                        color: hexToRgb(
                                                            e.color.toString()),
                                                        name:
                                                            e.name.toString()),
                                                  )
                                            ]
                                          : [
                                              CategoryWrap(
                                                  color: hexToRgb(widget
                                                      .model!.categoryColor
                                                      .toString()),
                                                  name: widget
                                                      .model!.categoryName
                                                      .toString()),
                                            ],
                                    ),
                                    VisibilityDetector(
                                      key: Key(widget.model!.title.toString()),
                                      onVisibilityChanged:
                                          (visibilityInfo) async {
                                        // print(isPlay);
                                        var visiblePercentage =
                                            visibilityInfo.visibleFraction *
                                                100.0;
                                        if (visiblePercentage == 100.0) {
                                          provider!.addviewData(
                                              widget.model!.id!.toInt());
                                        }
                                        if (visiblePercentage != 100.0) {
                                          var blogendTime = DateTime.now();
                                          provider!.addBlogTimeSpent(BlogTime(
                                              id: widget.model!.id,
                                              startTime: blogStartTime,
                                              endTime: blogendTime));
                                          if (isVolume) {
                                            stop();
                                            if (allSettings
                                                        .value.googleApikey !=
                                                    null &&
                                                allSettings
                                                        .value.isVoiceEnabled ==
                                                    true) {
                                              stops();
                                            }
                                            endTime = DateTime.now()
                                                .toIso8601String();

                                            ttsData = {
                                              "id": widget.model!.id,
                                              "start_time": startTime,
                                              "end_time": endTime
                                            };
                                            setState(() {});
                                            //WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                            provider!.addTtsData(
                                                ttsData['id'],
                                                ttsData['start_time'],
                                                ttsData['end_time']);

                                            //   });
                                          }

                                          if (mounted) {
                                            isVolume = false;
                                            setState(() {});
                                          }
                                        }
                                      },
                                      child: PostFeatureWrap(
                                          isVolume: isVolume,
                                          onVoice: () async {
                                            if (allSettings
                                                        .value.googleApikey !=
                                                    null &&
                                                allSettings
                                                        .value.isVoiceEnabled ==
                                                    true) {
                                              if (isVolume == false) {
                                                isVolume = true;
                                                if (widget.model!.audioData ==
                                                    null) {
                                                  await speech(parse(widget
                                                              .model!
                                                              .description
                                                              .toString())
                                                          .body!
                                                          .text)
                                                      .then((value) async {
                                                    if (value != null) {
                                                      playLocal(value);
                                                    }
                                                  });
                                                } else {
                                                  playLocal(audioLoad ??
                                                      widget.model!.audioData
                                                          as Uint8List);
                                                }
                                              } else {
                                                isVolume = true;
                                                stops();
                                              }
                                              setState(() {});
                                            } else {
                                              if (isVolume == false) {
                                                init(parse(widget
                                                        .model!.description
                                                        .toString())
                                                    .body!
                                                    .text);
                                                isVolume = true;
                                                //if (startTime == '') {
                                                startTime = DateTime.now()
                                                    .toIso8601String();
                                                ttsData = {
                                                  "id": widget.model!.id,
                                                  "start_time": startTime,
                                                  "end_time": endTime
                                                };
                                                setState(() {});

                                                //  }
                                              } else {
                                                stop();
                                                endTime = DateTime.now()
                                                    .toIso8601String();
                                                ttsData = {
                                                  "id": widget.model!.id,
                                                  "start_time": startTime,
                                                  "end_time": endTime
                                                };
                                                // if (startTime != '') {

                                                //  }
                                                provider!.addTtsData(
                                                    ttsData['id'],
                                                    ttsData['start_time'],
                                                    ttsData['end_time']);
                                                isVolume = false;
                                              }
                                            }
                                            print(ttsData);
                                            setState(() {});
                                          },
                                          provider: provider2,
                                          model: widget.model as Blog,
                                          isBookmarkContains: provider!
                                              .permanentIds
                                              .contains(widget.model!.id),
                                          onBookmark: currentUser.value.id ==
                                                  null
                                              ? () {
                                                  Navigator.pushNamed(
                                                      context, '/LoginPage');
                                                }
                                              : () {
                                                  if (!provider!.permanentIds
                                                      .contains(
                                                          widget.model!.id)) {
                                                    showCustomToast(
                                                        context,
                                                        allMessages.value
                                                                .bookmarkSave ??
                                                            'Bookmark Saved');
                                                    provider!.addBookmarkData(
                                                        widget.model!.id!
                                                            .toInt());
                                                  } else {
                                                    showCustomToast(
                                                        context,
                                                        allMessages.value
                                                                .bookmarkRemove ??
                                                            'Bookmark Removed');
                                                    provider!
                                                        .removeBookmarkData(
                                                            widget.model!.id!
                                                                .toInt());
                                                  }
                                                  provider!.setBookmark(
                                                      blog:
                                                          widget.model as Blog);
                                                  setState(() {});
                                                },
                                          onShare: () async {
                                            // await createDynamicLink(widget.model ?? Blog())
                                            isShare = true;
                                            setState(() {});
                                            Future.delayed(const Duration(
                                                milliseconds: 100));
                                            await captureScreenshot(
                                                    previewContainer,
                                                    isPost: true)
                                                .then((value) async {
                                              Future.delayed(const Duration(
                                                  milliseconds: 10));
                                              final data2 =
                                                  await convertToXFile(value!);
                                              Future.delayed(const Duration(
                                                  milliseconds: 10));
                                              shareImage(data2);
                                              provider!.addShareData(
                                                  widget.model!.id!.toInt());
                                              isShare = false;
                                              setState(() {});
                                            });
                                          }),
                                    )
                                  ],
                                ),
                              ),
                            ),
                      orientation == Orientation.landscape
                          ? const SizedBox()
                          : Positioned(
                              top: 22,
                              left: 34,
                              width: size(context).width / 1.2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Backbut(
                                      key: const ValueKey('34543'),
                                      onTap: widget.onTap ??
                                          () {
                                            Navigator.pop(context);
                                          }),
                                  //  TapInk(
                                  // pad: 4,
                                  // radius: 6,
                                  // onTap: () {
                                  //    BottomSheetWidget.bottom(context,const SizedBox(),
                                  //    isScrollable: true,
                                  //    title: 'Swipe Metrics');
                                  // },
                                  // child:Container(
                                  //   padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 6),
                                  //   decoration: BoxDecoration(
                                  //      color: Theme.of(context).primaryColor,
                                  //     borderRadius: BorderRadius.circular(8)
                                  //   ),
                                  //   child: const Row(
                                  //     children: [
                                  //       Icon(Icons.add,
                                  //       size: 18,
                                  //       color:Colors.black),
                                  //       Text('Swipe Test',style: TextStyle(fontFamily: 'Roboto',fontSize: 16),)
                                  //     ],
                                  //   ),
                                  // )),
                                ],
                              )),
                    ],
                  ),
                );
              }),
            )),
      ),
    );
  }

  Container bannerAdMob(BuildContext context) {
    return Container(
      key: ValueKey("GoogleAds${widget.index}"),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: size(context).width,
      height: height10(context) * 5,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // image: const DecorationImage(
        //   image: AssetImage('assets/images/ads.png'),
        //   )
      ),
      child: BannerAds(
        // key:  ValueKey("GoogleAds${widget.index}"),
        adUnitId: Platform.isIOS
            ? allSettings.value.admobBannerIdIos ?? ''
            : allSettings.value.admobBannerIdAndroid ?? '',
      ),
    );
  }

  Container facebookads(BuildContext context) {
    return Container(
        key: ValueKey('FbAds${widget.index}'),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: size(context).width,
        height: height10(context) * 5,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: FacebookAd(
          adUnitId: Platform.isIOS
              ? allSettings.value.fbAdsPlacementIdIos ?? ''
              : allSettings.value.fbAdsPlacementIdAndroid ?? '',
        ));
  }
}
