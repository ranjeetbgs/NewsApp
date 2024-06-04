
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/pages/live_news.dart';
import 'package:incite/pages/main/widgets/youtube_video.dart';
import 'package:incite/urls/url.dart';
import 'package:incite/widgets/anim.dart';
import 'package:incite/widgets/shimmer.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as convert;

import '../../api_controller/news_repo.dart';
import '../../utils/app_theme.dart';
import '../../utils/color_util.dart';
import '../../utils/theme_util.dart';
import '../../widgets/anim_util.dart';
import '../../widgets/back.dart';


class LiveNews extends StatefulWidget {
  const LiveNews({Key? key}) : super(key: key);

  @override
  _LiveNewsState createState() => _LiveNewsState();
}

class _LiveNewsState extends StateMVC {

  bool isFullscreen = false;
  int? selectedVideo;
  convert.YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
  if (liveNews.isNotEmpty) {
   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
      selectedVideo=0;
      setVideo();
     });
   });
  } else {
    getliveNews().then((value) {
      setState(() {
        selectedVideo=0;
        setVideo();
      });
    });
  }
  }

  setVideo() {
    final videoId = convert.YoutubePlayer.convertUrlToId(
      liveNews[selectedVideo!.toInt()].url
          .toString(),
    );
    _controller = convert.YoutubePlayerController(
      initialVideoId: videoId.toString(),
      flags: const convert.YoutubePlayerFlags(autoPlay: true),
    );
    _controller!.load(videoId.toString());

    // _controller!.addListener(() {
    //   if (_controller != null) {
    //     _enableFullscreen(_controller!.value.isFullScreen);
    //   }
    // });
  }

  void _enableFullscreen(bool fullscreen) {
    // isFullscreen = fullscreen;
    // setState(() {});
    if (fullscreen == true) {
      // Force landscape orientation for fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    // else {
    //   // Force portrait
    //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //       overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    //   SystemChrome.setPreferredOrientations([
    //     DeviceOrientation.portraitUp,
    //     DeviceOrientation.portraitDown,
    //   ]);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_controller == null) {
          Navigator.pop(context);
        }
        if (isFullscreen == true || _controller!.value.isFullScreen == true) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
          // _enableFullscreen(false);
          _controller!.toggleFullScreenMode();
          isFullscreen = false;
          setState(() {});
        } else {
          Navigator.pop(context);
        }
        return false;
      },
      child:  Scaffold(
        appBar: isFullscreen == true
            ? AppBar(
                backgroundColor: Colors.transparent,
                toolbarHeight: 0,
                elevation: 0,
              )
            : AppBar(
        centerTitle: false,
        leadingWidth: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        automaticallyImplyLeading: false,
        titleSpacing: 24,
        toolbarHeight: 65,
        elevation: 0,
        title: Row(
          children: [
            const Backbut(),
            const SizedBox(width: 15),
            AnimationFadeSlide(
             dx: 0.3,
             duration: 500,
              child: Text( allMessages.value.liveNews ?? 'Live News',style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                color: dark(context) ? ColorUtil.white : ColorUtil.textblack,
                fontWeight: FontWeight.w600
              )),
            )
          ],
        ),
      ), 
        body: liveNews.isEmpty
            ?  SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 24),
                child: Column(
                  children: [
                   ...List.generate(8, (index) => const ListShimmer())
                  ],
                ),
              ),
            )
            : Column(
                children: [
                  //video player
                  selectedVideo == null
                      ? const ListShimmer()
                      :  RepaintBoundary(
                        child:  Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: SizedBox(
                                      // key: ValueKey(_controller!.value.isFullScreen),
                                        height: _controller!.value.isFullScreen == true
                                            ? MediaQuery.of(context).size.height - 12
                                            : height10(context) * 25,
                                        width: MediaQuery.of(context).size.width,
                                        child: convert.YoutubePlayerBuilder(
                                          key:ValueKey(selectedVideo),
                                      onEnterFullScreen: () {
                                        isFullscreen = true;
                                         SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
                                          SystemChrome.setPreferredOrientations([
                                            DeviceOrientation.landscapeLeft,
                                            DeviceOrientation.landscapeRight,
                                          ]);
                                       Future.delayed(const Duration(milliseconds: 300), () {
                                          _controller!.play();
                                      });
                                      
                                        setState(() { });
                                      },
                                      onExitFullScreen: () {
                                        isFullscreen = false;
                                        
                                           SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                                            overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
                                        SystemChrome.setPreferredOrientations([
                                          DeviceOrientation.portraitUp,
                                          DeviceOrientation.portraitDown,
                                        ]);
                                        Future.delayed(const Duration(milliseconds: 300), () {
                                        _controller!.play();
                                         });
                                        setState(() { });
                                      },
                                      player:convert.YoutubePlayer(
                                          controller: _controller!,
                                          aspectRatio: 16 / 9,
                                          // bottomActions: [
                                          //   IconButton(
                                          //     onPressed: () {
                                          //        isFullscreen = true;
                                          //       _controller!.toggleFullScreenMode();
                                          //       // _enableFullscreen(isFullscreen);
                                          //       setState(() { });
                                          //   }, icon: const Icon(Icons.fullscreen_sharp,color: Colors.white))
                                          // ],
                                        ),
                                        builder: (context, player) {
                                          return player;
                                        },
                                      )
                            ),
                          ),
                        )
                      ),
                        
                  selectedVideo == null
                      ? Container()
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                 imageUrl: liveNews[selectedVideo!.toInt()].image.toString(),
                                  height: 30,
                                  width: 30,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(liveNews[selectedVideo!.toInt()]
                                    .companyName
                                    .toString(),
                                style: TextStyle(
                                    color: appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black.withOpacity(0.88),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                       const Divider(height: 1,thickness: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: liveNews.length,
                      itemBuilder: (context, index) {
                        return  Container(
                          height: 100,
                           foregroundDecoration : BoxDecoration(
                            color: selectedVideo != index ? Colors.transparent : Theme.of(context).primaryColor.withOpacity(0.1),
                           ),
                          child: LiveWidget(
                              padding: const EdgeInsets.only(top: 16,bottom: 16,),
                              title: liveNews[index].companyName,
                              fontWeight: FontWeight.w500,
                              isPlay:  selectedVideo == index,
                              image: liveNews[index].image,
                              playState: selectedVideo == index && _controller!.value.isPlaying,
                               onTap: () {
                                  setState(() {
                                    selectedVideo = index;
                                    setVideo();
                                  });
                                },
                              ),
                          
                        );
                      },
                    ),
                  ),
                ],
              ),
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }
}
