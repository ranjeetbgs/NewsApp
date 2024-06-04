import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/widgets/anim_util.dart';
import 'package:incite/widgets/back.dart';
import 'package:incite/widgets/loader.dart';
import 'package:incite/widgets/text_field.dart';

import '../../utils/color_util.dart';
import '../../utils/theme_util.dart';
import '../../widgets/button.dart';
import '../../widgets/gradient.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late TextEditingController controller;
  late TextEditingController controller2;
  TextEditingController? ncontroller, pcontroller;

  bool isObscure = true;
  late UserProvider userProvider;
  bool isLoad = false;

  bool isSubmit = false;
  FocusNode focus = FocusNode();

  @override
  void initState() {
    userProvider = UserProvider();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return CustomLoader(
      isLoading: isLoad,
      child: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            //  leadingWidth: 80,
            toolbarHeight: 12,
            automaticallyImplyLeading: false,
          ),
          resizeToAvoidBottomInset: false,
          body: Container(
            width: size.width,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: IntrinsicHeight(
                    child: Form(
                      autovalidateMode: isSubmit
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      key: userProvider.signupFormKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          const AppIcon(isRectangle: true, width: 130),
                          const SizedBox(height: 10),
                          Text(allMessages.value.signUp ?? 'Sign up',
                              style: const TextStyle(
                                fontSize: 30,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 30),
                          TextFieldWidget(
                            hint: allMessages.value.name ?? 'Name',
                            onValidate: (v) {
                              if (v!.isEmpty) {
                                return allMessages.value.enterAValidUserName ??
                                    'Name is required';
                              } else if (v.length < 4) {
                                return allMessages.value.enterAValidUserName ??
                                    'Name must contain 4 characters';
                              }
                              return null;
                            },
                            onSaved: (v) {
                              setState(() {
                                userProvider.user.name = v;
                              });
                            },
                            pos: 1,
                            prefix: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 17),
                              child: SvgPicture.asset(
                                'assets/svg/name.svg',
                                width: 20,
                                height: 16,
                              ),
                            ),
                            textAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 15),
                          TextFieldWidget(
                            hint: allMessages.value.email ?? 'Email',
                            pos: 2,
                            onValidate: (v) {
                              bool emailValid = RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                  .hasMatch(v!);

                              if (v.isEmpty) {
                                return allMessages.value.enterAValidEmail ??
                                    'Email is required';
                              } else if (emailValid == false) {
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
                              padding: const EdgeInsets.symmetric(horizontal: 17),
                              child: SvgPicture.asset(
                                'assets/svg/mail.svg',
                                width: 20,
                                height: 16,
                              ),
                            ),
                            textAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 15),
                          TextFieldWidget(
                            pos: 3,
                            hint: allMessages.value.password ?? 'Password',
                            onValidate: (v) {
                              if (v!.isEmpty) {
                                return 'Password field is required';
                              } else if (v.length <= 7) {
                                // return allMessages.value.enterAValidPassword;
                                return allMessages.value.enterAValidPassword ??
                                    'Password must contain 8 characters';
                              }
                              return null;
                            },
                            onFieldSubmitted: (p0) {
                              focus.requestFocus();
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 17),
                                child: Icon(
                                  isObscure == false
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: ColorUtil.textgrey2,
                                ),
                              ),
                            ),
                            isObscure: isObscure,
                            prefix: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 17),
                              child: SvgPicture.asset(
                                'assets/svg/password.svg',
                                width: 22,
                                height: 12,
                              ),
                            ),
                            textAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 15),
                          TextFieldWidget(
                            hint: '${allMessages.value.phoneNumber} (optional)',
                            pos: 4,
                            lengthFormatter: [
                              LengthLimitingTextInputFormatter(11),
                              PhoneNumberInputFormatter()
                            ],
                            focusNode: focus,
                            length: 11,
                            textAction: TextInputAction.go,
                            keyboard: TextInputType.number,
                            onSaved: (v) {
                              setState(() {
                                userProvider.user.phone = v;
                              });
                            },
                            onFieldSubmitted: (p0) {
                              isLoad = true;
                              isSubmit = true;
                              setState(() {});
                              userProvider.signup(context, onChanged: (value) {
                                isLoad = false;
                                setState(() {});
                              });
                            },
                            prefix: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 17),
                              child: SvgPicture.asset(
                                'assets/svg/phone.svg',
                                width: 21,
                                height: 21,
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          ElevateButton(
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                              onTap: () {
                                isLoad = true;
                                isSubmit = true;
                                setState(() {});
                                userProvider.signup(context, onChanged: (value) {
                                  isLoad = false;
                                  setState(() {});
                                });
                              },
                              text: allMessages.value.signUp ?? 'Sign up'),
                          const SizedBox(height: 30),
                          const BottomText(),
                          const Spacer(flex: 6)
                        ],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Backbut()]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomText extends StatelessWidget {
  const BottomText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            text: allMessages.value.alreadyHaveAnAccount ??
                'Already have an account? ',
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
                Navigator.pushNamed(context, '/LoginPage');
              },
              child: GradientText(
                allMessages.value.signIn ?? 'Sign in',
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

class AppIcon extends StatelessWidget {
  const AppIcon({super.key, this.width, this.height, this.isRectangle = false});

  final double? height, width;
  final bool isRectangle;

  @override
  Widget build(BuildContext context) {
    return AnimationFadeSlide(
      dy: -0.6,
      dx: 0,
      child: allSettings.value.rectangualrAppLogo != '' && isRectangle == true
          ? CachedNetworkImage(
              imageUrl:
                  "${allSettings.value.baseImageUrl}/${allSettings.value.rectangualrAppLogo}",
              width: width ?? 100,
              height: height ?? 100,
            )
          : allSettings.value.appLogo != ''
              ? CachedNetworkImage(
                  imageUrl:
                      "${allSettings.value.baseImageUrl}/${allSettings.value.appLogo}",
                  width: width ?? 100,
                  height: height ?? 100,
                )
              : Image.asset(
                  'assets/images/app_icon.png',
                  width: width ?? 100,
                  height: height ?? 100,
                ),
    );
  }
}

class RectangleAppNoIcon extends StatelessWidget {
  const RectangleAppNoIcon({
    super.key,
    this.width,
    this.height,
  });

  final double? height, width;

  @override
  Widget build(BuildContext context) {
    return allSettings.value.rectangualrAppLogo != null
        ? CachedNetworkImage(
            imageUrl:
                "${allSettings.value.baseImageUrl}/${allSettings.value.rectangualrAppLogo}",
            width: width ?? 100,
            height: height ?? 100,
          )
        : Image.asset(
            'assets/images/logo.png',
            width: width ?? 100,
            height: height ?? 100,
          );
  }
}

class PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final sanitizedValue = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedValue = StringBuffer();
    for (var i = 0; i < sanitizedValue.length; i++) {
      if (i == 5) {
        formattedValue.write(' ');
      }
      formattedValue.write(sanitizedValue[i]);
    }

    return TextEditingValue(
      text: formattedValue.toString(),
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}

class RectangleAppIcon extends StatelessWidget {
  const RectangleAppIcon({
    super.key,
    this.width,
    this.height,
  });

  final double? height, width;

  @override
  Widget build(BuildContext context) {
    return AnimationFadeSlide(
      dy: -0.6,
      dx: 0,
      child: allSettings.value.rectangualrAppLogo != null
          ? CachedNetworkImage(
              imageUrl:
                  "${allSettings.value.baseImageUrl}/${allSettings.value.rectangualrAppLogo}",
              width: width ?? 100,
              height: height ?? 100,
            )
          : Image.asset(
              'assets/images/logo.png',
              width: width ?? 100,
              height: height ?? 100,
            ),
    );
  }
}
