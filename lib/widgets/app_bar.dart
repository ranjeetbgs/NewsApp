import 'package:flutter/material.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/anim_util.dart';
import 'package:incite/widgets/back.dart';

import '../api_controller/user_controller.dart';
import '../utils/color_util.dart';

class CommonAppbar extends StatelessWidget {
  const CommonAppbar({super.key,this.title,this.isPinned=false});
  final String? title;
  final bool isPinned;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      child: SliverAppBar(
        centerTitle: false,
        leadingWidth: 0,
        pinned: isPinned,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        titleSpacing: 24,
        title: Row(
          children: [
            const Backbut(),
            const SizedBox(width: 15),
            AnimationFadeSlide(
             dx: 0.3,
             duration: 500,
              child: Text(title ?? allMessages.value.searchStories ?? 'Search Stories'
              ,style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                color: dark(context) ? ColorUtil.white : ColorUtil.textblack,
                fontWeight: FontWeight.w600
              )),
            )
          ],
        ),
      ),
    );
  }
}