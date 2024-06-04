import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/widgets/custom_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/news.dart';
import '../splash_screen.dart';
import '../urls/url.dart';

Dio dio = Dio();
 List<ENews> eNews = [];
 List<LiveNews> liveNews = [];

Future<bool?> checkUpdate({String route = 'epaper-list',String etag='enews-tag',bool headCall=true}) async{
    prefs = await SharedPreferences.getInstance();
    if (headCall == true) {
  final response = await dio.head('${Urls.baseUrl}$route',
   options:Options(
      headers: currentUser.value.id != null ?{
        "api-token" : currentUser.value.apiToken
      }: {
        
       }
   )
  );
  var eTag = response.headers.value('ETag'); 
  var prefTag = prefs!.containsKey(etag) ? prefs!.getString(etag) : '';

  if ((prefTag !=''|| prefTag !=null) && eTag != prefTag) {
     prefs!.setString(etag,eTag.toString());
    //  print('new update');
    return false;
  } else if (prefTag == ''|| prefTag == null) {
    return false;
  }else{ 
    return true;
  }
}else{
  return false;
}
  }


Future<List<ENews>> getENews(BuildContext context) async {
     
  try {
     await checkUpdate().then((value) async{
      if (value == true) {
          eNews = [];
       json.decode(prefs!.get('enews').toString())['data'].forEach((e){
          eNews.add(ENews.fromJson(e));
       });
       return eNews;
    } else {
      final String url = '${Urls.baseUrl}epaper-list';
    final client = http.Client();
    final response = await client.get(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    if (response.statusCode == 200) {
      eNews = [];
      json.decode(response.body)['data'].forEach((e) {
        eNews.add(ENews.fromJson(e));
      });
      prefs!.setString('enews', response.body);
      return eNews;
    }
    }
   });
  } on SocketException {
      showCustomToast(context, allMessages.value.noInternetConnection ?? '');
  }
  return [];
}

Future<List<LiveNews>> getliveNews() async {
  
  try {
     await checkUpdate(route: 'live-news-list',etag: 'live-news-tag').then((value) async{
      if (value == true) {
        liveNews = [];
       if (prefs!.containsKey('livenews')) {
          json.decode(prefs!.get('livenews').toString())['data'].forEach((e){
          liveNews.add(LiveNews.fromJson(e));
       });
       }
       return liveNews;
    } else {
    final String url = '${Urls.baseUrl}live-news-list';
    final client = http.Client();
    final response = await client.get(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    if (response.statusCode == 200) {
      liveNews = [];
      var decode = json.decode(response.body);
      debugPrint(decode.toString());
      decode['data'].forEach((e) {
        liveNews.add(LiveNews.fromJson(e));
      });
      // debugPrint(liveNews[0].toString());
       prefs!.setString('livenews', response.body);
       
      return liveNews;
    }
    }
     });
  } on SocketException {
     return [];
  }  catch(e) {
      debugPrint(e.toString());
  }
  return [];
}
