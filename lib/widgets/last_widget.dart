import 'package:flutter/material.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/back.dart';

import '../api_controller/blog_controller.dart';


class LastNewsWidget extends StatefulWidget {
  const LastNewsWidget({Key? key,required this.onBack,this.keyword,this.isButton=true ,this.onTap}) : super(key: key);
  final VoidCallback? onTap;
  final String? keyword;
  final bool isButton;
  final VoidCallback onBack;

  @override
  State<LastNewsWidget> createState() => _LastNewsWidgetState();
}

class _LastNewsWidgetState extends State<LastNewsWidget> {
  @override
  Widget build(BuildContext context) {
    var themeDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size(context).width,
      height: MediaQuery.of(context).size.height,
      child: Material(
        color: Theme.of(context).cardColor,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: Stack(
              children: [
                SizedBox(
               width: size(context).width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: MediaQuery.of(context).size.width / 4.5,
                                height: MediaQuery.of(context).size.width / 4.5,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 3,
                                      color:
                                          themeDark ? Colors.white : Colors.black,
                                    ),
                                    shape: BoxShape.circle),
                                child: Icon(
                                  Icons.done,
                                  size: 40,
                                  color: Theme.of(context).primaryIconTheme.color,
                                ),
                              ),
                            );
                          }),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                    allMessages.value.great ?? 'Great',
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryIconTheme.color,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text.rich(
                        TextSpan(
                          children:[
                          TextSpan(
                           text:  allMessages.value.youHaveViewedAll ?? 'You have viewed all',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                          TextSpan(
                           text: " ${widget.keyword}",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              color: dark(context) ? Colors.white
                                :Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                        )
                      ),
                      widget.isButton ==false? const SizedBox()
                      :TweenAnimationBuilder<Offset>(
                          duration: const Duration(milliseconds: 100),
                          tween: Tween<Offset>(
                              begin: const Offset(0, -20),
                              end: const Offset(1, 20)),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(
                                  0,
                                  (MediaQuery.of(context).size.height / 3.45) +
                                      value.dy.toDouble()),
                              // duration: const Duration(milliseconds: 200),
                              // curve: Curves.easeInOut,
                              child: AnimatedOpacity(
                                opacity: value.dx.toDouble(),
                                duration: const Duration(milliseconds: 400),
                                child: Container(
                                  width:   blogListHolder.getBlogType() != BlogType.allnews ?  MediaQuery.of(context).size.width / 3 :  MediaQuery.of(context).size.width / 2.25,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 4),
                                  child: TextButton.icon(
                                      label:  Text(
                                       blogListHolder.getBlogType() != BlogType.allnews ? 
                                       allMessages.value.allNews ?? 'All News': 'Back to Home',
                                        style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white),
                                      ),
                                      style: TextButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(13))),
                                          backgroundColor: Theme.of(context).primaryColor,
                                          elevation: 10),
                                      onPressed: blogListHolder.getBlogType() == BlogType.allnews ?
                                        widget.onBack : widget.onTap ??
                                          () {
                                          },
                                      icon:  Icon(
                                        blogListHolder.getBlogType() == BlogType.allnews ?  
                                        Icons.keyboard_arrow_left_rounded : Icons.keyboard_arrow_down_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      )),
                                ),
                              ),
                            );
                          })
                    ],
                  ),
                ),
                // TweenAnimationBuilder<Offset>(
                //     duration: const Duration(milliseconds: 100),
                //     tween: Tween<Offset>(
                //         begin: const Offset(0, -20), end: const Offset(1, 20)),
                //     builder: (context, value, child) {
                //       return AnimatedPositioned(
                //         bottom: value.dy.toDouble(),
                //         right: MediaQuery.of(context).size.width / 5,
                //         duration: const Duration(milliseconds: 200),
                //         curve: Curves.easeInOut,
                //         child: AnimatedOpacity(
                //           opacity: value.dx.toDouble(),
                //           duration: const Duration(milliseconds: 400),
                //           child: Container(
                //             width: MediaQuery.of(context).size.width / 3,
                //             padding: const EdgeInsets.symmetric(
                //                 vertical: 16, horizontal: 8),
                //             child: TextButton.icon(
                //                 label: const Text(
                //                   'All News',
                //                   style: TextStyle(color: Colors.white),
                //                 ),
                //                 style: TextButton.styleFrom(
                //                     shape: const RoundedRectangleBorder(
                //                         borderRadius: BorderRadius.all(
                //                             Radius.circular(13))),
                //                     backgroundColor: appMainColor,
                //                     elevation: 10),
                //                 onPressed: onTap ??
                //                     () {
                //                       Navigator.pop(context);
                //                       Navigator.push(
                //                           context,
                //                           MaterialPageRoute(
                //                               builder: (context) =>
                //                                   const SwipeablePage(
                //                                     0,
                //                                     isFromFeed: true,
                //                                   )));
                //                     },
                //                 icon: const Icon(
                //                   Icons.arrow_downward,
                //                   color: Colors.white,
                //                   size: 14,
                //                 )),
                //           ),
                //         ),
                //       );
                //     })
                 Positioned(
                    left: 16,
                    top: 16,
                    child: SafeArea(
                      child: Backbut(
                        onTap: widget.onBack
                      )))
              ],
            ),
          ),
        ),
      ),
    );
  }
}