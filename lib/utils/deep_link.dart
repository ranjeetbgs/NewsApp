import 'dart:convert';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:incite/api_controller/app_provider.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/main.dart';
import 'package:incite/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../model/blog.dart';
import '../urls/url.dart';

Future<String> createDynamicLink(Blog blog) async {
  String? url = 'https://www.newspepperapp.in/';
  final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://www.newspepperapp.in/',
      // ignore: prefer_interpolation_to_compose_strings
      link: Uri.parse(url),
      androidParameters: AndroidParameters(
        packageName: "${allSettings.value.bundleIdAndroid}",
        minimumVersion: 64,
      ),
      iosParameters: IOSParameters(
        bundleId: "${allSettings.value.bundleIdIos}",
        minimumVersion: '1.0.8',
        appStoreId: '123456789',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: blog.title,
          description: blog.description,
          imageUrl: blog.type == 'quote'
              ? Uri.tryParse(blog.imageUrl ?? '')
              : Uri.tryParse(blog.images![0])));

  var ref = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
  // FirebaseDynamicLinksPlatform.instanceFor(app: FirebaseApp)
  final Uri dynamicUrl = parameters.link;

  print('Dynamic Link: $dynamicUrl');

  return ref.shortUrl.toString();
}

void shareTextLink(String data) async {
  try {
    await Share.share(
      data,
      // text: allMessages.value.shareMessage,
    );
  } catch (e) {
    debugPrint('Error sharing : $e');
  }
}

Future initializeLink() async {
  final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

  if (initialLink != null) {
    final uriLink = initialLink.link;
    print('my link generated ${uriLink.data}');
  }
}

Future<void> initDynamicLinks(BuildContext context) async {
  final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  print('------------object---------------');
  Uri? uriLink;

  if (initialLink != null) {
    uriLink = initialLink.link;
    //print(uriLink);
    //print('my link generated ${uriLink.queryParameters['blog']}');
  }

  FirebaseDynamicLinks.instance.onLink.listen(
      (PendingDynamicLinkData dynamicLink) async {
    Uri? deepLink = dynamicLink.link;
    String? productId = '';
    // print(deepLink.host);
    // print(deepLink.path);
    // print(deepLink.query);`
    //  print(deepLink.query);
    //if(deepLink.data != null) {
    productId = deepLink.query.split('=').last;
    //  }

    print('object');
    //  if (uriLink != null) {

    //  }

    // print('URL');
    print('----------deeplink---------');
    print(productId);
    String? url;
    var provider = Provider.of<AppProvider>(context, listen: false);

    try {
      if (uriLink != null) {
        url = "${Urls.baseUrl}blog-detail/${uriLink.query.split('=').last}";
      } else {
        url = "${Urls.baseUrl}blog-detail/$productId";
      }

      print('--------url------------');
      print('--------${url}------------');

      var result = await http.get(
        Uri.parse(url),
      );
      Map datas = await json.decode(result.body);

      // print(datas);
      if (datas['success'] == true) {
        final list = Blog.fromJson(datas['data'], isNotification: true);
        // print(list.type);

        //if (list.type == 'quote') {
        ///setState(() {});

        prefs!.setBool('data', true);
        navkey.currentState!
            .pushNamed('/ReadBlog', arguments: [list, null, true]);
      }
    } on Exception catch (e) {
      print(e.toString());
    }

    // Navigate to the desired page based on the parameters
    // Navigator.pushNamed(
    //   context,
    //   '/BlogPage',
    //   arguments: {
    //      productId,
    //   },
    // );

    //print('Dynamic link received: $deepLink');
  }, onError: (e) async {
    print('Error handling dynamic link: $e');
  });

  // final PendingDynamicLinkData? data =
  //     await FirebaseDynamicLinks.instance.getInitialLink();
  // final Uri? deepLink = data?.link;

  // if (deepLink != null) {
  //   // Handle the dynamic link based on the deep link
  //   print('Initial dynamic link received: $deepLink');
  // }
  //}
}
