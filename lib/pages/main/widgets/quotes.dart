import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:incite/api_controller/app_provider.dart';
import 'package:incite/pages/auth/signup.dart';
import 'package:incite/pages/main/widgets/share.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/utils/image_util.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/loader.dart';
import 'package:incite/widgets/tap.dart';
import 'package:provider/provider.dart';

import '../../../api_controller/blog_controller.dart';
import '../../../model/blog.dart';
import '../../../model/home.dart';
import '../../../widgets/back.dart';
import '../blog.dart';

class QuotePage extends StatefulWidget {
  const QuotePage({super.key,this.type,required this.model,required this.onTap});
  final Blog model;
  final BlogOptionType? type;
  final VoidCallback onTap;


  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {

  GlobalKey previewContainer = GlobalKey();
  bool load= false;
  late AppProvider provider;

  @override
  void initState() {
      provider = Provider.of<AppProvider>(context,listen: false);
     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      if (blogListHolder.getList().blogs.isNotEmpty && blogListHolder.getList().blogs[0].postType ==PostType.quote  &&
       blogListHolder.getList().blogs[0].backgroundImage != null) {
        precacheImage(CachedNetworkImageProvider(blogListHolder.getList().blogs[0].backgroundImage.toString()), context);
      }
      if (widget.type == BlogOptionType.share) {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
          // load=true;
          // setState(() {  });
          Future.delayed(const Duration(milliseconds: 1400)).then((value)async{
          final  data = await captureScreenshot(previewContainer);
            Future.delayed(const Duration(milliseconds: 10));
            final  data2 = await convertToXFile(data!);
            Future.delayed(const Duration(milliseconds: 10));
            provider.addShareData(widget.model.id!.toInt());
            shareImage(data2);
            //  load=false;
             setState(() {  });
          });
        });
      }

       provider.addviewData(widget.model.id!.toInt());
       setState(() { });
     });
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {

    return  SizedBox(
      width: size(context).width,
      height: size(context).height,
      child: CustomLoader(
      isLoading: load,
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children :[ 
            RepaintBoundary(
              key: previewContainer,
              child: Container(
                width: size(context).width,
                height: size(context).height,
                margin: const EdgeInsets.symmetric(vertical: 40,horizontal: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12)
                ),
                child: ClipRRect(
                   borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                     imageUrl: widget.model.backgroundImage.toString(),
                       height: double.infinity,
                       width: double.infinity,
                       alignment: Alignment.center,
                     fit: BoxFit.fitHeight),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: 30,
              width: size(context).width - 60,
              child: SizedBox(
                // color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // AppIcon(
                    //   width: 20,
                    //   height: 15,
                    // ),
                    RectangleAppNoIcon(
                      width: 80,
                      height: 60,
                    ),
                  ],
                ),
                    TapInk(
                      radius: 100,
                      pad: 8,
                      onTap: () async {
                        load=true;
                        setState(() {   });
                        Future.delayed(const Duration(milliseconds: 10));
                        final  data = await captureScreenshot(previewContainer);
                         Future.delayed(const Duration(milliseconds: 10));
                         final  data2 = await convertToXFile(data!);
                         Future.delayed(const Duration(milliseconds: 10));
                         provider.addShareData(widget.model.id!.toInt());
                          shareImage(data2);
                         load=false;
                         setState(() {   });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          gradient: primaryGradient(context)
                        ),
                        padding: const EdgeInsets.all(6),
                        child: SvgPicture.asset(
                          SvgImg.share,
                          color: Colors.white,
                        width: 20,height: 20,)
                      ),
                    ),
                
                     ]),
              ),
          ) ,
           Positioned(
                top: 22,
                left: 24,
                width: size(context).width/1.2,
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment : MainAxisAlignment.spaceBetween,
                    children: [
                      Backbut(onTap:widget.onTap)
                  ]),
                )
                )
         ])
        ),
      ),
    );
  }
}