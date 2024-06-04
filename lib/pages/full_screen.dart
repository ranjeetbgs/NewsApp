// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'main/widgets/youtube_video.dart';

// class YoutubeVideoScreen extends StatefulWidget {
//   final String videoId;
//   final Duration currentPosition;

//  const YoutubeVideoScreen({super.key, required this.videoId,required this.currentPosition});

//   @override
//   _YoutubeVideoScreenState createState() => _YoutubeVideoScreenState();
// }

// class _YoutubeVideoScreenState extends State<YoutubeVideoScreen> {
//   // late YoutubePlayerController _controller ;
  
//   Duration? _currentPosition;


//   @override
//   Widget build(BuildContext context) {
//       SystemChrome.setPreferredOrientations([
//               DeviceOrientation.landscapeLeft,
//               DeviceOrientation.landscapeRight,
//       ]);
//     return Scaffold(
//       body: RepaintBoundary(
//         key: Key(widget.videoId),
//           child: YouTubeVideo(
//               videoUrl: widget.videoId,
//           ),
//         )
//     );
//   }

  
// }
