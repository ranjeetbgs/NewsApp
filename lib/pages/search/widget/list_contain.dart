import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:incite/api_controller/app_provider.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/utils/image_util.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/anim_util.dart';
import 'package:incite/widgets/gradient.dart';
import 'package:incite/widgets/tap.dart';
import 'package:provider/provider.dart';

import '../../../api_controller/user_controller.dart';
import '../../../model/blog.dart';
import '../../../utils/time_util.dart';
import '../../../widgets/custom_toast.dart';

class ListWrapper extends StatelessWidget {
  const ListWrapper({super.key,required this.onTap,
  this.isSearch=false,
   this.onChanged,
   this.isBookmark=false,
   required this.e,
   required this.index
   });

  final Blog e;
  final bool isBookmark,isSearch;
  final int index;
  final ValueChanged? onChanged;
  final VoidCallback onTap; 

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var  provider = Provider.of<AppProvider>(context,listen:false);
    return TapInk(
      splash: ColorUtil.whiteGrey,
      onTap: onTap,
      child: Container(
          width: size.width,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          margin: const EdgeInsets.only(top: 12.5,bottom: 12.5),
          child: Row(
            children: [
               AnimationFadeScale(
                      duration: index*150,
                 child:e.images!.isNotEmpty ?
                 CircleAvatar(
                  radius: 32,
                  backgroundImage:
                   CachedNetworkImageProvider( e.images![0] ?? ''),
                ): CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage(Img.logo)
                   ,
                ),
               ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     AnimationFadeSlide(
                      dx: (index*0.4),
                      duration: index*150,
                      child:  Text(e.title ?? 'How analysis essays are the new analysis essays',
                      maxLines: 2,
                      style:  const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                      )),),
                     const Spacer(),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Row(
                           children: [
                              GradientText(e.categoryName ?? 'Business',
                             gradient: primaryGradient(context),
                             style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12
                              )),
                              Padding(padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: CircleAvatar(radius: 2,
                              backgroundColor: dark(context) ? ColorUtil.whiteGrey : ColorUtil.textblack),
                              ),
                              Text( e.scheduleDate==null ?
                              '':timeFormat(DateTime.tryParse(e.scheduleDate!.toIso8601String())),style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12,
                              color:  dark(context) ? ColorUtil.whiteGrey : ColorUtil.textblack
                              )),
                           ],   
                         ),
                          Row(
                            children: [
                              InkResponse(
                                splashColor: Theme.of(context).primaryColor.withOpacity(0.4),
                                radius: 24,
                                  onTap: currentUser.value.id == null ?(){
                                       Navigator.pushNamed(context, '/LoginPage');
                                  } : isSearch ? () {
                                    if ( provider.permanentIds.contains(e.id)) {
                                   
                                      provider.removeBookmarkData(e.id!.toInt());
                                      showCustomToast(context,allMessages.value.bookmarkRemove ?? 'Bookmark Removed');
                                   }else{
                                      provider.addBookmarkData(e.id!.toInt());
                                     showCustomToast(context,allMessages.value.bookmarkSave ?? 'Bookmark Saved');
                                   }
                                   onChanged!(e.isBookmark);
                                  } : () {
                                  if (isBookmark == true) {
                                      provider.removeBookmarkData(e.id!.toInt());
                                      showCustomToast(context,allMessages.value.bookmarkRemove ?? 'Bookmark Removed');
                                   }
                                    onChanged!(e);
                                },
                                child: SvgPicture.asset(
                                  provider.permanentIds.contains(e.id)
                                ? SvgImg.fillBook :SvgImg.bookmark,
                                  width: 20,height: 20,key: ValueKey(provider.permanentIds.contains(e.id)),
                                color: Theme.of(context).primaryColor) 
                              ),
                              // const SizedBox(width: 12.5),
                              //  InkResponse(
                              //   radius: 24,
                              //    splashColor: Theme.of(context).primaryColor.withOpacity(0.4),
                              //   onTap: () {
                                  
                              //   },
                              //   child: SvgPicture.asset(SvgImg.share,width: 20,height: 20,
                              //  color: dark(context)? ColorUtil.white: ColorUtil.textblack)),
                            ],
                          ),
                       ],
                     )
                  ],
                ),
              )
            ],
          ),
        ),
    
    );
  }
}