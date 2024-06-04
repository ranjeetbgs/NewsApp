import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:incite/api_controller/blog_controller.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/app_bar.dart';
import 'package:incite/widgets/custom_toast.dart';
import 'package:incite/widgets/loader.dart';
import 'package:incite/widgets/text_field.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import '../../api_controller/app_provider.dart';
import '../../main.dart';
import '../../model/blog.dart';
import '../../splash_screen.dart';
import '../../urls/url.dart';
import '../../utils/http_util.dart';
import '../../utils/image_util.dart';
import 'widget/list_contain.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isRecentSearch = true;
  
  bool searchListShor=true;
   GetStorage localList = GetStorage();
  late TextEditingController searchController;
  
  List mainDataList=[];
  
  bool isLoading=false;
  
  bool isFound = false;
  
  List<Blog> blogList = [];
  
 late AppProvider provider;
  FocusNode focusNode = FocusNode();


  @override
  void initState() {
    List local = localList.read('searchList') ?? [];
    for (int i = 0; i < local.length; i++) {
      mainDataList.add(local[i]);
    }
    provider = Provider.of<AppProvider>(context,listen:false);
    currentUser.value.isPageHome = false;
    searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
     provider.getAllBookmarks();
    });
    super.initState();
  }

PreloadPageController pageController = PreloadPageController();

  @override
  Widget build(BuildContext context) {
    return CustomLoader(
      isLoading: isLoading,
      child: Scaffold(
        body:  SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                decelerationRate: ScrollDecelerationRate.fast
              ),
            slivers: [
               const CommonAppbar(),
               const SliverToBoxAdapter(
                child: SizedBox(height: 20),
               ),
               MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                 child: SliverAppBar(
                  leadingWidth: 0,
                  automaticallyImplyLeading: false,
                  titleSpacing: 24,
                  toolbarHeight: 60,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  title: TextFieldWidget(
                    radius: 30,
                    focusNode: focusNode,
                    
                    onSaved: (value) {},
                    suffix: GestureDetector(
                        onTap: () {
                          if (searchController.text == '') {
                          showCustomToast(context, allMessages.value.searchFieldEmpty ?? 'Search Field is empty',);
                          } else {
                                // isNoResult = false;

                                searchListShor = true;
                                isRecentSearch = true;
                                searchController.text = '';
                                setState(() {});
                              }
                          
                        },
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 13,vertical: 13),
                              child:Icon(searchController.text =='' ? null
                               : Icons.close_rounded,size: 22,color:dark(context)? ColorUtil.white: ColorUtil.textblack),
                            ),
                    ),
                    prefix: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 13,vertical: 13),
                            child: SvgPicture.asset(SvgImg.search,
                            width: 22,height: 22,
                            color: dark(context)? ColorUtil.white: ColorUtil.textblack,
                           ),
                          ),
                      controller: searchController,
                      hint: 'Search your keyword',
                      textAction: TextInputAction.search,
                      onChanged: (text) {
                        // if (text.length >= 3) {
                        //   recentSearch = false;
                        // } else
                        if (searchController.text.isEmpty) {
                          isRecentSearch = true;
                          searchListShor = true;
                        }
                        setState(() { });
    
                        // if (text.length >= 3) {
                        //   setState(() {
                        //     getSearchedBlog();
                        //   });
                        // }
                      },
                      onFieldSubmitted: (value) {
                        if (searchController.text == '') {
                        showCustomToast(context,'Search Field is empty');
                        } else {
                          if (searchListShor) {
                            isRecentSearch=false;
                            getSearchedBlog();
                            if (!mainDataList.contains(searchController.text)) {
                              if (mainDataList.length >= 4) {
                                localList.remove('searchList');
                                mainDataList.removeAt(mainDataList.length - 1);
                                mainDataList.add(searchController.text);
                                localList.write('searchList', mainDataList);
                              } else {
                                localList.remove('searchList');
                                mainDataList.add(searchController.text);
                                localList.write('searchList', mainDataList);
                              }
                            } else {
                              localList.remove('searchList');
                              mainDataList.removeWhere(
                                  (item) => item == searchController.text);
                              mainDataList.add(searchController.text);
                              localList.write('searchList', mainDataList);
                            }
                            searchListShor = false;
                          } else {
                            searchListShor = true;
                            searchController.text = '';
                          }
                          setState(() {
                            searchListShor = false;
                          });
                        }
                      },
                        ),
                 ),
               ),
               SliverPadding(
                 padding: const EdgeInsets.only(bottom: 12,top: 10),
                 sliver: SliverToBoxAdapter(  
                   child: isRecentSearch == true ? 
                          Padding(
                            padding:const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                           children: [ 
                           ...mainDataList.map((e) => 
                          Recents(
                            onClear: () {
                               localList.remove('searchList');
                              mainDataList
                                  .removeWhere(
                                      (item) =>item == e);
                              localList.write(
                                  'searchList',
                                  mainDataList);
                              setState(() {});
                            },
                           onTap: () async{ 
                          searchController.text = e;
                          searchController.value =
                          TextEditingValue(
                             text: e,
                             selection: TextSelection.collapsed(offset:searchController.text.length),
                             );
                             isRecentSearch=false;
                            await getSearchedBlog();
                             setState(() {});
                          },text: e))
                        ],
                      )) : blogList.isNotEmpty && isFound
                       ? isLoading == true? const SizedBox() :   Column(
                        children: [
                      ...blogList.asMap().entries.map((e) =>
                       ListWrapper(
                        onTap: () {
                           Navigator.pushNamed(context, '/BlogWrap',arguments: [e.key,true,pageController,e.value.id]);
                        },
                        key: ValueKey(e.key),
                        onChanged: (value) {
                          e.value.isBookmark = value;
                          provider.setBookmark(blog: e.value);
                          setState(() {   });
                        },
                        isSearch: true,
                        e: e.value,
                        index: e.key)),
                    ],
                   ) : isRecentSearch == true && searchController.text == ''
                         ? const SizedBox()
                        : isLoading == true? const SizedBox() :  Container(
                        height: size(context).height/2,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                         child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                             Text(allMessages.value.noResultsFoundMatchingWithYourKeyword ?? "No result found",
                             textAlign: TextAlign.center,
                             style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500
                             ),
                             )
                           ],
                         ),
                       ),
                 ),
               ),
               
            ],
          ),
        ),
      ),
    );
  }
  
   Future getSearchedBlog() async {
    isLoading = true;
    setState(() { });
     final https = http.Client();
    try {
  if (searchController.text != '' && searchListShor == true) {
    final msg = jsonEncode({"keyword": searchController.text,});
    final String url = '${Urls.baseUrl}blog-search';

    final response = await https.post(
      Uri.parse(url),
      headers: currentUser.value.id != null ? {
        HttpHeaders.contentTypeHeader: 'application/json',
        "api-token" : currentUser.value.apiToken ?? '',
         "language-code" : languageCode.value.language ?? '',
      } :  {
        HttpHeaders.contentTypeHeader: 'application/json',
         "language-code" : languageCode.value.language ?? '',
      },
      body: msg,
      //encoding: Encoding.getByName('utf-8')
    );
    Map<String, dynamic> data = json.decode(response.body);
    debugPrint(data.toString());
    setState(() {
      if (data['success'] == true) {
        isFound = true;
      } else {
        isFound = false;
      }
  
      final list = DataModel.fromJson(data,isSearch: true);
      isRecentSearch = false;
      blogList = list.blogs;
      blogListHolder2.clearList();
      blogListHolder2.setList(list);
      blogListHolder2.setBlogType(BlogType.search);
      isLoading = false;
    });
  } else {
    isRecentSearch = true;
    isLoading = false;
    setState(() {});
  }
} finally {
    // Ensure to close the HTTP client when done
    https.close();
  }

  }
}

class Recents extends StatelessWidget {
  const Recents({
    super.key,
   required this.onClear,
    required this.onTap,
    this.text,
  });
 
  final String? text;
  final VoidCallback onTap,onClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Row(
               children: [
                const Icon(Icons.refresh_rounded,size: 16),
                const SizedBox(width: 6),
                 Text(text ?? '',style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15,
                  fontWeight: FontWeight.w500
                 )),
               ],
             ),
              IconButton(onPressed:onClear,
               icon:const Icon(Icons.close_rounded,size: 16))
          ]
        ),
      ),
    );
  }
}