import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/back.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:photo_view/photo_view.dart';

import '../../../utils/color_util.dart';

class FullScreen extends StatefulWidget {
  const FullScreen({super.key,required this.image,this.images,this.isProfile=false,required this.index,this.title,});
  final String? image,title;
  final int index;
  final List? images;
  final bool isProfile;

  @override
  State<FullScreen> createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {

late PreloadPageController pageController;

@override
void initState(){
 
    pageController = PreloadPageController(initialPage: widget.index);
  
  super.initState();
}

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      child:Stack(
          children: [ Container(
       width: size(context).width, 
       height: size(context).height,
       alignment: Alignment.center,
        child:
             Stack(
          children: [
           Positioned.fill(
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                width: size(context).width,
                height: size(context).height,
                color: Colors.transparent,
              ),
            )),
           widget.images != null
          ? Positioned(child: SizedBox(
            width: size(context).width,
            height: size(context).height,
            child: PreloadPageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: pageController,
                      itemCount: widget.images!.length,
                      onPageChanged: (value) {
                        currentIndex = value;
                        setState(() {  });
                      },
                      preloadPagesCount: widget.images!.length,
                      itemBuilder: (context, index) {
                        return Hero(
                        tag: widget.images![index],
                        child: Container(
                          decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(16)
                        ),
                        width: size(context).width,
                        child:PhotoView(
                              enableRotation :false,
                              minScale : 0.3,
                              backgroundDecoration: BoxDecoration(
                                color:Theme.of(context).scaffoldBackgroundColor
                              ),
                              imageProvider:  CachedNetworkImageProvider(widget.images![index],
                               ),
                            ) ));
                      },
                    ),
          ))
           :  Positioned(
              child: Hero(
                tag: '${widget.index}${widget.image}',
                child: PhotoView(
                      enableRotation :false,
                      minScale : 0.3,
                      backgroundDecoration: BoxDecoration(
                        color:Theme.of(context).scaffoldBackgroundColor
                      ),
                      imageProvider:  CachedNetworkImageProvider(widget.image ?? '',
                      ),
                    ) 
              ),
            ),
          //  Padding(
          //    padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 12),
          //    child: TitleWidget(title: title,size: 16),
          //  )
          ],
        ),
      ),
          Positioned(
          left: widget.isProfile==true ? 20 : 34,
          top: widget.isProfile==true ? 12 : 22,
          child:  SafeArea(
            child: SizedBox(
              width: size(context).width/1.2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Backbut(),
                  if( widget.images != null)
                  const Spacer(),
                   if( widget.images != null)
                  Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.black.withOpacity(0.3)
                ),
                padding:const EdgeInsets.symmetric(vertical: 6,horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      SizedBox(
                      child: Text(
                        // key: ValueKey(index),
                        "${currentIndex+1} / ${widget.images!.length}",
                       style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                         color:  ColorUtil.whiteGrey,
                       ),
                      ))
                  ],
                  ),
              )
                ],
              ),
            ))
        ),
      ])
    );
  }
}