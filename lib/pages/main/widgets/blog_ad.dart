import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:incite/pages/main/web_view.dart';
import 'package:incite/pages/main/widgets/youtube_shorts.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/utils/image_util.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/button.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../model/blog.dart';
import '../../../widgets/back.dart';

class BlogAd extends StatefulWidget {
  const BlogAd({super.key,this.isBack=false,this.model,required this.onTap});
  final VoidCallback onTap;
  final Blog? model;
  final bool isBack;

  @override
  State<BlogAd> createState() => _BlogAdState();
}

class _BlogAdState extends State<BlogAd> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size(context).width,
      height: size(context).height,
      child: Scaffold(
        body: SafeArea(
          left: false,
          right: false,
          child: Stack(
            fit: StackFit.expand,
            children: [
          if(widget.model!.images != null && widget.model!.mediaType == 'image')
           CachedNetworkImage(
           imageUrl: widget.model!.media ?? '',
           errorWidget: (context, url, error) {
             return Image.asset('assets/images/ad.png',
             fit: BoxFit.cover);
           },
            fit: BoxFit.cover)
            else if(widget.model!.videoUrl != null &&  widget.model!.mediaType == 'video_url')
            YouTubeShort(
              
              onTap: () {
                
              },
              
              model: widget.model)
            else if(widget.model!.videoUrl != null && widget.model!.mediaType == 'video')
            MyVideoPlayer(url: widget.model!.media ?? ''),
             if(widget.model!.sourceLink != '')
             Positioned(
              left: 24,
              right: 24,
              bottom: height10(context) * 3,
              child: SizedBox(
              child: IconTextButton(
              text: widget.model!.sourceName ?? 'Explore Now',  
              splash: ColorUtil.whiteGrey,
              width: size(context).width,
              trailIcon: SvgPicture.asset(SvgImg.arrowRight,
             color:  ColorUtil.textblack,
              width: 20,
              height: 20,
              ),
              color: ColorUtil.whiteGrey,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 18,
                color: ColorUtil.textblack,
                fontWeight: FontWeight.w500
              ),
              onTap:() {
              Navigator.push(context, CupertinoPageRoute(
               builder: (context) => CustomWebView(url: widget.model!.sourceLink.toString())));
              },
              ) )),
             Positioned(
              top: 16,
              left: 24,
              width: size(context).width/1.2,
              child: SafeArea(
                child: Row(
                  mainAxisAlignment : MainAxisAlignment.spaceBetween,
                  children: [
                    Backbut(
                      onTap: widget.isBack ? (){
                      Navigator.pop(context);
                    } : widget.onTap)
                ]),
              )
              ),
            ]),
        ),
      ),
    );
  }
}




class MyVideoPlayer extends StatefulWidget {
  const MyVideoPlayer({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    controller.initialize().then((_) {
      // precache the video
      controller.setLooping(true);
      controller.setVolume(0);
       controller.play();
      // controller.play();
      setState(() {});
      // controller.pause();
    });
  }


@override
  void didChangeDependencies() {
    controller.pause();
    super.didChangeDependencies();
  }


    @override
    void dispose() {
      controller.pause();
      controller.dispose();
      super.dispose();
    }

  bool _audioEnabled = false;
  void _toggleAudio() {
    setState(() {
      _audioEnabled = !_audioEnabled;
      controller.setVolume(0);
      controller.setVolume(_audioEnabled ? 100 : 0);
    });
  }

  // void _playPause() {
  //   if (_isPlay == true) {
  //     setState(() {
  //       controller.pause();
  //     });
  //   } else {
  //     setState(() {
  //       controller.play();
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [VisibilityDetector(
      key: Key(widget.key.toString()),
      onVisibilityChanged: (visibility) {
        var visiblePercentage = visibility.visibleFraction * 100;
        if (visiblePercentage < 1 && mounted) {
          controller.pause();
            setState(() { });
          //pausing  functionality
        } else if (mounted) {
          controller.play();
          setState(() { });
          //playing  functionality
        }
      },
      child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(
              controller,
            ),
          ),
        ),
        // Positioned(
        //     top: 0,
        //     left: 0,
        //     bottom: 0,
        //     right: 0,
        //     child: InkResponse(
        //       onTap: _playPause,
        //       child: CircleAvatar(
        //           backgroundColor: Colors.black26,
        //           child: controller.value.isPlaying
        //               ? const Icon(
        //                   Icons.pause,
        //                   color: Colors.white,
        //                 )
        //               : const Icon(
        //                   Icons.arrow_forward,
        //                   color: Colors.white,
        //                 )),
        //     )),
        
            Positioned(
            top: 16,
            right: 16,
            child: InkResponse(
              onTap: _toggleAudio,
              child: CircleAvatar(
              backgroundColor: Colors.black26,
              child: _audioEnabled
                  ? const Icon(
                      Icons.volume_up_outlined,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.volume_off_outlined,
                      color: Colors.white,
                    )),
            ))
      ],
    );
  }
}
