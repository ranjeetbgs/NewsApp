import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:incite/pages/auth/signup.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/widgets/anim_util.dart';
import 'package:incite/widgets/back.dart';
import 'package:incite/widgets/button.dart';
import 'package:incite/widgets/drawer.dart';
import 'package:incite/widgets/loader.dart';
import 'package:incite/widgets/text_field.dart';

import '../../api_controller/repository.dart';
import '../../api_controller/user_controller.dart';
import "package:http/http.dart" as http;
import '../../model/user.dart';
import '../../splash_screen.dart';
import '../../urls/url.dart';
import '../../utils/nav_util.dart';
import '../../utils/theme_util.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/tap.dart';
import '../main/widgets/fullscreen.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key,this.isDash=false});
  final bool isDash;

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  TextEditingController? ucontroller;
  TextEditingController? nconroller;
  TextEditingController? pcontroller;
  
  bool _isLoading=false;
  File? _image;
  final picker = ImagePicker();
   var userProvider = UserProvider();
   
     bool isload =false;
     
       bool isFound=false;

@override
  void initState() {
  ucontroller= TextEditingController(text: currentUser.value.name ?? '');
  nconroller=TextEditingController(text: currentUser.value.email ?? '');
  pcontroller=TextEditingController(text: currentUser.value.phone ?? '');
    super.initState();
  }


Future<Users?> getProfile() async {
  try {
  final String url = '${Urls.baseUrl}get-profile';
  final client = http.Client();
  final response = await client.get(
    Uri.parse(url),
    headers: {
      "api-token":currentUser.value.apiToken.toString(),
      HttpHeaders.contentTypeHeader: 'application/json',
    },
  );
   debugPrint(response.body);
  var decode = json.decode(response.body);
  if (decode['success'] == true) {
    setCurrentUser(decode);
    currentUser.value = Users.fromJSON(decode['data']);
    return currentUser.value;
  } else {
    showCustomToast(context,decode['message']);
  }
} on Exception catch (e,stackTrace) {
   debugPrint(stackTrace.toString());
}
  return null;
}

   Future getImage() async {
     
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          _isLoading = true;
        } else {}
      });
      var stream = http.ByteStream(_image!.openRead());
      stream.cast();
      var length = await _image!.length();
      var uri = Uri.parse("${Urls.baseUrl}update-profile");
      var request = http.MultipartRequest("POST", uri);
      request.fields["id"] = currentUser.value.id.toString();
      request.headers["api-token"] = currentUser.value.apiToken.toString();
      // request.fields["email"] = userProvider.user.email.toString();
      //  request.fields["phone"] = userProvider.user.id.toString();
      // ignore: unnecessary_new
      var multipartFile = http.MultipartFile('photo', stream, length,
          filename: _image!.path.split('/').last);
      request.files.add(multipartFile);
       
      await request.send().then((response) async {
        
        response.stream.transform(utf8.decoder).listen((value) async {
          print(value);
          getCurrentUser();
          await getProfile();
          setState(() {
            currentUser.value.isPageHome = false;
            _isLoading = false;
          });
        });
      }).catchError((e) {
        print(e);
      });
  }


  @override
  Widget build(BuildContext context) {
    return CustomLoader(
      isLoading: isload,
      child: Scaffold(
        body: SafeArea(
          child: Form(
            key: userProvider.updateFormKey,
            child: CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: 8)),
                const SliverAppBar(
                leadingWidth: 0,
                pinned: true,
                automaticallyImplyLeading: false,
                titleSpacing: 20,
                 title:  Row(
                  children: [
                    Backbut(),
                  ],
                 ),
                ),
                SliverToBoxAdapter(
                  child:  Column(
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.only(left: 24,right: 24),
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //          color: Colors.transparent, 
                        //       borderRadius: BorderRadius.circular(12)
                        //     ),
                        //     child:  AnimationFadeSlide(
                        //       dy: -0.5,
                        //       dx: 0,
                        //       child: Image.asset('assets/images/news.jpg')),
                        //   ),
                        // ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimationFadeScale(
                                child: Stack(
                                children: [
                                    Hero(
                                      tag: widget.isDash ? 'Dash' : 'Drawer',
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100),
                                          border: Border.all(width: 4,color: Colors.white)
                                        ),
                                        child:_isLoading == true ?
                                            const CircleAvatar(
                                              radius: 65,
                                              child:  Center(child: CircularProgressIndicator(),)) 
                                            :  ProfileWidget(
                                             radius: 65,
                                             size: 48,
                                            onTap:currentUser.value.photo == null || currentUser.value.photo == '' ?
                                             () {

                                             }: () {
                                               Navigator.push(context, PagingTransform(
                                                       slideUp: true,
                                                        widget: FullScreen(
                                                        image: currentUser.value.photo,   
                                                        isProfile: true,
                                                        index: 0,
                                                        title: '',
                                               )));
                                            },
                                           ),
                                         ),
                                    ),
                                      Positioned(
                                  bottom: 0,
                                  right: 12,
                                  child: TapInk(
                                    radius: 100,
                                    onTap: () async {
                                         await getImage();
                                   },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(5, 5),
                                            spreadRadius: 0,
                                            color: ColorUtil.shadowColor,
                                            blurRadius: 10
                                          )
                                        ]
                                      ),
                                      child: const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 15,
                                      child: Icon(Icons.edit,size: 18,color: ColorUtil.textblack),
                                      ),
                                    ),
                                  ))
                                  ],
                                 ),
                               ),
                               const SizedBox(height: 10),
                                Text(currentUser.value.name.toString(),
                                style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 20,
                                fontWeight: FontWeight.w600
                               ))
                            ],
                          ),
                        )
                        ])
                ),
                 const SliverToBoxAdapter(
                  child: SizedBox(height:40),
                 ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                         TextFieldWidget(
                            hint:allMessages.value.name ?? 'Name',
                            pos: 1,
                            controller: ucontroller,
                            textAction: TextInputAction.next,
                            onValidate: (v) {
                              if (v!.isEmpty) {
                                return 'Name is required';
                              }else  if (v.length < 4) {
                                  return allMessages.value.enterAValidUserName ?? 'Name must contain 4 characters';
                              }
                              return null;
                            },
                            onSaved: (v) {
                              setState(() {
                                userProvider.user.name = v;
                              });
                            },
                            prefix: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 17),
                              child: SvgPicture.asset('assets/svg/name.svg',
                              width: 20,
                              height: 16,
                              ),
                            ),
                           ),
                           const SizedBox(height:  15),
                           TextFieldWidget(
                            hint: allMessages.value.email ??'Email',
                            isRead: true,
                            pos: 2,
                            controller: nconroller,
                             textAction: TextInputAction.next,
                            prefix: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 17),
                              child: SvgPicture.asset('assets/svg/mail.svg',
                              width: 20,
                              height: 16,
                              ),
                            ),
                           ),
                            const SizedBox(height: 15 ),
                         TextFieldWidget(
                            hint:allMessages.value.phoneNumber ?? 'Mobile',
                            pos: 3,
                            keyboard: TextInputType.phone,
                            
                            textAction : TextInputAction.go,
                            onFieldSubmitted: (p0) {
                               userProvider.profile(context,
                               onChanged: (value) {
                                  isload = value;
                                  setState(() { });
                                });
                            },
                            onSaved: (v) {
                            setState(() {
                              userProvider.user.phone = v;
                            });
                          },
                          length: 11,
                          onValidate: (p0) {
                            if (p0!.length < 6 ||  p0.length > 11) {
                               isload = false;
                               setState(() {  });
                              return allMessages.value.enterAValidPhoneNumber;
                            } 
                            return null;
                          },
                            lengthFormatter: [
                              LengthLimitingTextInputFormatter(11),
                              PhoneNumberInputFormatter()
                            ],
                          // textAction: TextInputAction.next,
                            controller: pcontroller,
                            prefix: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 17),
                              child: SvgPicture.asset('assets/svg/phone.svg',
                              width: 21,
                              height: 21,
                              ),
                            ),
                           ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: size(context).height * 0.05),
                           ElevateButton(
                              style:  const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500
                              ),
                              onTap:() {
                                //  isload = true;
                                // setState(() { });
                                userProvider.profile(context,onChanged: (value) {
                                  isload = value;
                                  setState(() { });
                                });
                            },text:allMessages.value.updateProfile ?? 'Update Profile'),
                            SizedBox(height:currentUser.value.loginFrom != 'email' ? 0 : 15),
                            currentUser.value.loginFrom != 'email' ? const SizedBox() :  ElevateButton(
                              style:  const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500
                              ),
                              onTap:() {
                              Navigator.pushNamed(context, '/ResetPage',arguments: [false,currentUser.value.email]);
                            },text: allMessages.value.changePassword ??'Change Password'),
                            const SizedBox(height: 20),
                            TextButton(
                              style:TextButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,vertical: 12
                                )
                              ),
                            
                              onPressed:() {
                                 showCustomDialog(
                                context: context,
                                title: allMessages.value.deleteAccount ?? 'Delete Account',
                                text: allMessages.value.confirmDeleteAccount ?? 'Do you want to delete account ?',
                                isTwoButton: true,
                                onTap: () async{
                                  Navigator.pop(context);
                                 await deleteAccount();
                                }
                              );
                              },
                              child: Text( allMessages.value.deleteAccount ??'Delete Account',
                              style:const TextStyle(fontFamily: 'Roboto',
                              fontSize: 14, color: Colors.white)),
                            ),
                          const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }


  Future<void> deleteAccount() async {
  
  isload = true;
  setState(() {});
  try {
  // final msg = jsonEncode({"id": currentUser.value.id});
  final String url = '${Urls.baseUrl}delete-account';
  final client = http.Client();
  final response = await client.get(
    Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "api-token" : currentUser.value.apiToken.toString()
    },
    // body: msg,
  );
  Map data = json.decode(response.body);
  print(data.toString());

    if (data['success'] == true) {  
    await prefs!.remove('current_user');
    await prefs!.setBool("isUserLoggedIn", false);
    await Future.delayed(const Duration(milliseconds: 100));
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/LoginPage', (route) => false);
  } else {
    isload = false;
     setState(() {});
    showCustomToast(context, 'Something went wrong. Try again !!');
  }
} on SocketException{
     isload = false;
     setState(() {});
   showCustomToast(context, 'No Internet Connection');
}  on Exception catch (e) {
    isload = false;
     setState(() {});
}
  }
}