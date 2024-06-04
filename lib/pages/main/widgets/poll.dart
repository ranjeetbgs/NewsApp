

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:incite/api_controller/app_provider.dart';
import 'package:incite/pages/main/widgets/share.dart';
import 'package:incite/utils/image_util.dart';
import 'package:incite/widgets/custom_toast.dart';
import 'package:incite/widgets/tap.dart';
import 'package:provider/provider.dart';
import '../../../api_controller/user_controller.dart';
import '../../../model/blog.dart';
import 'package:http/http.dart' as http;
import '../../../urls/url.dart';
import '../../../utils/color_util.dart';
import '../../../utils/theme_util.dart';

class BlogPoll extends StatefulWidget {
  const BlogPoll({super.key,this.model,required this.pollKey,required this.onChanged});
 final Blog? model;
 final GlobalKey<State<StatefulWidget>> pollKey;
 final ValueChanged onChanged;

  @override
  State<BlogPoll> createState() => _BlogPollState();
}

class _BlogPollState extends State<BlogPoll> {
  int? vote;
  bool isLoading = false;  
  bool isExpand=true;

  void _saveVoting(int option) async {
    try {
      final msg = jsonEncode({
        "option_id": option,
        'blog_id': widget.model!.id
      });
      print("msg $msg");
      final String url = '${Urls.baseUrl}add-vote';
      final client = http.Client();
      final response = await client.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          'api-token': currentUser.value.apiToken.toString(),
          },
        body: msg,
      );
      print("_saveVoting response $response");
      Map data = json.decode(response.body);
        
       if (data['success'] == true) {
        widget.model!.isVote = option;
        widget.model!.question!.options =[];
        data['data']['options'].forEach((e){
          widget.model!.question!.options!.add(PollOption.fromJSON(e));
        });
       }
         isLoading=false;
        setState(() { });

    } on SocketException {
        isLoading=false;
        setState(() { });
        showCustomToast(context, 'No internet Connection');
      }catch (e){
          isLoading=false;
        setState(() { });
        debugPrint(e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context,listen: false);
     var textStyle = const TextStyle(
       fontFamily: 'Roboto',
       fontSize: 16,
        color: Colors.white
     );
    return   Stack(
            children: [
           Padding(
             padding: EdgeInsets.symmetric(horizontal: 24, vertical: height10(context)-2),
             child: Column(
              mainAxisSize: MainAxisSize.min,
               children: [
                 GestureDetector(
              onTap: (){
                isExpand = !isExpand;
                widget.onChanged(isExpand);
                setState(() {  }); 
              },
               child: Container(
                  //  width: 125,
                  // constraints: const BoxConstraints(
                  //   minWidth: 0,
                  //   maxWidth: 240
                  // ),
                  width: size(context).width,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                      child: Row(
                          children: [
                            Spacer(),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 10),
                                  decoration:  BoxDecoration(
                                  color: dark(context) ? ColorUtil.blackGrey : ColorUtil.whiteGrey,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12)
                                  )
                                  ),
                                  child : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.poll,
                                      size: 14
                                      ),
                                       Text(allMessages.value.poll ?? 'Incite Poll',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 12,
                                        letterSpacing:0.3,
                                        color: dark(context) ? Colors.white : Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600
                                      )),
                                       RotatedBox(
                                         quarterTurns: isExpand==false ? 1 : -1,
                                         child: const Icon(Icons.chevron_left)
                                         ),
                                    ],
                                  ),
                                  )
                                ),
                                 Spacer(),
                          ],
                      ),
                    ),
                ),
                 AnimatedContainer(
                  duration: const Duration(microseconds: 300),
                  curve: Curves.easeInOut,
                  width: size(context).width,
                  decoration: BoxDecoration(
                  color: dark(context) ? ColorUtil.blackGrey 
                  : ColorUtil.whiteGrey,
                    borderRadius: BorderRadius.circular(20)),
                         padding: const EdgeInsets.all(15),
                         child:   Column(
                      children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(  widget.model!.question!.question ??  '',
                                  style: 
                                  textStyle.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: dark(context) ? ColorUtil.white : ColorUtil.textblack
                                  )),
                                ),
                                 isExpand && widget.model!.isVote != 0 ?  TapInk(
                            pad: 4,
                            splash: Colors.transparent,
                            onTap: () async{
                                Future.delayed(const Duration(milliseconds: 100));
                                await captureScreenshot(widget.pollKey,isPost : true).then((value) async{
                                Future.delayed(const Duration(milliseconds: 10));
                                final  data2 = await convertToXFile(value!);
                                Future.delayed(const Duration(milliseconds: 10));
                                shareImage(data2);
                                provider.addPollShare(widget.model!.id!.toInt());
                                });
                              setState(() {   });
                            },
                            child: SvgPicture.asset(SvgImg.share,
                            color:dark(context) ? Colors.white: Colors.black,
                            ),
                          ) : const SizedBox()
                              ],
                            ),
                            // vote == 1 || vote == 0 ? AnimateIcon(
                            //   child: Container(
                            //     key:  ValueKey(widget.model!.id),
                            //     width: size(context).width,
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(30)
                            //     ),
                            //     child:  Row(
                            //       children: [
                            //         Expanded(
                            //           flex: 89,
                            //           child: PollPercent(
                            //             poll: 1,
                            //             fraction: double.parse(widget.model!.yesPerc.toString()),
                            //             percText: '${widget.model!.yesPerc.toString()}%',
                            //           ),
                            //         ),
                            //         Expanded(
                            //           flex: 22,
                            //           child: PollPercent(
                            //               poll: 0,
                            //                fraction: double.parse(widget.model!.noPerc.toString()),
                            //               percText: '${widget.model!.noPerc.toString()}%',
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ) : 
                            Column(
                               key: const ValueKey('boat'),
                              children: [
                                  SizedBox(height: isExpand ? 12 :4),
                                  ...List.generate(isExpand ? widget.model!.question!.options!.length :0, (index) => 
                                   ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                     child: Stack(
                                       children: [
                                        InkWell(
                                            onTap: () {
                                              if (currentUser.value.id != null) {
                                              
                                             if (widget.model!.isVote != 0) {
                                                //  showCustomToast(context, 'Vote already registered');
                                             } else {
                                                if (currentUser.value.id == null) {
                                                   Navigator.pushNamed(context, '/LoginPage');
                                                } else {
                                                   isLoading = true;
                                                 setState(() {  });
                                                _saveVoting(widget.model!.question!.options![index].id!.toInt()); 
                                                }
                                             }
                                             }else{
                                               Navigator.pushNamed(context,'/LoginPage');
                                             }
                                            },
                                            child: Container(
                                            width: size(context).width,
                                            margin: const EdgeInsets.only(bottom: 12),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.only(
                                                topRight: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                topLeft: Radius.circular(8),
                                              ),
                                              border: Border.all(width: widget.model!.isVote == widget.model!.question!.options![index].id ? 1.25 :1 ,
                                              color: widget.model!.isVote == widget.model!.question!.options![index].id ?
                                              Theme.of(context).primaryColor : dark(context) ? Theme.of(context).disabledColor : ColorUtil.lightGrey)
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Text(widget.model!.question!.options![index].option.toString(),
                                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                fontSize: 16,
                                              )),
                                            ),
                                           ),
                                         ),
                                       if(widget.model!.isVote !=0)
                                         Positioned(
                                          bottom: 12,
                                          child: ClipRRect(
                                             borderRadius: BorderRadius.circular(10),
                                            child: Container(
                                              alignment: Alignment.centerLeft,
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              width: (size(context).width-80)*(widget.model!.question!.options![index].percentage!.toInt()/100),
                                              //  decoration: BoxDecoration(
                                              // borderRadius: BorderRadius.circular(10),
                                              color: widget.model!.isVote == widget.model!.question!.options![index].id ?
                                              Theme.of(context).primaryColor.withOpacity(0.3) :
                                               dark(context) ?Colors.white.withOpacity(0.3) : ColorUtil.textgrey.withOpacity(0.3) ,
                                            // ),
                                            child:const Text(''),
                                            ),
                                          )
                                          ),
                                          if(widget.model!.isVote != 0)
                                          Positioned(
                                            right: 8,
                                            top: 10,
                                            child: Text(
                                            "${widget.model!.question!.options![index].percentage.toStringAsFixed(2)}%",
                                            style:const TextStyle(
                                              fontFamily: 'Roboto',
                                              fontSize: 14,
                                              letterSpacing: 1,
                                              fontWeight: FontWeight.w600
                                            )))
                                       ],
                                     ),
                                   )
                                  )
                                  // Expanded(
                                  //   child: IconTextButton(
                                  //   text: 'Yes',
                                  //   padding: const EdgeInsets.symmetric(vertical: 7),
                                  //   style: textStyle,
                                  //   trailIcon: svgPicture,
                                  //   onTap: () {
                                  //     isLoading=true;
                                  //     vote = 1;
                                  //     setState(() {});
             
                                  //     Future.delayed(const Duration(seconds: 2),() {
                                  //      isLoading = false;
                                  //     setState(() {       });
                                  //     });
                                  //   }),
                                  // ),
                                  // const SizedBox(width: 15),
                                  // Expanded(
                                  //   child: IconTextButton(
                                  //   color: ColorUtil.textblack,
                                  //   text: 'No',
                                  //   trailIcon: svgPicture,
                                  //     padding: const EdgeInsets.symmetric(vertical: 7),
                                  //   style: textStyle,
                                  //   onTap: () {
                                  //    isLoading=true;
                                  //     vote = 0;
                                  //     setState(() {});
                                  //      Future.delayed(const Duration(seconds: 2),() {
                                  //         isLoading = false;
                                  //       setState(() {});
                                  //      });
                                       
                                  //   }),
                                  // )
                                  
                              ],
                            )
                      ],
                    ),
                     ),
               ],
             ),
           ),
              isLoading ? Positioned.fill(child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),  
                margin: EdgeInsets.symmetric(horizontal: 24,vertical: height10(context)-2),
               curve: Curves.easeIn,
                 decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isLoading ? 
                  dark(context) ? Colors.grey.shade700.withOpacity(0.85) :ColorUtil.whiteGrey.withOpacity(0.9) : Colors.transparent 
                ),
              )): const SizedBox() ,
             isLoading ? 
                 const Positioned.fill(
                  left: 24,
                  right: 24,
                  child: 
                  Center(
                    child: CircularProgressIndicator())
                  ) : const SizedBox() 
            ],
          );
  }
}

class PollPercent extends StatelessWidget {
  const PollPercent({
    super.key,
    this.fraction,
    this.poll,
    this.percText,
  });

  final int? poll;
  final String? percText;
  final double? fraction;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(microseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: poll == 0 ? ColorUtil.textblack : null,
        gradient: poll == 0 ? null : primaryGradient(context),
        borderRadius: poll == 0 ? const BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30)
        ) : const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30)
        )
      ),
      alignment: Alignment.center,
     padding: EdgeInsets.symmetric(vertical: 7,horizontal:fraction! < 20.0 ? 2 : 0),
      child: Text(percText ?? '89%',style: const TextStyle(
        fontFamily: 'Roboto',
        color: Colors.white,
        height: 0,
        fontSize:16,
      )));
  }
}