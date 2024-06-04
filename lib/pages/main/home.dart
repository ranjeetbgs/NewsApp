import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:incite/api_controller/repository.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/utils/rgbo_to_hex.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/anim_util.dart';
import 'package:incite/widgets/drawer.dart';
import 'package:incite/widgets/tap.dart';
import 'package:provider/provider.dart';

import '../../api_controller/app_provider.dart';
import '../../api_controller/blog_controller.dart';
import '../../api_controller/user_controller.dart';
import '../../model/blog.dart';
import '../../splash_screen.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_util.dart';
import '../../widgets/shimmer.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key,required this.onChanged});
  final ValueChanged<int> onChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin{
  var controller = TextEditingController();
  
  int isCurr =0;
  
  PageController pageController = PageController(viewportFraction: 0.85);
  GlobalKey<ScaffoldState> sfkey = GlobalKey();
  
  bool isLoading=true;
  late UserProvider userProvider;

@override
  void initState() {
  userProvider= UserProvider();
  prefs!.remove('data');
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    userProvider.socialMediaList();
    userProvider.getAllAvialbleLanguages(context);
    userProvider.getCMS(context);
    if (currentUser.value.id != null) {
    getNotification().then((value) {
       appThemeModel.value.isNotificationEnabled.value = value as bool;
       setState(() {   });
    });
    }
   Future.delayed(const Duration(milliseconds: 500),() {
     isLoading = false;
     setState(() { });
   });
  });
    super.initState();
  }  

  

  @override
  Widget build(BuildContext context) {
  var appProvider = Provider.of<AppProvider>(context, listen: false);
    // if(isCurr==0){
    //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //   overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    //     SystemChrome.setPreferredOrientations([
    //       DeviceOrientation.portraitUp,
    //       DeviceOrientation.portraitDown,
    //     ]);
    // }
    super.build(context);
    var size = MediaQuery.of(context).size;
    var length = appProvider.featureBlogs.isEmpty ? 5 : appProvider.featureBlogs.length;
    return  Consumer<AppProvider>(
      builder: (context,appProvider,child) {
        return Scaffold(
          drawer: const DrawerPage(),
          onDrawerChanged: (isOpened) {
            
          },
          key: sfkey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            leadingWidth: 0,
            titleSpacing: 24,
            elevation: 0,
            toolbarHeight: 66,
            automaticallyImplyLeading: false,
            title: Container(
             decoration: BoxDecoration(
              color: dark(context)  ? Colors.grey.shade900 :ColorUtil.whiteGrey,
              borderRadius: BorderRadius.circular(30)
             ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                TapInk(
                  radius: 100,
                  onTap: () {
                    sfkey.currentState!.openDrawer();
                    // Navigator.push(context, PagingTransform(widget: const BookmarkPage()));
                  },
                    child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17,vertical: 15),
                     child: SvgPicture.asset(SvgImg.menu,width: 21,height: 15,
                     color: dark(context)? ColorUtil.white: ColorUtil.textblack,
                     ),
                    ),
                  ),
                  Row(
                    children: [
              TapInk(
                  radius: 100,
                  onTap: () {
                    Navigator.pushNamed(context, '/SearchPage');
                  },
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13,vertical: 13),
                          child: SvgPicture.asset(SvgImg.search,width: 22,height: 22,
                          color: dark(context)? ColorUtil.white: ColorUtil.textblack),
                        ),
                      ),
                     Padding(
                     padding:  const EdgeInsets.all(8.0),
                     child: ProfileWidget(
                       radius: 18,
                       size:22,
                       onTap:currentUser.value.id == null ? () {
                           Navigator.pushNamed(context,'/LoginPage');
                       } :  () {
                          Navigator.pushNamed(context, '/UserProfile',arguments: true);
                       },
                     ),
                     ),
                    ],
                  ),
                  
                ],
              ),),
          ),
          body: RefreshIndicator(
            onRefresh: () async{
              await Future.delayed(const Duration(milliseconds: 2000));
               var userProvider = UserProvider();
                // ignore: use_build_context_synchronously
               userProvider.getCMS(context);
               // ignore: use_build_context_synchronously
               userProvider.getLanguageFromServer(context);
               userProvider.checkSettingUpdate(context);
               appProvider.getCategory();
               userProvider.adBlogs();
               userProvider.socialMediaList();
               setState(() {});
            },
            child: CustomScrollView(
              // physics: const BouncingScrollPhysics(),
                slivers: [
                    SliverPadding(
                     padding:const EdgeInsets.only(left: 24,right: 24),
                     sliver: SliverToBoxAdapter(
                      child: TopHeader(onTap: () {
                            if (currentUser.value.id != null) {
                               blogListHolder.clearList();
                               appProvider.feed!.blogs = appProvider.feedBlogs;
                               blogListHolder.setList(appProvider.feed as DataModel);
                              //  print(appProvider.feed);
                                blogListHolder.setBlogType(BlogType.feed);
                                 widget.onChanged(0);
                               setState((){});
                            } else {
                                Navigator.pushNamed(context, '/LoginPage');
                            }
                        }),
                     ),
                   ),
                   SliverPadding(padding:const EdgeInsets.symmetric(vertical: 30),
                   sliver: SliverToBoxAdapter(
                     child: SizedBox(
                      height: size.height*0.28,
                       child: Column(
                         children: [
                        
                           Expanded(
                             child: PageView(
                              physics: const BouncingScrollPhysics(),
                              padEnds: false,
                              controller: pageController,
                              onPageChanged: (value) {
                                isCurr = value;
                                setState(() {  });
                              },
                              children: [
                                  ...List.generate(appProvider.featureBlogs.isEmpty ? 5 :length-1, (index) => 
                                  appProvider.featureBlogs.isEmpty  ?
                                   ShimmerLoader(
                                     width: size.width*0.75,
                                     height: size.height*0.258,
                                     margin: EdgeInsets.only(left:index==0 ? 16 : 0,right: 12),
                                  ) : FContainer(
                                  title: appProvider.featureBlogs[index].title,
                                  image:appProvider.featureBlogs[index].images != null &&
                                  appProvider.featureBlogs[index].images!.isNotEmpty ? appProvider.featureBlogs[index].images![0] : '',
                                  category: appProvider.featureBlogs[index].categoryName,
                                  color: appProvider.featureBlogs[index].categoryColor,
                                  index: index,
                                  onTap: () {
                                        blogListHolder.clearList();
                                        // appProvider.featureBlogs.add(Blog(
                                        //     title: 'Last-featured',
                                        //     id: 2345678876543212345,
                                        //     sourceName: 'Great',
                                        //     description: 'You have viewed all featured stories',
                                        //   )); 
                                        blogListHolder.setList(DataModel(blogs: appProvider.featureBlogs));
                                        blogListHolder.setBlogType(BlogType.featured);
                                        setState((){});
                                        widget.onChanged(index);

                                  },
                                  isfirst: index==0,
                                  )),
                             ]),
                           ),
                           const SizedBox(height: 15),
                           Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ...List.generate( appProvider.blog == null ? 5 :length-1, (index) =>  Container(
                                 margin: const EdgeInsets.only(right: 5),
                                child: CirlceDot(
                                  radius:isCurr == index ? 9 : 7,
                                  color: isCurr == index ?
                                   null : dark(context) ? Theme.of(context).cardColor :ColorUtil.whiteGrey,
                                )))
                            ],
                           )
                         ],
                       ),
                     ),
                   ),
                   ),
                   SliverPadding(
                     padding: const EdgeInsets.symmetric(horizontal: 24),
                     sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(allMessages.value.filterByTopics ?? 'Filter By Topics',style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                             )),
                          const SizedBox(height: 20),
                          GridView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          crossAxisSpacing: 15,
                                          mainAxisSpacing: 15,
                                          mainAxisExtent: 100,
                                          childAspectRatio: 4),
                                  
                                  children:  appProvider.blog == null  ? [
                                   ...List.generate(12,(es) => const CategoryShimmer())
                                  ] :[
                                      AnimationFadeSlide(
                                        key:  const ValueKey('345'),
                                        dx:0.1,
                                        child:TopicContainer(
                                          key:const ValueKey('3456'),
                                          image:"${allSettings.value.baseImageUrl}/${allSettings.value.appLogo}",
                                          onTap:(){
                                            blogListHolder.clearList();
                                            appProvider.allNews!.blogs = appProvider.allNewsBlogs;
                                            blogListHolder.setList(appProvider.allNews as DataModel);
                                            widget.onChanged(0);
                                            blogListHolder.setBlogType(BlogType.allnews);
                                            setState((){});
                                          },
                                          title: allMessages.value.allNews ?? 'All News'
                                        )),
                                         if(( appProvider.blog == null|| appProvider.blog != null) && appProvider.blog!.categories != null 
                                        && appProvider.blog!.categories!.isEmpty)
                                         ...List.generate(7, (index) => const CategoryShimmer(
                                         ))
                                        else
                                      ...appProvider.blog!.categories!.asMap().entries.map((e) => 
                                      AnimationFadeSlide(
                                        key: ValueKey("${e.key}${appProvider.blog!.categories![e.key].name}"),
                                        dx:0.0250*e.key+1,
                                        child: TopicContainer(
                                          key:ValueKey("123${appProvider.blog!.categories![e.key].name}"),
                                          onTap: () async {
                                            
                                        if(blogAds.value.isNotEmpty){ 
                                          var blogs = await appProvider.arrangeAds(appProvider.blog!.categories![e.key].data!.blogs);
                                           appProvider.blog!.categories![e.key].data!.blogs = blogs;
                                        }
                                            if(appProvider.calledPageurl == appProvider.blog!.categories![e.key].data!.lastPageUrl && !appProvider.blog!.categories![e.key].data!.blogs.contains(Blog(
                                                categoryName: appProvider.blog!.categories![e.key].name,
                                                id: appProvider.blog!.categories![e.key].id,
                                                title: 'Last-Category'
                                              ))) {
                                              appProvider.blog!.categories![e.key].data!.blogs.add(
                                              Blog(
                                                categoryName: appProvider.blog!.categories![e.key].name,
                                                id: appProvider.blog!.categories![e.key].id,
                                                title: 'Last-Category',
                                               )
                                             );
                                            }
                                            blogListHolder.clearList();
                                            blogListHolder.setList(appProvider.blog!.categories![e.key].data!);
                                            widget.onChanged(0);
                                            appProvider.setCategoryIndex(e.key);
                                            blogListHolder.setBlogType(BlogType.category);
                                            setState((){});
                                          },
                                          title: e.value.name,
                                          image: e.value.image
                                        ),
                                      )),
                                      if(allSettings.value.liveNewsStatus == '1') 
                                        TopicContainer(title: allMessages.value.liveNews ??'Live News',
                                        onTap: () {
                                           Navigator.pushNamed(context, '/LiveNews');
                                        }, image: '${allSettings.value.baseImageUrl}/${allSettings.value.liveNewsLogo}'),
                                     
                                      if(allSettings.value.ePaperStatus == '1') 
                                        TopicContainer(title: allMessages.value.eNews ?? 'E News',
                                        image:'${allSettings.value.baseImageUrl}/${allSettings.value.ePaperLogo}', 
                                        onTap: () {
                                           Navigator.pushNamed(context,'/ENews');
                                        }),
                                  ]
                            
                          ),
                          const SizedBox(height: 30),
                           Center(
                            child: Text(
                              allMessages.value.stayBlessedAndConnected ??'Made with ❤️ in India',style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                            )),
                          ),
                           const SizedBox(height: 20),
                        ],
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
  
  @override
  bool get wantKeepAlive => true;
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 68,
       height: 68,
      child: Column(
        children: [
          ShimmerLoader(
            borderRadius: 100,
            width: 56,
            height: 56,
          ),
          SizedBox(height: 12),
          ShimmerLoader(
            width: 68,
            height: 12,
            borderRadius: 4,
          )
        ],
      ),
    );
  }
}

class TopicContainer extends StatelessWidget {
  const TopicContainer({
    super.key,
    this.image ,
    this.title,
    this.onTap
  });

final String? image,title;
final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkResponse(
            radius: 40,
            onTap:onTap ?? () {},
            child: Container(
              width: 68,
              height: 68,
             decoration: BoxDecoration(
              shape: BoxShape.circle,
              image : image != null  && (image!.contains('.png') || image!.contains('.jpg') ||
               image!.contains('.webp') || image!.contains('.jpeg'))  && image!.contains('http') ?
               DecorationImage(image: CachedNetworkImageProvider(image.toString()))
               : DecorationImage(image: AssetImage(image ?? Img.logo),
              fit: BoxFit.cover
              ),
             ),
            ),
          ),
          const SizedBox(height: 10),
          Text(title ?? 'data',
          softWrap: true,
          overflow:TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            letterSpacing: -0.1,
            height: 1.2,
            ))
        ],
      ),
    );
  }
}


class FContainer extends StatelessWidget {
  const FContainer({
    super.key,
    this.title,
    this.image,
    this.category,
    this.color,
    this.index=0,
    this.isfirst=false,
    this.onTap
  });

  final String? title,image,category;
  final VoidCallback? onTap;
  final  int index;
  final String? color;
  final bool isfirst;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          width: size.width*0.75,
          height: size.height*0.258,
          margin: EdgeInsets.only(right: 15,left: isfirst ? 24 : 0),
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(image: CachedNetworkImageProvider(image ?? Img.img1),fit: BoxFit.cover,)
          ),
          ),
    Positioned.fill(child: Container(
       margin: EdgeInsets.only(right: 15,left: isfirst ? 24 :0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: ColorUtil.textGradient
      ),
    )),    
    Positioned.fill(
      child: TapInk(
          splash: ColorUtil.whiteGrey,
          radius: 20,
          onTap:onTap ?? () {
        
          },
          child:  Container(
          margin: EdgeInsets.only(left: isfirst ? 24 : 0,right: 15),
          alignment: Alignment.bottomLeft,
          child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text( title ?? 'KKR’s Rinku Singh adds glorious chapter to IPL story',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.5
                  )),
          ),
        ),
      )),
    Positioned(
    left:isfirst ?  24+15 : 15,
    top: 15,
    child: CategoryWrap(name: category,color: hexToRgb(color ?? '#000000'))
        )
      ],
    );
  }
}


class CategoryWrap extends StatelessWidget {
  const CategoryWrap({
    super.key,
    this.name,
    this.color,
    this.radius,
  });

final String? name;
final double? radius;
final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorUtil.textblack,
    borderRadius: BorderRadius.circular(radius ?? 30),
    boxShadow: const [
      BoxShadow(
        offset: Offset(0.25, -0.25),
        spreadRadius: 0.1,
        blurRadius: 0,
        color: Colors.white
      ),
      BoxShadow(
        offset: Offset(0.2, 0.7),
        spreadRadius: 1,
        blurRadius: 10,
        color: Colors.white12
      )
    ]
    ),
    
    padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min    ,
            children: [
               CirlceDot(
                color: color,
              ),
              const SizedBox(width: 6),
               Text( name ?? 'Sports',style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Colors.white
              ))
            ],
          ),
         );
  }
}

class CirlceDot extends StatelessWidget {
  const CirlceDot({
    super.key,
    this.radius,
    this.color,
    this.child,
    this.border,
  });

  final Color? color;
  final double? radius;
  final Widget? child;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:radius ??  8,
      height:radius ?? 8,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: border,
      gradient:color==null  ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
             isBlack(Theme.of(context).primaryColor)&& dark(context) ? Colors.white :  Theme.of(context).primaryColor, 
             isBlack(Theme.of(context).primaryColor)&& dark(context) ?  Colors.white24  :  Theme.of(context).colorScheme.secondary
       ]) : null
     ),
    child: child,
    );
  }
}

class TopHeader extends StatelessWidget {
  const TopHeader({
    super.key,
    required this.onTap,
  });
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Row(
             children: [
               Text(allMessages.value.featuredStories ?? 'Featured Stories',
               style: const TextStyle(
                fontFamily: 'Roboto',
                letterSpacing: -0.5,
                fontWeight: FontWeight.w600
                )),
             ],
           ),
           
          TapInk(
            radius: 12,
            splash: Theme.of(context).primaryColor.withOpacity(0.3),
            onTap: onTap,
            child:  Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(allMessages.value.myFeed ??'My Feed',
                  style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: isBlack(Theme.of(context).primaryColor) && dark(context)?  Colors.white : Theme.of(context).primaryColor
              )),
                 const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded,
                  color: isBlack(Theme.of(context).primaryColor) && dark(context) ?  Colors.white : Theme.of(context).primaryColor)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}