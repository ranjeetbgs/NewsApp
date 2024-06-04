import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:preload_page_view/preload_page_view.dart';

import '../../../model/blog.dart';
import '../../../utils/color_util.dart';
import '../../../utils/image_util.dart';
import '../../../utils/nav_util.dart';
import 'fullscreen.dart';

//https://newinciteweb.technofox.co.in/api/blog-list

class CaurosalSlider extends StatefulWidget {
  const CaurosalSlider({super.key, required this.model});
  final Blog model;

  @override
  State<CaurosalSlider> createState() => _CaurosalSliderState();
}

class _CaurosalSliderState extends State<CaurosalSlider> {
  Timer? timer;
  late PreloadPageController pageController;
  int currentIndex = 0;

  @override
  void initState() {
    pageController = PreloadPageController();
    slider();

    super.initState();
  }

  slider() {
    if (widget.model.images!.length > 1) {
      timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        if (currentIndex < widget.model.images!.length - 1) {
          currentIndex++;
        } else {
          currentIndex = 0;
        }
        if (pageController.hasClients) {
          pageController.animateToPage(
            currentIndex,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: size(context).width,
        height: height10(context) * 25,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(30, 30, 30, 0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              top: -20,
              left: -20,
              right: -20,
              bottom: -20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: 25,
                        sigmaY: 25,
                        // tileMode: TileMode.decal,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                              "${allSettings.value.baseImageUrl}/${allSettings.value.appLogo}",
                              errorListener: (e) {
                                Image.asset(Img.logo,
                                    color: dark(context)
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200);
                              },
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),
                ),
              ),
            ),
            Positioned.fill(
              child: SizedBox(
                width: size(context).width,
                height: height10(context) * 25,
                child: PreloadPageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: pageController,
                  itemCount: widget.model.images!.length,
                  onPageChanged: (value) {
                    currentIndex = value;
                    setState(() {});
                  },
                  preloadPagesCount: widget.model.images!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              PagingTransform(
                                  widget: FullScreen(
                                    image:
                                        widget.model.images![index].toString(),
                                    index: index,
                                    images: widget.model.images,
                                    title: widget.model.title.toString(),
                                  ),
                                  slideUp: true));
                        },
                        child: Hero(
                            tag: widget.model.images![index],
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16)),
                              width: size(context).width,
                              child: CachedNetworkImage(
                                imageUrl: widget.model.images![index],
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return Image.asset(Img.cat2);
                                },
                              ),
                            )));
                  },
                ),
              ),
            ),
            Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.black.withOpacity(0.3)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          child: Text(
                        // key: ValueKey(index),
                        "${currentIndex + 1} / ${widget.model.images!.length}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ColorUtil.whiteGrey,
                        ),
                      ))
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
