
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/utils/image_util.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/app_bar.dart';
import 'package:incite/widgets/shimmer.dart';
import 'package:incite/widgets/tap.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as convert;
import '../api_controller/news_repo.dart';
import '../model/news.dart';

class LiveNewsPage extends StatefulWidget {
  const LiveNewsPage({super.key});

  @override
  State<LiveNewsPage> createState() => _LiveNewsPageState();
}

class _LiveNewsPageState extends State<LiveNewsPage>  {
  // ... your code ...

  bool load=true;
  LiveNews? live;
  bool isFullScreen = false;
  
  
  int? selectedVideo;
  convert.YoutubePlayerController? _controller;
  
  bool isFullscreen=false;


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() { 
        load = true;
     });
     if (liveNews.isNotEmpty) {
        live = liveNews[0];
         setVideo();
         print('object');
        setState(() { });
     } else {
      getliveNews().then(( value) async{
        live = liveNews[0];
         await setVideo();
         setState(() { });
      });
     }
    });
    super.initState();
  }

  
 @override
  void didChangeDependencies() {
  
    load = false;
    setState(() { });
    super.didChangeDependencies();
  }


  setVideo() async {
    final videoId = convert.YoutubePlayer.convertUrlToId(
        live!.url.toString(),
    );
    _controller = convert.YoutubePlayerController(
      initialVideoId: videoId.toString(),
      flags: const convert.YoutubePlayerFlags(autoPlay: true),
    );
    _controller!.load(videoId.toString());

    _controller!.addListener(() {
      if (_controller != null) {
        _enableFullscreen(_controller!.value.isFullScreen);
      }
    });
  }
  void _enableFullscreen(bool fullscreen) {
    isFullscreen = fullscreen;
    setState(() {});
    if (fullscreen) {
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
    var landscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return  WillPopScope(
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
      child:  Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
    
            SystemChrome.setPreferredOrientations(DeviceOrientation.values);
            Navigator.pop(context);
          }
        },
        child: Scaffold(
              body: CustomScrollView(
                slivers: [
                 landscape ? const SliverToBoxAdapter() : const CommonAppbar(
                    title: 'Live News',
                  ),
                  landscape ? const SliverToBoxAdapter() :const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal:landscape ? 0 : 24),
                    sliver: SliverToBoxAdapter(
                      child: Stack(
                        children: [
                            Builder(key: ValueKey(live ?? 0),
                              builder: (context) {
                                return Container(
                                height: landscape ? size(context).height  :size(context).height*0.222,
                                width: size(context).width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image:liveNews.isEmpty  ? null :  DecorationImage(image: 
                                  CachedNetworkImageProvider('${allSettings.value.baseImageUrl}/${allSettings.value.liveNewsLogo.toString()}'),fit: BoxFit.cover)
                                ),
                                child: liveNews.isEmpty && live == null && liveNews.isEmpty  
                                 ? const Row(
                                   children: [
                                      ShimmerLoader(),
                                      ListShimmer()
                                   ],
                                 )  
                                  : convert.YoutubePlayer(
                                     controller: _controller!,
                                   aspectRatio: 16/9,
                                  
                                ),
                          );
                              }
                            ),
                          // Positioned(
                          //   top: 15,
                          //   left: 15,
                          //   right: 15,
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //        Row(
                          //         children: [
                          //         liveNews.isEmpty ? const ShimmerLoader(
                          //           width: 30,
                          //           height: 30,
                          //           borderRadius: 100,
                          //          ) : CircleAvatar(radius: 15,
                          //           backgroundImage: CachedNetworkImageProvider(live!.image.toString())),
                          //           const SizedBox(width: 12),
                          //            liveNews.isEmpty   ?  ShimmerLoader(
                          //           width: size(context).width/2,
                          //           height: 30,
                          //          ) : Text(live!.companyName.toString(),
                          //            style: const TextStyle(
                          //             fontFamily: 'Roboto',
                          //             fontSize: 14,
                          //             color: Colors.white
                          //           )),
                          //         ],
                          //       ),
                                // TapInk(
                                //   onTap: (){} ,
                                //   child: const Icon(Icons.more_vert,size: 16,color: Colors.white))
                            //   ],/
                            // ))
                        ],
                      ),
                    ),
                  ),
                   SliverToBoxAdapter(
                    child: Column(
                      children : landscape ? []
                       : [
                        ...liveNews.asMap().entries.map((e) =>  LiveWidget(
                          title: e.value.companyName,
                          onTap:(){
                              live = e.value;
                              setVideo();
                              setState((){});
                          },
                          image: e.value.image,
                        ))
                      ],
                    ),
                  )
                ],
              ),
            )
       )
        );
  }
}

class ListShimmer extends StatelessWidget {
  const ListShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin : const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const ShimmerLoader(
         height: 70,
         width: 70,
         borderRadius: 100,
         ),
         const SizedBox(width:12),
         Column(
          children: [
            ShimmerLoader(width: size(context).width/2,height: 20),
            SizedBox(height: height10(context)),
             ShimmerLoader(width: size(context).width/2,height: 20)
          ],
         )
        ],
      ),
    );
  }
}

class LiveWidget extends StatelessWidget {
  const LiveWidget({
    super.key,
    this.title,
    this.fontWeight,
    this.onTap,
    this.playState=false,
    this.padding,
    this.image,
    this.radius,
    this.isPlay=false,
  });

final String? title,image;
final bool isPlay,playState;
final EdgeInsetsGeometry? padding;
final FontWeight? fontWeight;
final double? radius;
final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TapInk(
      splash: ColorUtil.textgrey,
      onTap: onTap ?? (){},
      child: Container(
        decoration: BoxDecoration(
          
          border: Border(bottom: BorderSide(width: 1,color: dark(context) ? ColorUtil.textgrey.withOpacity(0.3) :ColorUtil.textgrey.withOpacity(0.1) ))
        ),
        margin: const EdgeInsets.only(left: 20,right: 20),
        padding: padding ?? const EdgeInsets.only(top:16,bottom:16),
        child: Row(children: [
                  CircleAvatar(
                  radius:radius ?? 32,
                  backgroundImage: CachedNetworkImageProvider(image ?? Img.tv),
                  ),
                 const SizedBox(width: 15),
                 Expanded(
                   child: Text( 
                    title ?? 'Tv',
                    maxLines: 2,
                   style: TextStyle(
                    fontSize: 17,
                    color: textColor(context),
                    fontFamily: 'Roboto',
                    overflow: TextOverflow.ellipsis,
                    fontWeight: fontWeight ?? FontWeight.w500
                   )),
                 ),
                           
          ],
        ),)
    );
  }
}