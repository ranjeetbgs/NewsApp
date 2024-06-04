
// ignore_for_file: use_build_context_synchronously, body_might_complete_normally_catch_error

  import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/main.dart';
import 'package:incite/utils/shared_util.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/custom_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/blog.dart';
import '../model/cms.dart';
import '../model/lang.dart';
import '../model/messages.dart';
import '../model/user.dart';
import '../splash_screen.dart';
import '../urls/url.dart';
import 'package:http/http.dart' as http;
import '../utils/app_theme.dart';
import '../utils/http_util.dart';

 final dio = Dio();
 
Future<Users?> signin(Users user,BuildContext context) async {
    try {
    if (RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(user.email.toString())) {
    final msg = jsonEncode({
      "email": user.email, 
      "player_id" :user.deviceToken ,
      "password": user.password
    });
    final  url = Uri.parse('${Urls.baseUrl}login');
    final response = await http.post(
       url,
      body: msg,
      headers: {
        HttpHeaders.contentTypeHeader : 'application/json'
      }
    );
    var res =json.decode(response.body);

    if (res['success'] == true) {
      res['data']['login_from'] = 'email';
      setCurrentUser(res);
      currentUser.value = Users.fromJSON(res['data']);
      currentUser.value.isPageHome = true;
       
      currentUser.value.id =res['data']['id'].toString();
      if (currentUser.value.langCode != null) {
        for (var element in allLanguages) {
          if (element.language == currentUser.value.langCode) {
            languageCode.value = element;
          }
        }
      }
       showCustomToast(context,res['message']);
      return currentUser.value;
    } else {
      showCustomToast(context,res['message']);
      return null;
    }
  } else {
     return null;
  }
     
  } on SocketException {
     showCustomToast(context,'No Internet Connection');
  }catch (e) {
    debugPrint('API request failed: $e');
  }
    return null;
  }

  Future<Users?> register(Users user,BuildContext context) async {
  if (RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(user.email.toString())) {
    final msg = jsonEncode({
      "email": user.email,
      "name": user.name,
      "phone": user.phone ?? '',
      "password": user.password,
      "player_id": prefs!.getString('player_id')
    });
    final String url = '${Urls.baseUrl}signup';
    final response = await http.post(Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: msg,
      encoding: Encoding.getByName('utf-8')
    // ignore: data_might_complete_normally_catch_error
    ).catchError((e) {
      debugPrint("register error $e");
    });
    
    var res = json.decode(response.body);

    if (res['success'] == true) {
     
      setCurrentUser(res);
      currentUser.value = Users.fromJSON(res['data']);
      currentUser.value.isPageHome = true;
      currentUser.value.isNewUser = true;
      return currentUser.value;
    } else {
      showCustomToast(context,res["message"]);
    }
  } 
  return null;
}



Future<Users?> googleLogin( users,Users user,BuildContext context) async {
  final authentication = await users.authentication;
  // final firebaseMessaging = FirebaseMessaging.instance;
  // String token = firebaseMessaging.getToken().toString();
  try {
  final msg = jsonEncode({
    "email": users.email,
    "name": users.displayName,
    "image": users.photoUrl,
    "google_token": authentication.accessToken,
    "player_id": prefs!.getString('player_id'),
    "login_from": "google"
  });
  debugPrint("msg $msg");
  final String url = '${Urls.baseUrl}social-media-signup';
  final response = await http.post(
    Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: msg,
    encoding: Encoding.getByName('utf-8')
  );
  var decode = json.decode(response.body);
  if (decode['success'] == true) {
    debugPrint('----------- Api Token -------------');
     debugPrint(decode['data'].toString());
    setCurrentUser(decode);
    
    currentUser.value = Users.fromJSON(decode['data']);
    currentUser.value.isPageHome = true;
    // if (currentUser.value.langCode != null) {
    //   for (var element in allLanguages) {
    //     if (element.language == currentUser.value.langCode) {
    //       languageCode.value = element;
    //     }
    //   }
    // }
    return currentUser.value;
  } else{
   return null;
  }
} on SocketException{
  //  showCustomToast(context, 'No Internet Connection');
} on Exception catch (e) {
     debugPrint(e.toString());
}
  return null;
}


Future<bool?> resetPassword(Users user,BuildContext context ,String email) async {
  var userData = json.decode(emailData!)['data'];
 if (user.password != user.cpassword) {
    showCustomToast(context,allMessages.value.passwordAndConfirmPasswordShouldBeSame  ?? 'Password is not matching');
  } else {
    // debugPrint("userData.id ${userData.id}");
    final msg = jsonEncode({
      "id": userData['id'],
      "otp": userData['otp'],
      "email": email,
      "cpassword": user.cpassword,
      "password": user.password
    });
    //final String url =
    //'${GlobalConfiguration().getValue('api_base_url')}reset-password';
    final String url = '${Urls.baseUrl}reset-password';
    final client = InciteHttp().client;
    final response = await client.post(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: msg,
    );
    var res =json.decode(response.body);
    
    if(res['success'] == true) {
      return true;
    } else {
      showCustomToast(context ,json.decode(response.body)['message']);
        return null;
    }
  }
  return null;
}

Future<bool?> forgetPassword(Users user, BuildContext context) async {
  final msg = jsonEncode({"email": user.email});
  //final String url =
  //'${GlobalConfiguration().getValue('api_base_url')}forgot-password';
  final String url = '${Urls.baseUrl}forget-password';
  final client  = InciteHttp().client;
  final response = await client.post(
    Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: msg,
    encoding: Encoding.getByName('utf-8')
  );
    var res = jsonDecode(response.body);
    print(res);

  if (res['success'] == true) {
    emailData = response.body;
    return true;
  // ignore: duplicate_ignore
  } else {
    //  showToast(json.decode(response.data)['message']);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)
        ),
        backgroundColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.all(16),
        title:  Row(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 12,
            backgroundColor: Colors.red,
            child: Icon(Icons.close,
            color: Colors.white,
            size: 18)),
          const SizedBox(width: 8),Text(
          "Error ocurred!",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.merge(
                const TextStyle(
                    color: Colors.red,
                    fontFamily: 'Roboto',
                    fontSize: 19.0,
                    fontWeight: FontWeight.w600),
              ),
        )
       ]),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
              children: [
                    Text(
                       json.decode(response.body)['message'].toString(),
                        style:  TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: dark(context) ?Colors.grey.shade700 : Colors.grey.shade500)),
                  
                 const SizedBox(height: 12),
                Text(
                  ' ${user.email}.',
                  style: TextStyle(
                      fontSize: 14,
                      color: appThemeModel.value.isDarkModeEnabled.value
                          ? Colors.white
                          : Colors.black,
                      fontWeight:FontWeight.w500,
                      height: 1.4),
                )
              ],
            ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(allMessages.value.ok ?? 'Ok' ),
          ),
        ],
      ),
    );
  }
  return null;
}



Future<void> logout() async {
  currentUser.value = Users();

  SharedPreferences? prefs = GetIt.instance<SharedPreferencesUtils>().prefs;
  await prefs!.remove('current_user');
  prefs.setBool("isUserLoggedIn", false);
}

void setCurrentUser(jsonString) async {
  SharedPreferences? prefs = GetIt.instance<SharedPreferencesUtils>().prefs;
  if (jsonString['data'] != null) {
    prefs!.setBool("isUserLoggedIn", true);
    await prefs.setString(
        'current_user', json.encode(jsonString['data']));
    currentUser.value =Users.fromJSON(json.decode(prefs.get('current_user').toString()));

    debugPrint("Current User id ${currentUser.value.id}");
  }
}

Future<Users> getCurrentUser() async {
  SharedPreferencesUtils sharedPreferencesUtils =
      GetIt.instance<SharedPreferencesUtils>();
  //appThemeModel.value.
  if (currentUser.value.id == null &&
      sharedPreferencesUtils.prefs!.containsKey('current_user')) {
    currentUser.value = Users.fromJSON(json.decode(sharedPreferencesUtils.prefs!.get('current_user').toString()));
    currentUser.value.auth = true;
    currentUser.value.isNewUser = false;
  } else {
    currentUser.value.auth = false;
  }
  return currentUser.value;
}

setOnesignalUserId(String id){
  prefs!.setString('player_id',id);
}

String? getOnesignalUserId()  {
  
     if (prefs!.containsKey('player_id')) {
        final str = prefs!.getString('player_id');
        currentUser.value.deviceToken = str;
        return str;
     }
}


Future<Users?> appleLogin( Map<String, dynamic> appleData,BuildContext context) async {
  // final firebaseMessaging = FirebaseMessaging.instance;
  // String token = firebaseMessaging.getToken().toString();
  try {
    final msg = jsonEncode({
    "email": appleData["email"],
    "name": appleData["name"],
    "image": appleData["image"],
    "apple_token": appleData["apple_token"],
    "player_id": prefs!.getString('player_id'),
    "login_from": "apple"
  });
  debugPrint("msg $msg");
  final String url = '${Urls.baseUrl}social-media-signup';
  final response = await http.post(
    Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: msg,
  );
  var decode = json.decode(response.body);
  if (decode['success'] == true) {
     debugPrint(decode['data'].toString());
    setCurrentUser(decode);
    currentUser.value = Users.fromJSON(decode['data']);
    currentUser.value.isPageHome = true;
    return currentUser.value;
  } else{
   return null;
  }
} on SocketException{
    showCustomToast(context,allMessages.value.noInternetConnection ?? 'No Internet Connection');
} on Exception catch (e) {
     debugPrint(e.toString());
}
  return null;
}

Future<List<Blog>> adView() async {

  final String url = '${Urls.baseUrl}ads-list';

  try {
  final response = await http.get(
   Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    }
  );
  var decode = json.decode(response.body);
  
  if (decode['success'] == true) {
     List<Blog> blogAdList=[];
    decode['data'].forEach((element) { 
      blogAdList.add(Blog.fromJson(element,isAds: true));
    });
    return blogAdList;
  } 
} on Exception catch (e) {
   debugPrint(e.toString());
}
  return [];
}


Future getStatusAccount(BuildContext context) async {

  final String url = '${Urls.baseUrl}get-profile';

  try {
  final response = await http.get(
   Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      'api-token' : currentUser.value.apiToken.toString()
    },
  );
  var decode = json.decode(response.body);
  // print(decode.toString());
  
  if (decode['message'] == "Unauthenticated" ) {
     prefs!.remove('current_user');
    prefs!.remove('bookmarks');
    prefs!.remove('isBookmark');
    currentUser.value = Users();
     Navigator.pushNamedAndRemoveUntil(context,'/LoginPage',(route) => false);
       showCustomDialog(
        context: context,
        dismissible: false,
        title: "Account Deleted",
        text:  'User doesn\'t please contact us for more info',
        onTap: () async {
           Navigator.pop(navkey.currentState!.context);
        },
        isTwoButton: false
      );
    
  } 
} on Exception catch (e) {
    print(e.toString());
}
}

Future<Users?> update(Users user, BuildContext context) async {
  final msg = jsonEncode({
    "email": user.email,
    "name": user.name,
    "id": currentUser.value.id,
    "phone": user.phone,
    "password": user.password
  });

  final String url = '${Urls.baseUrl}update-profile';

  final response = await http.post(
   Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      'api-token' : currentUser.value.apiToken.toString()
    },
    body: msg,
  );
  var decode = json.decode(response.body);
  
  if (decode['success'] == true) {
    setCurrentUser(decode);
    currentUser.value = Users.fromJSON(decode['data']);
    return currentUser.value;
  } 
  return null;
}

Future<Users?> updateLanguage() async {
  final msg = jsonEncode({
    "lang-code": languageCode.value.language,
    "email": currentUser.value.email,
    "name": currentUser.value.name,
    "id": currentUser.value.id,
    "phone": currentUser.value.phone,
  });

  final client = http.Client();

  try {
  final String url = '${Urls.baseUrl}update-profile';
  final response = await client.post(
   Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: msg,
  );
  var decode = json.decode(response.body);
  if (decode['success'] == true) {
    setCurrentUser(response.body);
    currentUser.value = Users.fromJSON(decode['data']);
    return currentUser.value;
  } 
  return null;
} on Exception catch (e) {
  print('update profile');
  print(e);
} finally {

  client.close();
}
}

Future<bool> changePassword(BuildContext context,
    {required String conPass,
    required String newPass,
    required String oldPass
    }) async {

  try {
  final msg = jsonEncode({
    "old_password": oldPass,
    "password": newPass,
    "cpassword": conPass,
  });
  
  final String url = '${Urls.baseUrl}change-password';
  final response = await http.post(
   Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "api-token" : currentUser.value.apiToken.toString()
    },
    body: msg,
  );

 
  var decode = json.decode(response.body);
  // ignore: duplicate_ignore
  if (decode['success'] == true) {
     return true;
  } else{
    return false;
  }
}on SocketException{
   showCustomToast(context, allMessages.value.noInternetConnection ?? 'No internet connection');
}  on Exception catch (e) {
 
}
 return false;
}

Future<Messages?> getLocalText(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String url;
 var client = http.Client();
  try {
    url ="${Urls.baseUrl}localisation-list?language_id=${languageCode.value.id}";
  
  final response = await client.get(
    Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
  );

  var res= jsonDecode(response.body);
  if (res['success'] == true) {
    prefs.setString("local_data", json.encode(res['data']));
   allMessages.value = Messages.fromJson(res['data']);
  
    return Messages.fromJson(res['data']);
  }
}on SocketException{
   showCustomToast(context , allMessages.value.noInternetConnection ??  'No Internet Connection');
}  on Exception catch (e) {
  debugPrint(e.toString());
} finally {
  client.close();
}
  return null;

}

Future<List<Language>> getAllLanguages(BuildContext context) async {
  final String url = '${Urls.baseUrl}language-list';
  final client = http.Client();
  try {
    final response = await client.get(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    var res = jsonDecode(response.body);

    if (res['success'] == true) {
      List<Map<String, dynamic>> jsonList = [];
      allLanguages= [];
       res['data'].forEach((language) {
        allLanguages.add(Language.fromJson(language));
        jsonList.add(language);
      });
       prefs!.setString("languages",json.encode(jsonList));
       prefs!.setString("defalut_language", json.encode(languageCode.value.toJson()));
      return allLanguages;
    } else {
      showCustomToast(context,json.decode(res)['message']);
    }
  } catch (e) {
    showCustomToast(context,e.toString());
  } finally {   
     client.close();
  }
  return [];
}


Future<List<CmsModel>> getCMS() async {
  final client = http.Client();
  try {
    final String url = '${Urls.baseUrl}cms-list';
    final response = await InciteHttp().client.get(Uri.parse(url),
    );
    var decode = json.decode(response.body);
    if (decode['success'] == true) {
      allCMS = [];
      decode['data'].forEach((language) {
        allCMS.add(CmsModel.fromJson(language));
      });
        prefs!.remove('OffAds');
        prefs!.setString('OffAds',response.body);
      return allCMS;
    } else {
      // showToast('getCMS --->>>');
      // showToast(json.decode(response.body)['message']);
    }
  } on SocketException {
    if (prefs!.containsKey('OffAds')) {
      allCMS= [];
      final ads = prefs!.getString('OffAds').toString();
      json.decode(ads)['data'].forEach((language) {
        allCMS.add(CmsModel.fromJson(language));
      });
    } 
    return allCMS;
  } on Exception catch (e) {
      debugPrint(e.toString());
      
  } finally {
       client.close();
   }
  return [];
}


Future<Users?> updateToken(Users user,String str) async {
  try {
  final msg = jsonEncode({
    "player_id": str,
    "is_notification_enabled" : appThemeModel.value.isNotificationEnabled.value == true ?  1 : 0
  });

  print(currentUser.value.apiToken.toString());

  print(msg);
  final String url = '${Urls.baseUrl}update-token';
   var res =  await http.post( Uri.parse(url),
    headers: currentUser.value.id != null ? {
         HttpHeaders.contentTypeHeader: 'application/json',
         "api-token" : currentUser.value.apiToken.toString()
    } : {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: msg,
  );

   var response = json.decode(res.body);
   
    debugPrint(response.toString());
    if (response['success']== true && currentUser.value.id == null) {
      prefs!.setString('non-logged-in', str.toString());
    }
  } on SocketException {
  //  showCustomToast(context, 'No Internet Conne');
 } on Exception catch (e) {
    debugPrint(e.toString());
}
  return null;
}




Future<List<SocialMedia>> socialMediaList() async{
  try {

  
  final String url = '${Urls.baseUrl}social-media-list';
   var res =  await InciteHttp().client.get(Uri.parse(url),
    headers: currentUser.value.id != null ? {
         HttpHeaders.contentTypeHeader: 'application/json',
         "api-token" : currentUser.value.apiToken.toString()
    } : {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
  );
 
   var response = json.decode(res.body);
    if (response['success']== true ) {
      List<SocialMedia> social=[];
      response['data'].forEach((e){
        social.add(SocialMedia.fromJson(e));
      });

      return social;
    }else{
       return [];
    }
  } on SocketException {
  //  showCustomToast(context, 'No Internet Conne');
 } on Exception catch (e) {
    debugPrint(e.toString());
}
  return [];
}

Future<bool?> getNotification()async{
  try {

  final msg = jsonEncode({
    "player_id": currentUser.value.deviceToken,
  });
  
  final String url = '${Urls.baseUrl}get-notification-detail';
   var res =  await InciteHttp().client.post(Uri.parse(url),
    headers: currentUser.value.id != null ? {
         HttpHeaders.contentTypeHeader: 'application/json',
         "api-token" : currentUser.value.apiToken.toString()
    } : {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: msg,
  );
  //     print('---------------- Testing --------------------------');
  //  print(res.body.toString());
 
   var response = json.decode(res.body);
    // print(response['data']['is_notification_enabled']);
    if (response['success']== true ) {  
      appThemeModel.value.isNotificationEnabled.value =  response['data']['is_notification_enabled'] == 1 ? true : false;
      return  response['data']['is_notification_enabled'] == 1 ?  true : false;
    }
  } on SocketException {
  //  showCustomToast(context, 'No Internet Conne');
 } on Exception catch (e) {
    debugPrint(e.toString());
}
  return false;
}