
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/pages/auth/signup.dart';
import 'package:incite/widgets/loader.dart';

import '../../utils/color_util.dart';
import '../../widgets/button.dart';
import '../../widgets/text_field.dart';

class ResetPassword extends StatefulWidget {

  const ResetPassword({super.key,this.isChange=false,this.mail=''});
   final bool isChange;
   final String mail;


  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  late TextEditingController controller;
  
  bool isObscure=true,isObscure2=true,isObscure3=true;
  
  TextEditingController? controller2,controller3, controller4;
  UserProvider userProvider = UserProvider();
  
  bool isLoad=false;

  @override
  void initState() {
    controller2 = TextEditingController();
    controller3 = TextEditingController();
     controller4 = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    controller2!.dispose();
    controller3!.dispose();
     controller4!.dispose();
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
          child: SingleChildScrollView(
              child:Container(
            width: size.width,
            height: size.height-kToolbarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child:   Form(
              key: userProvider.resetFormKey,
              child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                       widget.isChange ? const SizedBox() : InkResponse(
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
                       if(widget.isChange == true)
                       const AppIcon(width: 100,height: 100),
                       const SizedBox(height:30),
                      Text( widget.isChange ? allMessages.value.resetPassword ?? 'Reset password' : allMessages.value.changePassword ??  'Change password',
                       style: const TextStyle(
                        fontSize: 30,
                        fontFamily: 'Roboto',
                        fontWeight:FontWeight.w600,
                      )),
                      const SizedBox(height:60),
                    
                     widget.isChange ? const SizedBox() :TextLabel(
                      label: allMessages.value.currentPassword ?? 'Current password',
                       child: TextFieldWidget(
                        pos: 2,
                          controller: controller2 as TextEditingController,
                           hint: allMessages.value.currentPassword ?? 'Current password',
                           onSaved: (p0) {
                             setState(() {
                              controller2!.text = p0.toString();
                             });
                           },
                           onValidate: (p0) {
                               if (p0!.isEmpty) {
                                  return allMessages.value.entercurrentpassword ??  'Enter current password';
                               }
                               return null;
                           },
                          suffix: InkResponse(
                            onTap: () {
                              isObscure = !isObscure;
                              setState(() {  });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 17),
                              child: Icon( isObscure==true ? Icons.visibility :Icons.visibility_off,
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
                   const SizedBox(height: 15),
                    TextLabel(
                      label: allMessages.value.newpassword ?? 'New password',
                       child: TextFieldWidget(
                        pos:3,
                          controller: controller3 as TextEditingController,
                          hint: allMessages.value.newpassword ?? 'New password',
                          onValidate: (p0) {
                             if (p0!.isEmpty) {
                                  return  allMessages.value.newEnterPassword ?? 'Enter new password';
                            } 
                            return null;
                           },
                           onSaved: (p0) {
                             setState(() {
                              controller3!.text = p0.toString();
                               userProvider.user.password = p0;
                             });
                           },
                          suffix: InkResponse(
                            onTap: () {
                              isObscure2 = !isObscure2;
                              setState(() {  });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 17),
                              child: Icon( isObscure2==true ? Icons.visibility :Icons.visibility_off,
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
                       SizedBox(height: widget.isChange ? 30 :15),
                         TextLabel(
                      label: allMessages.value.confirmpassword ?? 'Confirm new password',
                       child: TextFieldWidget(
                              pos: 4,
                            controller: controller4 as TextEditingController,
                            hint:  allMessages.value.confirmpassword ??'Confirm new password',
                             onValidate: (p0) {
                             if (p0!.isEmpty) {
                                  return allMessages.value.reEnterPassword ?? 'Enter confirem new password';
                            } 
                            return null;
                           },
                           onSaved: (p0) {
                             setState(() {
                               controller4!.text = p0.toString();
                               userProvider.user.cpassword = p0;
                             });
                           },
                            suffix: InkResponse(
                            onTap: () {
                              isObscure3 = !isObscure3;
                              setState(() {  });
                            },
                            
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 17),
                              child: Icon( isObscure3==true ? Icons.visibility :Icons.visibility_off,
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
                          if (widget.isChange == true) {
                            setState(() { isLoad = true;});
                              userProvider.resetPass(context, userProvider.user.email.toString(),onChanged: (value) {
                              setState(() { isLoad = false;});
                              });
                          } else {
                              setState(() { isLoad = true;});
                              userProvider.changePassword(context,conPass: controller4!.text,
                              newPass: controller3!.text, oldPass: controller2!.text,onChanged: (value) {
                                setState(() { isLoad = false;});
                              });
                          }
                       },text:allMessages.value.submit ??'Submit'),
                       const Spacer(flex: 3)
                        ],),
            ),
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