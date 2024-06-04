import 'package:flutter/material.dart';
import 'package:incite/pages/main/widgets/text.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/back.dart';
import 'package:provider/provider.dart';

import '../../../api_controller/app_provider.dart';
import '../../../model/blog.dart';
import 'youtube_video.dart';

class YouTubeShort extends StatefulWidget {
  const YouTubeShort({super.key, this.model, required this.onTap});
  final VoidCallback onTap;
  final Blog? model;

  @override
  State<YouTubeShort> createState() => _YouTubeShortState();
}

class _YouTubeShortState extends State<YouTubeShort> {
  late AppProvider provider;

  @override
  void initState() {
    provider = Provider.of<AppProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      provider.addviewData(widget.model!.id!.toInt());
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            foregroundDecoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54])),
            child: RepaintBoundary(
              key: Key(widget.model.hashCode.toString()),
              child: YouTubeVideo(
                height: size(context).height,
                isMute: true,
                isPlay: false,
                hidecontrols: false,
                videoUrl: widget.model!.sourceLink,
              ),
            ),
          ),
          // Positioned(
          //   left: 24,
          //   top:kToolbarHeight,
          // child: Backbut(onTap: widget.onTap)
          // ),
          // Positioned(
          //   left: 24,
          //   right: 24,
          //   bottom: 20,
          //   child: Column(
          //   children: [
          //     TitleWidget(
          //       title: widget.model!.title,
          //       color: Colors.white,
          //     ),
          //   ],
          // ))
        ],
      ),
    );
  }
}
