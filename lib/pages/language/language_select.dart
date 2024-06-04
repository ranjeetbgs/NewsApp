import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:incite/api_controller/repository.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/widgets/anim_util.dart';
import 'package:incite/widgets/custom_toast.dart';
import 'package:incite/widgets/dismiss_widget.dart';
import 'package:incite/widgets/loader.dart';
import 'package:provider/provider.dart';
import '../../api_controller/app_provider.dart';
import '../../splash_screen.dart';
import '../../widgets/back.dart';
import '../interests/widgets/radius_wrap.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key,this.isSetting=false});
  final bool isSetting;

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {

 int selected =-1;  
 bool isLoad=false;

  @override
  Widget build(BuildContext context) {
    var textStyle = const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 30,
            fontWeight: FontWeight.w600
          );
        var size  = MediaQuery.of(context).size;
    return DismissWidget(
      child: CustomLoader(
          isLoading: isLoad,
          child:Scaffold(
          appBar: AppBar(
          leadingWidth: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
            titleSpacing: 24,
            title:const Row(
              children: [
                 Backbut(),
                 Spacer()
              ],
            ),
          ),
          body: SizedBox(
              width: size.width,
              height: size.height,
              child: Stack(
                children: [
                 SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        Padding(
                        padding: const EdgeInsets.only(top: 30,bottom: 40),
                        child: AnimationFadeSlide(
                          duration: 500,
                          dx: 0.3,
                          child: Text(allMessages.value.chooseYourLanguage ?? 
                          'Choose your language',
                          textAlign: TextAlign.center,
                          style: textStyle),
                        ),
                        ),
                        SizedBox(
                        width: size.width,
                        child:  GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                        childAspectRatio: 3.5),
                                itemCount: allLanguages.length,
                                itemBuilder: (context1, index) {
                           return RadiusBox(
                                  index: index,
                                  isGradient: true,
                                  dur: 200,
                                   padding: const EdgeInsets.symmetric(vertical: 10),
                                    onTap:(){
                                      selected = index;
                                    languageCode.value = allLanguages[index];
                                    prefs!.setString('defalut_language',json.encode(languageCode.value.toJson()));
                                     isLoad = true;
                                     setState(() {});
                                      var provider = Provider.of<AppProvider>(context,listen:false);
                                    getLocalText(context).then((value) {
                                       if (value != null) {
                                       
                                      }
                                    });
                                   provider.getAnalyticData().whenComplete(() {
                                     provider.getCategory().then((value) {
                                       isLoad = false;
                                        setState(() {});
                                        prefs!.remove("isBookmark");
                                        Navigator.pushNamedAndRemoveUntil(context,'/MainPage',(route) => false,arguments: 0);
                                        showCustomToast(context,
                                        'Language Translated to ${languageCode.value.name}');
                                      });
                                     });
                                    },
                                    title: allLanguages[index].name.toString(),
                                    isSelected: allLanguages[index].id == languageCode.value.id);
                        
                              })
                        )
                        ],
                          ),
                      ),
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}