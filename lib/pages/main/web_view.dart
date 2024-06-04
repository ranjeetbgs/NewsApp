import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:incite/widgets/custom_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api_controller/user_controller.dart';
import '../../utils/theme_util.dart';

// var webViewScaffoldKey = GlobalKey<ScaffoldState>();

class CustomWebView extends StatefulWidget {
  final String url;
  const CustomWebView({Key? key, required this.url}) : super(key: key);
  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  String? host;
  List<PopupMenuItem>? popupList;

  @override
  void initState() {
    super.initState();

    final uri = Uri.parse(widget.url);
    host = uri.host;
    popupList = [
      // PopupMenuItem(
      //   child: Row(
      //     children: [
      //       GestureDetector(
      //         onTap: () {
      //           if (_webViewController != null) {
      //             _webViewController!.goBack();
      //           }
      //         },
      //         child: const Icon(
      //           Icons.arrow_back_ios,
      //           color: Colors.black,
      //           size: 20,
      //         ),
      //       ),
      //       const SizedBox(
      //         width: 20,
      //       ),
      //       GestureDetector(
      //         onTap: () {
      //           if (_webViewController != null) {
      //             _webViewController!.goForward();
      //           }
      //         },
      //         child: const Icon(
      //           Icons.arrow_forward_ios,
      //           color: Colors.black,
      //           size: 20,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      PopupMenuItem(
        child: GestureDetector(
            onTap: () {
              Clipboard.setData(
                ClipboardData(
                  text: widget.url,
                ),
              ).then((value) {
                showCustomToast(
                    context,
                    allMessages.value.copiedToClipboard ??
                        'copied to clipboard');
              });
            },
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.copy, size: 18),
              const SizedBox(width: 6),
              Text(
                allMessages.value.copyLink ?? 'Copy Link',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              ),
            ])),
      ),
      PopupMenuItem(
        child: GestureDetector(
          onTap: () {
            canLaunchUrl(Uri.parse(widget.url));
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.web, size: 18),
              const SizedBox(width: 6),
              Text(
                allMessages.value.openBrowser ?? 'Open in browser',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              ),
            ],
          ),
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarIconBrightness:
              dark(context) ? Brightness.light : Brightness.dark,
          statusBarColor: Colors.transparent),
      // child: Dismissible(
      // key: UniqueKey(),
      // direction: DismissDirection.startToEnd,
      // onDismissed: (direction) {
      //   if (direction == DismissDirection.startToEnd) {
      //     // Handle left swipe
      //     Navigator.pop(context);
      //   }
      // },
      // behavior: HitTestBehavior.deferToChild,
      // // background: Container(
      // //   color: Colors.white,
      // // ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Container(
                color: Theme.of(context).primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      host!,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const Spacer(),
                    PopupMenuButton(
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: widget.url,
                                ),
                              ).then((value) {
                                showCustomToast(
                                    context,
                                    allMessages.value.copiedToClipboard ??
                                        'Copied to clipboard');
                              });
                            },
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.copy, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                allMessages.value.copyLink ?? 'Copy Link',
                                style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 14),
                              ),
                            ]),
                          ),
                          PopupMenuItem(
                            onTap: () async {
                              showCustomToast(
                                  context,
                                  allMessages.value.openingNewsInWeb ??
                                      'Opening in browser');
                              await launchUrl(Uri.parse(widget.url));
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.web, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  allMessages.value.openBrowser ??
                                      'Open in browser',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins', fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        ];
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InAppWebView(
                gestureRecognizers: Set()
                  ..add(Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer())),
                initialUrlRequest: URLRequest(
                  url: Uri.parse(widget.url),
                ),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform:
                      InAppWebViewOptions(verticalScrollBarEnabled: true),
                  android: AndroidInAppWebViewOptions(
                    // Enable overscroll for Android
                    scrollBarStyle:
                        AndroidScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY,
                    overScrollMode: AndroidOverScrollMode.OVER_SCROLL_NEVER,
                  ),
                ),
                onWebViewCreated: (InAppWebViewController controller) {},
              ),
            ),
            /* Expanded(
                child: WebView(
                  initialUrl: widget.url,
                ),
              ),*/
          ],
        ),
      ),
      // ),
    );
  }
}
