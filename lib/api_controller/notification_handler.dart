// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:preload_page_view/preload_page_view.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
//
// import '../main.dart';
// import '../model/blog.dart';
// import '../pages/main/blog.dart';
// import '../urls/url.dart';
// import 'app_provider.dart';
// import 'blog_controller.dart';
//
// class NotificationHandler {
//
//   handleNotifications(OSNotificationClickEvent result)async{
//
//     log("Got Push Notification.........      ${result.notification.title}");
//     log("Got Push Notification.........      ${result.notification.body}");
//     log("Got Push Notification.........      ${result.notification.rawPayload}");
//     log("Got Push Notification.........      ${result.notification.buttons}");
//
//     if (appLoaded == false) {
//       await Future.delayed(const Duration(seconds: 5));
//     }
//     final blog = json.decode(result.notification.rawPayload!['custom'].toString())['a']['blog'];
//     final buttons = result.notification.buttons!.toList();
//     final action = result.notification.rawPayload!['actionId'];
//     //  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//     var provider = Provider.of<AppProvider>(navkey.currentState!.context, listen: false);
//
//     if (blog != null) {
//       // loading = true;
//       // Future.delayed(const Duration(seconds: 5)).then((value) {
//       //   loading = false;
//       // });
//       try {
//         var url = "${Urls.baseUrl}blog-detail/$blog";
//         var result = await http.get(
//           Uri.parse(url),
//         );
//         Map data = await json.decode(result.body);
//         if (data['success'] == true) {
//           final list = Blog.fromJson(data['data'], isNotification: true);
//           // print(list.type);
//
//           if (list.type == 'quote') {
//             var data = provider.allNews!.blogs;
//             provider.allNews!.blogs = [];
//             provider.allNews!.blogs.add(list);
//             if (data.isNotEmpty && data.contains(list)) {
//               data.remove(list);
//             }
//             provider.allNews!.blogs.addAll(data);
//             blogListHolder.clearList();
//             blogListHolder.setBlogType(BlogType.allnews);
//             blogListHolder.setList(provider.allNews as DataModel);
//             SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
//               navkey.currentState!.pushNamed('/BlogWrap', arguments: [
//                 0,
//                 false,
//                 PreloadPageController(),
//                 "noti${list.id}",
//                 action == 'Share' ? BlogOptionType.share : null,
//                 true
//               ]);
//             });
//           }
//           else {
//             if (list.images!.isNotEmpty) {
//               WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
//                 await precacheImage(CachedNetworkImageProvider(list.images![0]), navkey.currentState!.context);
//               });
//             }
//             if (buttons.isNotEmpty && action == 'Bookmark') {
//               updateBlogList(list, provider);
//               WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//                 navkey.currentState!.pushNamed('/BlogWrap',
//                     arguments: [0, false, PreloadPageController(), "noti${list.id}", BlogOptionType.bookmark, true]);
//               });
//             } else if (buttons.isNotEmpty && action == 'Share') {
//               updateBlogList(list, provider);
//               WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//                 navkey.currentState!.pushNamed('/BlogWrap',
//                     arguments: [0, false, PreloadPageController(), "noti${list.id}", BlogOptionType.share, true]);
//               });
//             } else {
//               // ignore: use_build_context_synchronously
//               updateBlogList(list, provider);
//               WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//                 navkey.currentState!.pushNamed('/BlogWrap',
//                     arguments: [0, false, PreloadPageController(), "noti${list.id}", null, true]);
//               });
//             }
//           }
//         }
//       } on Exception catch (e) {
//         if (kDebugMode) {
//           print(e.toString());
//         }
//       }
//     }
//   }
//
// }