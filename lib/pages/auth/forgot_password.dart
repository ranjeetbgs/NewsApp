import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:incite/api_controller/user_controller.dart';

import '../../utils/color_util.dart';
import '../../widgets/button.dart';
import '../../widgets/loader.dart';
import '../../widgets/text_field.dart';
import 'otp.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key,this.isReset=false, this.isChange=false,this.title,});

  final bool isReset,isChange;
  final String? title;

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  late TextEditingController controller;
  
  bool isObscure=false,isObscure2=false,isObscure3=false;
  UserProvider userprovider = UserProvider();
  TextEditingController? controller2,controller3, controller4;
  
  bool isLoad=false;

  @override
  void initState() {
   controller= TextEditingController();
  if (widget.isReset == true) {
    controller2 = TextEditingController();
    controller3 = TextEditingController();
     controller4 = TextEditingController();
  }
    super.initState();
  }

  @override
  void dispose() {
   controller.dispose();
   if (widget.isReset == true) {
    controller2!.dispose();
    controller3!.dispose();
     controller4!.dispose();
  }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return CustomLoader(
      isLoading: isLoad,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Form(
            key: widget.isReset == true ?
              userprovider.resetFormKey
             : userprovider.forgetFormKey,
            child: Container(
              width: size.width,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child:   Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                     InkResponse(
                      onTap: () {
                        Navigator.pop(context);
                      },
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: ColorUtil.whiteGrey,
                          child: Icon(Icons.keyboard_arrow_left_rounded,
                          size: 28,
                          color: ColorUtil.textblack),
                        ),
                      ),
                 
                    ],
                  ),
                   const Spacer(),
                   
                  Image.asset('assets/images/app_icon.png',
                  width: 100,
                  height: 100,
                  ),
                  const SizedBox(height:60),
                    Text(allMessages.value.forgotPassword ?? 'Forgot password?',
                   style: const TextStyle(
                    fontSize: 30,
                    fontFamily: 'Roboto',
                    fontWeight:FontWeight.w600,
                  )),
                  const SizedBox(height:30),
                 widget.isReset==true ?const SizedBox(): TextFieldWidget(
                    hint: 'Email',
                    pos: 3,
                    controller: controller,
                     onValidate: (v) {
                    bool emailValid = RegExp(
                            r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                        .hasMatch(v!);
                        if (v.isEmpty) {
                          return allMessages.value.enterAValidEmail ?? 'Email is required';
                        } else if (!emailValid) {
                          return allMessages.value.enterAValidEmail ?? 'Enter a valid email';
                        }
                        return null;
                      },
                      onSaved: (v) {
                        setState(() {
                          userprovider.user.email = v;
                        });
                      },
                      onFieldSubmitted: (p0) {
                         if (widget.isReset == false) {
                        isLoad =true;
                        enterOtp.text='';
                        setState(() {  });
                        
                        userprovider.forgetPassword(context,
                        onChanged: (value) {
                            isLoad = false;
                            setState(() {  });
                        });
                       } 
                      },
                      textAction: TextInputAction.go,
                    prefix: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: SvgPicture.asset('assets/svg/mail.svg',
                      width: 20,
                      height: 16,
                      ),
                    ),
                   ),
                   
                 widget.isReset==false ? const SizedBox(): widget.isChange==true ?
                  const SizedBox() : TextLabel(
                  label:  allMessages.value.currentPassword ?? 'Current password',
                   child: TextFieldWidget(
                      controller: controller2 as TextEditingController,
                       hint: allMessages.value.entercurrentpassword ?? 'Current password',
                      suffix: InkResponse(
                        onTap: () {
                          isObscure = !isObscure;
                          setState(() {  });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 17),
                          child: Icon( isObscure==false ? Icons.visibility_off :Icons.visibility,
                          color: ColorUtil.textgrey2,
                          ),
                        ),
                      ),
                      isObscure: isObscure,
                      prefix: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 17),
                        child: SvgPicture.asset('assets/svg/password.svg',
                        width: 22,
                        height: 12,
                        ),
                      ),
                     ),
                 ),
                widget.isReset==false ?const SizedBox(): const SizedBox(height: 15),
                widget.isReset==false ? const SizedBox():  TextLabel(
                  label:allMessages.value.newpassword ?? 'New password',
                   child: TextFieldWidget(
                        controller: controller2 as TextEditingController,
                        hint:allMessages.value.newEnterPassword ?? 'New password',
                        suffix: InkResponse(
                        onTap: () {
                          isObscure2 = !isObscure2;
                          setState(() {  });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 17),
                          child: Icon( isObscure2==false ? Icons.visibility_off :Icons.visibility,
                          color: ColorUtil.textgrey2,
                          ),
                        ),
                      ),
                      isObscure: isObscure2,
                      prefix: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 17),
                        child: SvgPicture.asset('assets/svg/password.svg',
                        width: 22,
                        height: 12,
                        ),
                      ),
                    ),
                    ),
                  widget.isReset==false ?const SizedBox():  const SizedBox(height: 15),
                     widget.isReset==false ? const SizedBox():  TextLabel(
                  label:allMessages.value.confirmpassword ?? 'Confirm new password',
                   child: TextFieldWidget(
                                   controller: controller2 as TextEditingController,
                                   hint: allMessages.value.reEnterPassword ??  'Confirm new password',
                                   suffix: InkResponse(
                        onTap: () {
                          isObscure3 = !isObscure3;
                          setState(() {  });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 17),
                          child: Icon( isObscure3==false ? Icons.visibility_off :Icons.visibility,
                          color: ColorUtil.textgrey2,
                          ),
                        ),
                        ),
                        isObscure: isObscure3,
                        prefix: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 17),
                        child: SvgPicture.asset('assets/svg/password.svg',
                        width: 22,
                        height: 12,
                        ),
                        ),
                      ),
                     ),
                   const Spacer(flex: 3),
                    ElevateButton(
                    style:  const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500
                    ),
                    onTap:() {
                      if (widget.isReset == false) {
                        isLoad =true;
                        setState(() {  });
                        userprovider.forgetPassword(context,
                        onChanged: (value) {
                            isLoad = false;
                            setState(() {  });
                        });
                      } 
                    // Navigator.pushNamed(context,'/ResetPage');
                   },text:allMessages.value.submit ??'Submit'),
                   const Spacer()
                    ],),
              ),
          ),
          ),
    
      ),
    );
  }
}


class TextLabel extends StatelessWidget {
  const TextLabel({super.key,this.label='',required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label , style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
        )),
        const SizedBox(height: 8),
        child
      ],
    );
  }
}