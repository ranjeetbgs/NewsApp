import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:incite/api_controller/app_provider.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/pages/auth/signup.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/button.dart';
import 'package:incite/widgets/gradient.dart';
import 'package:incite/widgets/loader.dart';
import 'package:incite/widgets/text_field.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import '../../api_controller/repository.dart';
import '../../splash_screen.dart';
import '../../utils/image_util.dart';

class LoginPage extends StatefulWidget {
  const LoginPage(
      {super.key,
      this.bottomTap,
      this.title = 'Sign in',
      this.buttonText = 'Sign in',
      this.bottomText1,
      this.bottomText2,
      this.buttonTap,
      this.isSignUp = false});

  final VoidCallback? bottomTap, buttonTap;
  final String? bottomText1, bottomText2, buttonText, title;
  final bool isSignUp;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isObscure = true;
  UserProvider userProvider = UserProvider();

  bool isLoad = false;
  UserProvider user = UserProvider();

  @override
  void initState() {
    if (!prefs!.containsKey('player_id')) {
      OneSignal.Notifications.addPermissionObserver((accepted) async {
        final String? osUserID = OneSignal.User.pushSubscription.id;

        if (osUserID != null) {
          await setOnesignalUserId(osUserID.toString());
          if (prefs!.containsKey('player_id')) {
            currentUser.value.deviceToken = osUserID.toString();
            setState(() {});
            updateToken(currentUser.value, getOnesignalUserId().toString());
          }
          debugPrint(currentUser.value.deviceToken);
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (prefs!.containsKey('data')) {
        isLoad = true;
        setState(() {});
        prefs!.remove('data');
      }
      var provide = Provider.of<AppProvider>(context, listen: false);
      provide.getCategory();
      provide.setAnalyticData();
      // user.checkSettingUpdate(context);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (prefs!.containsKey('data')) {
      isLoad = true;
      setState(() {});
      prefs!.remove('data');
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return ValueListenableBuilder(
        valueListenable: allSettings,
        builder: (context, value, child) {
          return CustomLoader(
            isLoading: isLoad,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                //  leadingWidth: 80,
                toolbarHeight: 12,
                automaticallyImplyLeading: false,
                systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarIconBrightness:
                        dark(context) ? Brightness.light : Brightness.dark,
                    statusBarColor: Colors.transparent),
                actions: const [SizedBox(width: 12)],
              ),
              resizeToAvoidBottomInset: widget.isSignUp,
              body: value.enableMaintainanceMode == '1'
                  ? WillPopScope(
                      onWillPop: () async {
                        showCustomDialog(
                            context: context,
                            title: allMessages.value.confirmExitTitle ??
                                "Exit Application",
                            text: allMessages.value.confirmExitApp ??
                                'Do you want to exit from app ?',
                            onTap: () {
                              var provider = Provider.of<AppProvider>(context,
                                  listen: false);
                              var end = DateTime.now();
                              provider.addAppTimeSpent(
                                  startTime: provider.appStartTime,
                                  endTime: end);
                              provider.getAnalyticData();
                              Future.delayed(const Duration(milliseconds: 300));
                              exit(0);
                            },
                            isTwoButton: true);
                        return false;
                      },
                      child: SizedBox(
                        width: size.width,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Image.asset(Img.logo,width: 100, height: 100),
                              Stack(children: [
                                Image.asset('assets/images/maintain.png',
                                    width: 200, height: 200),
                                Positioned(
                                    top: kToolbarHeight,
                                    right: 50,
                                    child: Image.asset(Img.logo,
                                        width: 30, height: 30))
                              ]),
                              Text(
                                  value.maintainanceTitle ??
                                      'Server Under Maintenance',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Text(value.maintainanceShortText.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    height: 1.4,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: size.width,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: userProvider.loginFormKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                widget.isSignUp == false
                                    ? const SizedBox()
                                    : InkResponse(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: const CircleAvatar(
                                          radius: 20,
                                          backgroundColor: ColorUtil.whiteGrey,
                                          child: Icon(
                                              Icons.keyboard_arrow_left_rounded,
                                              size: 28,
                                              color: ColorUtil.textblack),
                                        ),
                                      ),
                                widget.isSignUp == true
                                    ? const SizedBox()
                                    : InkWell(
                                        onTap: () {
                                          Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              '/MainPage',
                                              (route) => false);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              allMessages.value.skip ?? 'Skip',
                                              style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: dark(context)
                                                      ? ColorUtil.white
                                                      : ColorUtil.textgrey)),
                                        )),
                              ],
                            ),
                            const Spacer(),
                            const AppIcon(isRectangle: true, width: 130),
                            const SizedBox(height: 20),
                            Text(widget.title ?? 'Sign in',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w600,
                                )),
                            const SizedBox(height: 40),
                            TextFieldWidget(
                              hint: allMessages.value.email ?? 'Email',
                              pos: 2,
                              onValidate: (v) {
                                bool emailValid = RegExp(
                                        r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                                    .hasMatch(v!);
                                if (v.isEmpty) {
                                  return allMessages.value.enterAValidEmail ??
                                      'Email is required';
                                } else if (!emailValid) {
                                  return allMessages.value.enterAValidEmail ??
                                      'Enter a valid email';
                                }
                                return null;
                              },
                              onSaved: (v) {
                                setState(() {
                                  userProvider.user.email = v;
                                });
                              },
                              prefix: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 17),
                                child: SvgPicture.asset(
                                  'assets/svg/mail.svg',
                                  width: 20,
                                  height: 16,
                                ),
                              ),
                              textAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            TextFieldWidget(
                              hint: allMessages.value.password ?? 'Password',
                              pos: 3,
                              textAction: TextInputAction.go,
                              onValidate: (v) {
                                if (v!.isEmpty) {
                                  return 'Password field is required';
                                } else if (v.length <= 7) {
                                  // return allMessages.value.enterAValidPassword;
                                  return 'Wrong password';
                                }
                                return null;
                              },
                              onFieldSubmitted: (p0) {
                                isLoad = true;
                                setState(() {});
                                userProvider.signin(context,
                                    onChanged: (value) {
                                  isLoad = false;
                                  setState(() {});
                                });
                              },
                              onSaved: (v) {
                                setState(() {
                                  userProvider.user.password = v;
                                });
                              },
                              suffix: InkResponse(
                                onTap: () {
                                  isObscure = !isObscure;
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 17),
                                  child: Icon(
                                    isObscure == false
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: dark(context)
                                        ? ColorUtil.white
                                        : ColorUtil.textgrey2,
                                  ),
                                ),
                              ),
                              isObscure: isObscure,
                              prefix: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 17),
                                child: SvgPicture.asset(
                                  'assets/svg/password.svg',
                                  width: 22,
                                  height: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            widget.isSignUp == true
                                ? const SizedBox()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, '/ForgotPage');
                                          },
                                          child: Text(
                                              allMessages
                                                      .value.forgotPassword ??
                                                  'Forgot Password?',
                                              style: const TextStyle(
                                                  fontSize: 14)))
                                    ],
                                  ),
                            const Spacer(flex: 4),
                            ElevateButton(
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                                onTap: widget.bottomTap ??
                                    () {
                                      isLoad = true;
                                      setState(() {});
                                      userProvider.signin(context,
                                          onChanged: (value) {
                                        isLoad = false;
                                        setState(() {});
                                      });
                                    },
                                text: allMessages.value.signIn ?? 'Sign in'),
                            const SizedBox(height: 20),
                            Platform.isIOS == false
                                ? const SizedBox()
                                : ElevateButton(
                                    splash: ColorUtil.textgrey.withOpacity(0.4),
                                    leadIcon: SvgPicture.asset(
                                        'assets/svg/apple.svg',
                                        width: 20,
                                        height: 20,
                                        color: dark(context)
                                            ? Colors.white
                                            : Colors.black),
                                    style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                    color: dark(context)
                                        ? Theme.of(context).cardColor
                                        : ColorUtil.whiteGrey,
                                    onTap: () {
                                      userProvider.appleLogin(context,
                                          onChanged: (value) {
                                        isLoad = value;
                                        setState(() {});
                                      });
                                    },
                                    text: allMessages.value.appleSignIn ??
                                        'Sign in with Apple'),
                            Platform.isIOS == false
                                ? const SizedBox()
                                : widget.isSignUp == true
                                    ? const SizedBox()
                                    : const SizedBox(height: 20),
                            widget.isSignUp == true
                                ? const SizedBox()
                                : ElevateButton(
                                    splash: ColorUtil.textgrey.withOpacity(0.4),
                                    leadIcon: Image.asset(
                                      'assets/images/google.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                    style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                    color: dark(context)
                                        ? Theme.of(context).cardColor
                                        : ColorUtil.whiteGrey,
                                    onTap: () {
                                      userProvider.googleLogin(context,
                                          onChanged: (value) {
                                        isLoad = value;
                                        setState(() {});
                                      });
                                    },
                                    text: allMessages.value.googleSignIn ??
                                        'Sign in with Google'),
                            SizedBox(height: widget.isSignUp == true ? 30 : 40),
                            BottomText2(
                                widget: widget,
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/LoginPage');
                                  Navigator.pushNamed(context, '/SignUpPage');
                                }),
                            widget.isSignUp == true
                                ? const Spacer(flex: 6)
                                : const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        });
  }
}

class BottomText2 extends StatelessWidget {
  const BottomText2({
    super.key,
    this.onTap,
    required this.widget,
  });

  final LoginPage widget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            text: allMessages.value.newUser ?? 'New user? ',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: dark(context) ? ColorUtil.white : ColorUtil.textblack,
            ),
            children: [
          WidgetSpan(
              child: Container(
            margin: const EdgeInsets.only(left: 8),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/SignUpPage');
              },
              child: GradientText(
                allMessages.value.signUp ?? 'Sign Up',
                gradient: dark(context)
                    ? darkPrimaryGradient(context)
                    : primaryGradient(context),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
            ),
          ))
        ]));
  }
}
