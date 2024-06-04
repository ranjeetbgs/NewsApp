import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:incite/api_controller/repository.dart';
import 'package:incite/main.dart';
import 'package:incite/model/home.dart';
import 'package:incite/pages/auth/login.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/utils/image_util.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/custom_toast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import '../model/blog.dart';
import '../model/cms.dart';
import '../model/lang.dart';
import '../model/messages.dart';
import '../model/settings.dart';
import '../model/user.dart';
import '../splash_screen.dart';
import '../urls/url.dart';
import 'app_provider.dart';
import 'repository.dart' as repository;
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart'
    as firebase_messaging;

ValueNotifier<Messages> allMessages = ValueNotifier(Messages());
ValueNotifier<SettingModel> allSettings = ValueNotifier(SettingModel());
ValueNotifier<Users> currentUser = ValueNotifier(Users());
ValueNotifier<List<Blog>> blogAds = ValueNotifier([]);
ValueNotifier<List<SocialMedia>> socialMedia = ValueNotifier([]);
ValueNotifier<double> defaultFontSize = ValueNotifier(16.0);
ValueNotifier<int> defaultAdsFrequency = ValueNotifier(3);
ValueNotifier<ScrollConfig> scrollConfig = ValueNotifier(ScrollConfig());
List<Language> allLanguages = [];
List<CmsModel> allCMS = [];
ValueNotifier<Language> languageCode =
    ValueNotifier(Language(id: 1,name: 'English', language: 'en'));
String? emailData;

class UserProvider extends ControllerMVC {
  final bool _isLoggedIn = false;
  Users user = Users();
  final bool _isLoading=false;
  bool get isLoggedIn => _isLoggedIn;
  GlobalKey<FormState>? loginFormKey,otpFormKey;
  GlobalKey<FormState>? updateFormKey;
  GlobalKey<FormState>? signupFormKey;
  GlobalKey<FormState>? forgetFormKey;
  GlobalKey<FormState>? resetFormKey; 
  firebase_messaging.FirebaseMessaging? _firebaseMessaging;
final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile'
    ],
  );
  
UserProvider(){
    loginFormKey = GlobalKey<FormState>();
    updateFormKey = GlobalKey<FormState>();
    signupFormKey = GlobalKey<FormState>();
    forgetFormKey = GlobalKey<FormState>();
    resetFormKey = GlobalKey<FormState>();
    otpFormKey  = GlobalKey<FormState>();
    
    _firebaseMessaging = firebase_messaging.FirebaseMessaging.instance;
    _firebaseMessaging?.getToken().then((String? _deviceToken) {
      user.deviceToken = getOnesignalUserId();
    }).catchError((e) {
      debugPrint('Notification not configured');
    });
}

 getLanguageFromServer(BuildContext context) async {
    
  // await checkUpdate(route: 'localisation-list?language_id=1',
  // etag: 'localisation-etag').then((value) async{
  //    if (value == true) {
      
  //    } else {
        await repository.getLocalText(context).then((value) {
        if (value != null) {
          allMessages.value = value;
        }
    //   }).catchError((e,stackTrace) {
    //     debugPrint(stackTrace.toString());
    //   }).whenComplete(() {});
    //  }
   });
  }


  getAllAvialbleLanguages(BuildContext context) async {

    // await checkUpdate(route: 'language-list',etag: 'lang-etag')
    // try {
    //  if (value == false) {
      await repository.getAllLanguages(context).then((value) {
      allLanguages = value;
    // } on. catch ((e) {
    // }).whenComplete(() {});
    //   }
    });
  }

  socialMediaList() async {

      await repository.socialMediaList().then((value) {
       if (value.isNotEmpty) {
          socialMedia.value = value;
          setState(() { });
       }
    });
  }

  Future<bool?> checkUpdate({String route = 'setting-list',String etag='setting-etag'}) async{
   if (prefs!.containsKey('local_data')) {
      prefs = await SharedPreferences.getInstance();
   try {
      final response = await dio.head('${Urls.baseUrl}$route');
    var eTag = response.headers.value('ETag'); 
    var prefTag = prefs!.containsKey(etag) ? prefs!.getString(etag) : '';

    if ((prefTag !=''|| prefTag !=null) && eTag != prefTag) {
       prefs!.setString(etag,eTag.toString());
      return false;
    } else if (prefTag == ''|| prefTag == null) {
      return false;
    }else{ 
      return true;
    }
   } catch ( e) {
     debugPrint(e.toString());
   }
   }else{
     return false;
   }
   
  }

Future<void> checkSettingUpdate(context) async {
  // Send a HEAD request to retrieve the etag header
    //  await checkUpdate().then((etag) async{
  //  try {
  //   if ( true) {
  //       getMessageAndSetting();
  //   } else {
     try {
  final conditionalResponse = await http.get(
  Uri.parse('${Urls.baseUrl}setting-list'),
   headers:{ 
    HttpHeaders.contentTypeHeader: 'application/json',
    "language-code" : languageCode.value.language ?? '',
   },
      );
   var res = json.decode(conditionalResponse.body);
  //  print(res.toString());

  if (res['success'] == true) {
    allSettings.value = SettingModel.fromJson(res['data']);
    prefs!.setBool('maintain',res['data']['enable_maintainance_mode'] == 1 ? true : false);
    prefs!.setString('setting',json.encode(res['data']));
   }else{
      if (res['message'] == "Unauthenticated") {
        // ignore: use_build_context_synchronously
        showCustomToast(navkey.currentState!.context, "User Account not found");
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
           Navigator.pushAndRemoveUntil(navkey.currentState!.context, MaterialPageRoute(builder:(context) => const LoginPage()), (route) => false);
        });
      }
   }
  }  on SocketException catch (e) {
     
  }  on TimeoutException catch (e) {
     showCustomToast(context, 'Connection Timeout');
  } on Exception catch (e) {

     allSettings.value.enableMaintainanceMode = '1';
     allSettings.value.maintainanceTitle  = 'Server Under Maintenance';
     allSettings.value.maintainanceShortText = 'Please contact the server administrator at ' 
		'contact@newspepperapp.in to inform them of the time this error occurred.';
     setState(() { });
    print(e.toString());
  }

   
  //  } catch ( e,stackTrace) {
  //   debugPrint(stackTrace.toString());
  //  }
    // } );
  // Check the response status code
}

Future googleLogin(BuildContext context,{required ValueChanged onChanged }) async {
       onChanged(true);
       var provider  = Provider.of<AppProvider>(context,listen: false); 
      try {
        GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
        repository.googleLogin(googleSignInAccount!,user,context).then((Users? value) async {
          if (value != null) {
              if (currentUser.value.isNewUser == true) {
                provider.addUserSession(isSocialSignup: true);
                showCustomToast(context, 'You are Signed-up successfully');
                Navigator.pushNamedAndRemoveUntil(context,'/SaveInterests',(route) => false,arguments: false);
              } else {
                provider.addUserSession(isSocialSignup: false);
                 showCustomToast(context, 'You are logged-in successfully');
                provider.getCategory().whenComplete(() {
                    onChanged(false);
                    Navigator.pushNamedAndRemoveUntil(context,'/MainPage',(route) => false,arguments: 1);
                  });
              }
          }
        }).catchError((e) {
            onChanged(false);
        }).whenComplete(() {
      });
      } catch (e) {
        onChanged(false);
      }
  
  }
  
  Future<void> signin(BuildContext context,{required ValueChanged onChanged}) async {
    // if (user.password != "") {
        if (loginFormKey!.currentState!.validate()) {
          loginFormKey!.currentState!.save();
          repository.signin(user,context).then((value) async {
            var provider = Provider.of<AppProvider>(context, listen: false);
            // await provider.getLatestBlog();
            currentUser.value.loginFrom = 'email';
            setState(() { });
            if (value != null) {
              provider.addUserSession(isSignin: true);
               showCustomToast(context, 'You are logged in successfully');
               provider.getCategory().whenComplete(() {
                 onChanged(false);
                 Navigator.pushNamedAndRemoveUntil(context,
                 '/MainPage',(route) => false,arguments: 1);
               });
            } else {
              onChanged(false);
            }
          }).catchError((e) {
            onChanged(false);
            showCustomToast(context, e.toString());
          }).whenComplete(() {
          });
        } else {
            onChanged(false);
        }
    
  }


  void appleLogin(BuildContext context,{List<Scope> scopes = const [Scope.email, Scope.fullName],ValueChanged? onChanged}) async {
   
     onChanged!(true);
      try {
        // 1. perform the sign-in request
        final result = await TheAppleSignIn.performRequests(
            [AppleIdRequest(requestedScopes: scopes)]);
        // 2. check the result
        switch (result.status) {
          case AuthorizationStatus.authorized:
            final appleIdCredential = result.credential;
            final oAuthProvider = OAuthProvider('apple.com');
            /*   final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken),
            accessToken:
                String.fromCharCodes(appleIdCredential.authorizationCode),
          );*/

            Map<String, dynamic> resultData = {
              "name": (appleIdCredential?.fullName?.givenName ?? "") +
                  (appleIdCredential?.fullName?.familyName ?? ""),
              "email": appleIdCredential?.email,
              "image": "",
              "apple_token": appleIdCredential?.user,
            };

            repository.appleLogin(resultData,context).then((value) async {
              var provider = Provider.of<AppProvider>(context, listen: false);
               if (value != null) {
              if (currentUser.value.isNewUser == true) {
                provider.addUserSession(isSocialSignup: true);
                showCustomToast(context, 'You are Signed-up successfully');
                Navigator.pushNamedAndRemoveUntil(context,'/SaveInterests',(route) => false,arguments: false);
              } else {
                provider.addUserSession(isSocialSignup: false);
                 showCustomToast(context, 'You are logged-in successfully');
                provider.getCategory().whenComplete(() {
                    onChanged(false);
                    Navigator.pushNamedAndRemoveUntil(context,'/MainPage',(route) => false,arguments: 1);
                  });
              }
          }
            }).catchError((e) {
              onChanged(false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text(allMessages.value.emailNotExist.toString()),
              ));
            }).whenComplete(() {
             
            });
            break;
          case AuthorizationStatus.error:
             onChanged(false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(result.error.toString()),
            ));
            break;
 
          case AuthorizationStatus.cancelled:
          onChanged(false);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Sign in aborted by user'),
            ));
            break;
          default:
            onChanged(false);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Something went wrong'),
            ));
            break;
        }
      } catch (e) {
           onChanged(false);
        // BotToast.showCustomText(toastBuilder: (void Function() cancelFunc) {
        //   return Container(height: 10,width: double.infinity,color: Colors.red,);
        // });
      }
    
  }

  Future adBlogs() async {
    repository.adView().then((value) {
      if (value.isNotEmpty) {
        blogAds.value = value;
        print(blogAds);
        setState(() { });
      } 
    }).catchError((e){
       
    });
  }
   
  Future<void> signup(BuildContext context,{ required ValueChanged onChanged }) async {
    if (signupFormKey!.currentState!.validate()) {
        signupFormKey!.currentState!.save();
        repository.register(user,context).then((value) {
         var provider = Provider.of<AppProvider>(context,listen: false);
          if (value != null && value.apiToken != null) {
            provider.clearLists();
            provider.addUserSession(isSignup: true);
            showCustomToast(context, 'Signup successfully done',isSuccess: true,islogo: false);
            Navigator.pushNamedAndRemoveUntil(context,'/SaveInterests',(route) => false,arguments: false);
          } else {  
            onChanged(false);
            }
          }).catchError((e) {
              onChanged(false);
              showCustomToast(context,allMessages.value.emailNotExist.toString());
        }).whenComplete(() {
            onChanged(false);
        });
      }else{
         onChanged(false);
      }
  }


  void forgetPassword(BuildContext context,{required ValueChanged onChanged}) async {
    
      try {
  if (forgetFormKey!.currentState!.validate()) {
    forgetFormKey!.currentState!.save();
    repository.forgetPassword(user, context).then((value) async {
      if (value==true) {
         onChanged(false);
        showCustomToast(context, "OTP sent to your email address",);
        Navigator.pushNamed(context, '/OTP',arguments: user.email); 
      } else {
        // print("else ");
        onChanged(false);
      }
    }).whenComplete(() {
       onChanged(false);
    });
     }
   }on SocketException{
       onChanged(false);
    } on Exception catch (e) {
       onChanged(false);
      debugPrint(e.toString());
    }
  
  }

   getCMS(BuildContext context) async {
    await checkUpdate(route: 'cms-list',etag: 'cms-etag').then((value) async{
    // if (value == false) {
      await repository.getCMS().then((value) {
         allCMS = value;
     }).catchError((e) {
       debugPrint(e);
     }).whenComplete(() {});
    // } 
   });
  }

  Future resetPass(BuildContext context, String email,{required  ValueChanged onChanged }) async {
   
      if (resetFormKey!.currentState!.validate()) {
        resetFormKey!.currentState!.save();
        repository.resetPassword(user,context, email).then((value) async {
          if (value != null && value == true) {
            onChanged(false);
            showCustomToast( context, "Your password reset successfully",);
            Navigator.pushNamedAndRemoveUntil(context,'/LoginPage',(route) => false);
          } else {
                 onChanged(false);
                showCustomToast(context, "Something went wrong",);
          }
        }).whenComplete(() {
           onChanged(false);
        });
      }
    
  }

  

  void profile(BuildContext context,{required ValueChanged onChanged}) async {
      if (updateFormKey!.currentState!.validate()) {
        updateFormKey!.currentState!.save();
        onChanged(true);
        repository.update(user, context).then((value) {
          if (value != null && value.apiToken != null) {
            onChanged(false);
             showCustomToast(context,allMessages.value.profileUpdatedSuccessfully ?? 'Profile updated successfully');
             Navigator.pop(context);
          }
        }).catchError((e) {
          onChanged(false);
          showCustomToast(context,'Something went wrong!!');
        }).whenComplete(() {
          onChanged(false);
        });
      }
  }

  void updateLanguage(BuildContext context) async {
      repository.updateLanguage().then((value) {
        if (value != null && value.apiToken != null) {
        
          showCustomToast(context,allMessages.value.profileUpdated.toString());
        }
      }).catchError((e) {
        debugPrint(e);
      }).whenComplete(() {});
    }

  void changePassword(BuildContext context,{
      required String conPass,
      required String newPass,
      required String oldPass,
      required ValueChanged onChanged}) async {
      
      repository.changePassword(context,
              oldPass: oldPass, newPass: newPass, conPass: conPass)
          .then((value) {
              onChanged(false);
            if (value == true && oldPass.isNotEmpty) {
                showCustomToast(context,allMessages.value.changePasswordSuccess ?? 'Password changed successfully');
                Navigator.pop(context);
            }else if (oldPass.isEmpty) {
                   showCustomToast(context,'Old Password is Empty');
              } else if (newPass != conPass) {
               showCustomToast(context,allMessages.value.passwordAndConfirmPasswordShouldBeSame ?? 'New Password and confirm passowrd should be same.');
            } else if (newPass == conPass && conPass == oldPass && newPass == oldPass) {
               showCustomToast(context,allMessages.value.newPasswordOldPasswordNotSame ??'New password can\'t be same as the old password.');
            }  else {
             showCustomToast(context,allMessages.value.oldPasswordError ?? 'Old Password is incorrect');

            }
          }).catchError((e) {
             onChanged(false);
             showCustomToast(context,'Something went wrong!!');
        }).whenComplete(() {
         onChanged(false);
      });
    
  }
  

void logout(BuildContext context)async{
  var provider = Provider.of<AppProvider>(context,listen: false);
  showCustomDialog(context: context,title:allMessages.value.signOut  ??  'Sign Out',
    text:  allMessages.value.doYouWantSigOut  ?? 'Do you want to sign out ?',
    isTwoButton:true,
    onTap: () async {
         provider.clearLists();
        provider.logoutUserSession();
        provider.getAnalyticData();
        prefs!.remove('current_user');
        prefs!.remove('bookmarks');
        prefs!.remove('isBookmark');
        
        _googleSignIn.signOut();
        currentUser.value = Users();
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.pushNamedAndRemoveUntil(context,'/LoginPage',(route) => false);
    }
  );
}
}

  showCustomDialog(
      {BuildContext? context,
      String? title,
      String? text,
      VoidCallback? onTap,dismissible = true,isTwoButton = false}) async {
    await showDialog(
      context: context!,
      barrierDismissible: dismissible,
      builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
          borderRadius:BorderRadius.circular(16)
          ),
          
          title: Row(
            children: [
              SvgPicture.asset(SvgImg.logout,color: Theme.of(context).disabledColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title.toString(),
                  style: Theme.of(context).textTheme.bodyLarge?.merge(
                        TextStyle(
                            color: isBlack(Theme.of(context).primaryColor) && dark(context) ? Colors.white  : Theme.of(context).primaryColor,
                            fontFamily: 'Roboto',
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600),
                      ),
                ),
              ),
            ],
          ),
          content: Text(text.toString(),
           textAlign: TextAlign.center,
          style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500)),
          actions: <Widget>[
           isTwoButton == false ? const SizedBox() :  TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text( allMessages.value.no ?? 'No',style: const TextStyle(
                          color: ColorUtil.textgrey,
                          fontFamily: 'Roboto',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500)),
            ),
            TextButton(
              onPressed: onTap,
              child: Text(isTwoButton == false  ? 'Ok' : allMessages.value.yes ?? 'Yes'),
            ),
          ],
        
      ),
    );
  }