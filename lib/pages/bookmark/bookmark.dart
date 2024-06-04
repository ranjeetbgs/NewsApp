import 'package:flutter/material.dart';
import 'package:incite/widgets/app_bar.dart';
import 'package:incite/widgets/loader.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import '../../api_controller/app_provider.dart';
import '../../api_controller/user_controller.dart';
import '../../model/blog.dart';
import '../../splash_screen.dart';
import '../../utils/color_util.dart';
import '../../utils/theme_util.dart';
import '../../widgets/anim_util.dart';
import '../search/widget/list_contain.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {

bool isLoad=false;
PreloadPageController pageController = PreloadPageController();

@override
  void initState() {
    // print(currentUser.value.apiToken);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var provider = Provider.of<AppProvider>(context,listen:false);
     if (!prefs!.containsKey('isBookmark')) {
        provider.getAllBookmarks().then(( value) {
         isLoad=false;
        setState(() { });
      });
     } else {
       provider.setAllBookmarks().then((value) {
       isLoad=false;
       setState(() { });
       });
     }    
     
    //  }     
    });
   
    super.initState();
  }

// void lastGreatBookmark(AppProvider provider) {
//   if (!provider.bookmarks.contains(Blog(id: 2345678,title: 'Last-Bookmark'))) {
//       provider.bookmarks.add(Blog(id: 2345678,title: 'Last-Bookmark'));
//    } 
// }

  @override
  void dispose() {
    
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context,listen:false);
    return Consumer<AppProvider>(
      builder: (context,val,child) {
        return CustomLoader(
          isLoading: isLoad,
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                 CommonAppbar(title:allMessages.value.mySavedStories ?? 'My Saved Stories',
                 isPinned: true),
                 SliverPadding(
                     padding: const EdgeInsets.only(bottom: 12,top: 10),
                     sliver: SliverToBoxAdapter(  
                       child: provider.bookmarks.isEmpty && isLoad==false ?
                       SizedBox(
                        height: size(context).height/1.5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              AnimationFadeScale(
                            child: Image.asset('assets/images/confuse.png',
                            width: 70,
                            height: 70,
                            color:dark(context) ? ColorUtil.white : ColorUtil.blackGrey,
                            ),
                          ),
                          const SizedBox(height: 20),
                           Text(allMessages.value.noSavedPostFound ?? 'No Bookmark Post Found',style:const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20,
                            fontWeight: FontWeight.w500
                          ))
                          ],
                        ),
                       ) :Builder(
                         builder: (context) {
                           return Column(
                            mainAxisAlignment: provider.bookmarks.isEmpty ? 
                            MainAxisAlignment.center : MainAxisAlignment.start,
                            children:   [
                               ...val.bookmarks.asMap().entries.map((e){ 
                                  if (e.value.title == 'Last-Bookmark' && e.value.id == 2345678) {
                                    return const SizedBox();
                                  } else {
                                    return ListWrapper(
                                      key: ValueKey(e.key),
                                      e: e.value,
                                      isBookmark: true,
                                      onChanged: (value) {
                                        provider.setBookmark(blog: e.value);
                                        setState(() {   });
                                      },
                                      index: e.key,
                                      onTap: () { 
                                        Navigator.pushNamed(context,'/BlogWrap',arguments: [e.key,true,pageController,e.value.id]).then((value) {

                                        });
                                    }); 
                                  }
                                })
                            ],
                           );
                         }
                       ),
                     ),
                   )
              ],
            ),
          ),
        );
      }
    );
  }
}