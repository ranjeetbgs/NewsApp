import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:incite/api_controller/app_provider.dart';
import 'package:incite/pages/interests/widgets/radius_wrap.dart';
import 'package:incite/widgets/back.dart';
import 'package:incite/widgets/custom_toast.dart';
import 'package:incite/widgets/loader.dart';
import 'package:provider/provider.dart';
import '../../api_controller/user_controller.dart';
import "package:http/http.dart" as http;
import '../../urls/url.dart';
import '../../utils/rgbo_to_hex.dart';
import '../../widgets/anim_util.dart';
import '../../widgets/button.dart';

class SaveInterest extends StatefulWidget {
  const SaveInterest({super.key,this.isDrawer=false});
final bool isDrawer;

  @override
  State<SaveInterest> createState() => _SaveInterestState();
}

class _SaveInterestState extends State<SaveInterest> {

 List selected = [];
 
  bool load = false;

  @override
  void initState() {
    super.initState();
  }

 Future setCategory(AppProvider provider) async {
    
    if ( provider.selectedFeed.length < 3) {
      showCustomToast(context ,allMessages.value.minimum3Select ?? "Minimum 3 should be selected");
    } else {
    
      if (true) {

        final formMap = jsonEncode({
          "category_id": provider.selectedFeed
        });
        try {
          setState(() {
            load = true;
          });
          var url = "${Urls.baseUrl}add-feed";
          var result = await http.post(
            Uri.parse(url),
            headers: {
             HttpHeaders.contentTypeHeader: "application/json",
              "api-token" : currentUser.value.apiToken ?? '',
            },
            body: formMap,
          );
          print(formMap);

          Map data = json.decode(result.body);
          debugPrint(data.toString());
          if (result.statusCode == 200) {
            showCustomToast(context,data['message']);
            if (widget.isDrawer) {
                setState(() {
                  load = true;
                });
                  // ignore: use_build_context_synchronously
                  await provider.getCategory(headCall: false).then((value) {
                    setState(() {
                      load = false;
                    });
                Navigator.pushNamedAndRemoveUntil(context,'/MainPage',(route) => false,arguments: 0);
              });
            }
            if (!widget.isDrawer) {
              setState(() {
                load = true;
               currentUser.value.isNewUser = true;
              });
              await provider.getCategory().then((value) {
                setState(() {
                  load = false;
                });
                Navigator.pushNamedAndRemoveUntil(
                    context, '/MainPage', (route) => false,arguments: 1);
              });
              // });
            }
          }
          setState(() {
            load = false;
          });
        } catch (e) {
          debugPrint(e.toString());
          setState(() {
            load = false;
          });
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    
    return  CustomLoader(
      isLoading: load,
      child: Scaffold(
        body: Consumer<AppProvider>(
          builder: (context,value,child) {
            return LayoutBuilder(
              builder: (context,constraint) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraint.maxHeight),
                      child: IntrinsicHeight(
                        child:Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(    
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: kToolbarHeight),
                          widget.isDrawer ? const Row(
                          children: [
                            Backbut()
                          ],
                          ) : const SizedBox(),
                            SizedBox(height:  widget.isDrawer ? 20 : 0),
                            AnimationFadeSlide(
                            duration: 500,
                            child: Text( widget.isDrawer ? allMessages.value.editSaveInterests ??  'Your interests for better content & experience.' :
                             allMessages.value.saveYourInterestsForBetterContentExperience ?? 'Save your interests for better content & experience.',
                             style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize:widget.isDrawer ? 24 : 30,
                                        fontWeight: FontWeight.w600,  
                                      ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Wrap(
                            spacing: 10,
                            runSpacing: 16,
                            children: [
                            ...value.blog!.categories!.asMap().entries.map((e) => RadiusBox(
                            index: e.key,
                            color: hexToRgb(e.value.color.toString()),
                            isGradient: true,
                              onTap:(){
                                if (value.selectedFeed.contains(e.value.id as int)) {
                                  value.selectedFeed.remove(e.value.id as int);
                                } else {
                                  value.selectedFeed.add(e.value.id as int);
                                }
                                setState(() {});
                              },
                              title: e.value.name.toString(),
                              isSelected: value.selectedFeed.contains(e.value.id as int)))
                          ],),
                          const Spacer(),
                          ElevateButton(
                                style:  const TextStyle(  
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500
                                ),
                                onTap:() async{
                                 await setCategory(value);
                               },text:  widget.isDrawer  ? allMessages.value.editButtonInterests ??'Save Interests' : allMessages.value.saveInterests ?? 'Save Interests'),
                               const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
                );
              }
            );
          }
        )
      ),
    );
  }
}