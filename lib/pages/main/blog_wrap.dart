import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook_audience_network/ad/ad_interstitial.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:incite/api_controller/blog_controller.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/model/home.dart';
import 'package:incite/pages/main/widgets/quotes.dart';
import 'package:incite/pages/main/widgets/youtube_shorts.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/widgets/anim_util.dart';
import 'package:incite/widgets/button.dart';
import 'package:incite/widgets/custom_toast.dart';
import 'package:incite/widgets/last_widget.dart';
import 'package:incite/widgets/swipe_physics.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import '../../api_controller/app_provider.dart';
import '../../api_controller/repository.dart';
import '../../main.dart';
import '../../model/blog.dart';
import '../../utils/theme_util.dart';
import 'blog.dart';
import 'package:http/http.dart' as http;
import 'widgets/blog_ad.dart';

class BlogWrapPage extends StatefulWidget {
  const BlogWrapPage(
      {super.key,
      required this.onChanged,
      this.type,
      this.isBookmark = false,
      this.index = 0,
      this.preloadPageController,
      this.isBack = false});
  final ValueChanged onChanged;
  final bool isBookmark;
  final BlogOptionType? type;
  final bool isBack;
  final PreloadPageController? preloadPageController;
  final int index;

  @override
  State<BlogWrapPage> createState() => _BlogWrapPageState();
}

class _BlogWrapPageState extends State<BlogWrapPage>
    with AutomaticKeepAliveClientMixin {
  int cur = 0;
  // PreloadPageController preloadPageController = PreloadPageController();

  bool isWebOpen = false;
  bool isNotExist = false;
  bool isData = true;

  bool isInterstialLoaded = false;
  int fbAdindex = int.parse(allSettings.value.fbAdsFrequency.toString()) +
      int.parse(allSettings.value.admobFrequency.toString());
  int adindex = int.parse(allSettings.value.admobFrequency.toString());

  InterstitialAd? _interstitialAd;

  bool _isInterstitialAdLoaded = false;

  @override
  void initState() {
    super.initState();
    appLoaded = true;
    if (currentUser.value.id != null) {
      getStatusAccount(context);
    }
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      if (blogListHolder.getList().blogs.isNotEmpty &&
          blogListHolder.getList().blogs[0].images != null &&
          blogListHolder.getList().blogs[0].images!.isNotEmpty) {
        await precacheImage(
            CachedNetworkImageProvider(
                blogListHolder.getList().blogs[0].images![0]),
            context);
      }
      if (widget.isBookmark == true &&
          widget.preloadPageController!.hasClients) {
        widget.preloadPageController!.jumpToPage(widget.index);
      } else if (blogListHolder.blogType == BlogType.featured) {
        widget.preloadPageController!.jumpToPage(widget.index);
      }
    });
    if (Platform.isAndroid &&
        allSettings.value.enableFbAds == '1' &&
        allSettings.value.fbInterstitialIdAndroid != null) {
      _loadInterstitialAd();
    }

    if (Platform.isIOS &&
        allSettings.value.enableFbAds == '1' &&
        allSettings.value.fbAdsPlacementIdIos != null) {
      _loadInterstitialAd();
    }
    // cur = blogListHolder.getIndex();
  }

  @override
  void didChangeDependencies() {
    if (blogListHolder.blogType == BlogType.featured) {
      cur = blogListHolder.getIndex();
      setState(() {});
    }

    super.didChangeDependencies();
  }

  void _loadInterstitialAd() {
    FacebookInterstitialAd.loadInterstitialAd(
      // placementId: "YOUR_PLACEMENT_ID",
      placementId: Platform.isIOS == true
          ? allSettings.value.fbInterstitialIdIos ?? ''
          : allSettings.value.fbInterstitialIdAndroid ?? "",
      listener: (result, value) {
        debugPrint(">> FAN > Interstitial Ad: $result --> $value");
        if (result == InterstitialAdResult.LOADED) {
          _isInterstitialAdLoaded = true;
        }

        /// Once an Interstitial Ad has been dismissed and becomes invalidated,
        /// load a fresh Ad by calling this function.
        if (result == InterstitialAdResult.DISMISSED &&
            value["invalidated"] == true) {
          _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
        }
        setState(() {});
      },
    );
  }

  void createInterstitialAd() {
    // 'ca-app-pub-3940256099942544/1033173712'
    //  'ca-app-pub-3940256099942544/4411468910'
    Platform.isAndroid &&
            allSettings.value.enableAds == '1' &&
            allSettings.value.admobInterstitialIdAndroid != null
        ? InterstitialAd.load(
            adUnitId: allSettings.value.admobInterstitialIdAndroid ?? '',
            request: const AdRequest(),
            adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: (InterstitialAd ad) {
                // Keep a reference to the ad so you can show it later.
                isInterstialLoaded = true;
                _interstitialAd = ad;
                setState(() {});
              },
              onAdFailedToLoad: (LoadAdError error) {
                isInterstialLoaded = false;
                _interstitialAd!.dispose();
                setState(() {});
                debugPrint('InterstitialAd failed to load: $error');
              },
            ))
        : null;

    Platform.isIOS &&
            allSettings.value.enableAds == '1' &&
            allSettings.value.admobInterstitialIdIos != null
        ? InterstitialAd.load(
            adUnitId: allSettings.value.admobInterstitialIdIos ?? '',
            request: const AdRequest(),
            adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: (InterstitialAd ad) {
                // Keep a reference to the ad so you can show it later.
                isInterstialLoaded = true;
                _interstitialAd = ad;
                setState(() {});
              },
              onAdFailedToLoad: (LoadAdError error) {
                isInterstialLoaded = false;
                _interstitialAd!.dispose();
                setState(() {});
                debugPrint('InterstitialAd failed to load: $error');
              },
            ))
        : null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var provider = Provider.of<AppProvider>(context, listen: false);
    return widget.isBookmark == false && blogListHolder.getList().blogs.isEmpty
        ? SizedBox(
            width: size(context).width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimationFadeScale(
                  child: Image.asset(
                    'assets/images/confuse.png',
                    width: 100,
                    height: 100,
                    color:
                        dark(context) ? ColorUtil.white : ColorUtil.blackGrey,
                  ),
                ),
                const SizedBox(height: 12),
                AnimationFadeSlide(
                    dx: 0,
                    dy: 0.6,
                    child: Text('Oops!!',
                        style: Theme.of(context).textTheme.displayMedium)),
                const SizedBox(height: 12),
                AnimationFadeSlide(
                  dx: 0,
                  dy: 0.4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      blogListHolder.blogType == BlogType.feed
                          ? 'Seems like you have no interests selected. Please refer to page below to select interests'
                          : 'No post found related to this Category.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (blogListHolder.blogType == BlogType.feed)
                  ElevateButton(
                      width: 120,
                      style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                      onTap: currentUser.value.id == null
                          ? () {
                              Navigator.pushNamed(context, '/LoginPage');
                              // Navigator.push(context, PagingTransform(widget: NestedSwiperScreen()));
                            }
                          : () {
                              Navigator.pushNamed(context, '/SaveInterests',
                                  arguments: false);
                            },
                      text: allMessages.value.myFeed ?? 'My feed')
              ],
            ),
          )
        : PreloadPageView.builder(
            key: ValueKey(widget.isBookmark
                ? blogListHolder2.getList().total
                : blogListHolder.getBlogType()),
            itemCount: widget.isBookmark
                ? blogListHolder2.getList().blogs.length
                : blogListHolder.getList().blogs.length,
            physics: isWebOpen
                ? const NeverScrollableScrollPhysics()
                : MediaQuery.of(context).orientation == Orientation.landscape
                    ? const NeverScrollableScrollPhysics()
                    : const CustomScrollPhysics2(),
            controller: widget.preloadPageController,
            scrollDirection: Axis.vertical,
            preloadPagesCount: 5,
            onPageChanged: (value) {
              //var url = blogListHolder.getList().nextPageUrl;

              cur = value;
              isWebOpen = false;

              addFeedLast(provider);

              if (widget.isBookmark) {
                blogListHolder2.setIndex(value);
              } else {
                blogListHolder.setIndex(value);
              }

              if (widget.isBookmark == false) {
                var fb =
                    int.parse(allSettings.value.fbAdsFrequency.toString()) +
                        int.parse(allSettings.value.admobFrequency.toString());

                if (_isInterstitialAdLoaded == true &&
                    allSettings.value.enableFbAds != '0' &&
                    value % fbAdindex == 0) {
                  FacebookInterstitialAd.showInterstitialAd();
                  fbAdindex += fb;
                  setState(() {});
                } else {
                  debugPrint("Interstial Ad not yet loaded!");
                }

                print(blogListHolder.getList().nextPageUrl);
                print(provider.calledPageurl);
                print(blogListHolder.getList().lastPageUrl);
                if (value != 0 &&
                    value % 9 == 0 &&
                    blogListHolder.getList().nextPageUrl != null &&
                    provider.calledPageurl !=
                        blogListHolder.getList().lastPageUrl) {
                  print('---------- calledPageUrl -------------');
                  print(provider.calledPageurl);
                  print(blogListHolder.getList().nextPageUrl);

                  print('---------- LastPageUrl -------------');
                  print(blogListHolder.getList().lastPageUrl);
                  getLatestCategory(
                      nextpageurl: blogListHolder.getList().nextPageUrl ?? '',
                      provider: provider);
                }

                addNewsLast(provider);
                addCategoryLast(provider);

                if (isInterstialLoaded &&
                    _interstitialAd != null &&
                    value != 0 &&
                    value % adindex == 0) {
                  adindex +=
                      int.parse(allSettings.value.admobFrequency!.toString()) *
                          2;
                  _interstitialAd!.show();
                } else {
                  _interstitialAd = null;
                  createInterstitialAd();
                }
              }
              setState(() {});
              debugPrint(cur.toString());
            },
            itemBuilder: (context, index) {
              if (widget.isBookmark) {
                return blogListHolder2.getList().blogs[index].postType ==
                        PostType.video
                    ? YouTubeShort(
                        key: ValueKey(index),
                        onTap: () {
                          widget.onChanged(true);
                        },
                        model: blogListHolder2.getList().blogs[index])
                    : blogListHolder2.getList().blogs[index].postType ==
                            PostType.quote
                        ? QuotePage(
                            model: blogListHolder2.getList().blogs[index],
                            onTap: () {
                              widget.onChanged(true);
                            },
                            key: ValueKey(index))
                        : blogListHolder2.getList().blogs[index].postType ==
                                PostType.ads
                            ? BlogAd(
                                model: blogListHolder2.getList().blogs[index],
                                onTap: () {
                                  widget.onChanged(true);
                                },
                                key: ValueKey(index))
                            : blogListHolder2.getList().blogs[index].postType ==
                                    PostType.image
                                ? BlogPage(
                                    key: ValueKey(index),
                                    isBackAllowed: true,
                                    index: index,
                                    currIndex: cur,
                                    model:
                                        blogListHolder2.getList().blogs[index],
                                  )
                                : blogListHolder2
                                                .getList()
                                                .blogs[index]
                                                .title ==
                                            'Last-Bookmark' &&
                                        blogListHolder2
                                                .getList()
                                                .blogs[index]
                                                .id ==
                                            2345678
                                    ? LastNewsWidget(
                                        onBack: () {
                                          Navigator.pop(context);
                                        },
                                        keyword:
                                            allMessages.value.mySavedStories,
                                        isButton: false,
                                      )
                                    : const SizedBox();
              } else {
                return blogListHolder.getList().blogs[index].title ==
                            'Last-Category' ||
                        blogListHolder.getList().blogs[index].title ==
                            'Last-Feed' ||
                        blogListHolder.getList().blogs[index].title ==
                            'Last-News'
                    ? LastNewsWidget(
                        key: ValueKey(blogListHolder.getList().blogs[index].id),
                        onBack: widget.isBack
                            ? () {
                                Navigator.pop(context);
                              }
                            : () {
                                widget.onChanged(0);
                              },
                        keyword:
                            "${blogListHolder.getList().blogs[index].categoryName} Stories",
                        onTap: widget.isBack
                            ? () {
                                Navigator.pop(context);
                              }
                            : () {
                                blogListHolder.clearList();
                                provider.allNews!.blogs = provider.allNewsBlogs;
                                blogListHolder.setBlogType(BlogType.allnews);
                                blogListHolder
                                    .setList(provider.allNews as DataModel);
                                // widget.onChanged(0);
                                setState(() {});
                              },
                      )
                    : blogListHolder.getList().blogs[index].title ==
                                'Last-Featured' &&
                            blogListHolder.getList().blogs[index].id ==
                                2345678876543212345
                        ? LastNewsWidget(
                            onBack: () {
                              widget.onChanged(0);
                            },
                            keyword: allMessages.value.featuredStories,
                            onTap: () {
                              blogListHolder.clearList();
                              provider.allNews!.blogs = provider.allNewsBlogs;
                              blogListHolder
                                  .setList(provider.allNews as DataModel);
                              blogListHolder.setBlogType(BlogType.allnews);
                              setState(() {});
                            },
                          )
                        : blogListHolder.getList().blogs[index].postType ==
                                PostType.video
                            ? YouTubeShort(
                                key: ValueKey(index),
                                onTap: widget.isBack
                                    ? () {
                                        Navigator.pop(context);
                                      }
                                    : () {
                                        widget.onChanged(true);
                                      },
                                model: blogListHolder.getList().blogs[index])
                            : blogListHolder.getList().blogs[index].postType ==
                                    PostType.quote
                                ? QuotePage(
                                    model:
                                        blogListHolder.getList().blogs[index],
                                    type: widget.type,
                                    onTap: widget.isBack
                                        ? () {
                                            Navigator.pop(context);
                                          }
                                        : () {
                                            widget.onChanged(true);
                                          },
                                    key: ValueKey(index))
                                : blogListHolder
                                            .getList()
                                            .blogs[index]
                                            .postType ==
                                        PostType.ads
                                    ? BlogAd(
                                        isBack: widget.isBack,
                                        model: blogListHolder
                                            .getList()
                                            .blogs[index],
                                        onTap: () {
                                          widget.onChanged(true);
                                        },
                                        key: ValueKey(index))
                                    : blogListHolder
                                                .getList()
                                                .blogs[index]
                                                .postType ==
                                            PostType.image
                                        ? BlogPage(
                                            onChanged: (value) {
                                              isWebOpen = value;
                                              setState(() {});
                                            },
                                            type: widget.type,
                                            onTap: widget.isBack
                                                ? null
                                                : () {
                                                    widget.onChanged(false);
                                                    setState(() {});
                                                  },
                                            key: ValueKey(
                                                "$index${blogListHolder.getBlogType().name.toString()}"),
                                            isBackAllowed: widget.isBack,
                                            index: index,
                                            currIndex: cur,
                                            model: blogListHolder
                                                .getList()
                                                .blogs[index],
                                          )
                                        : const SizedBox();
              }
            },
          );
  }

  Future getLatestCategory({AppProvider? provider, String? nextpageurl}) async {
    var _blog = provider!.blog;

    try {
      DataCollection? anotherBlog;
      var url = nextpageurl ?? '';

      var result = await http.get(Uri.parse(url),
          headers: currentUser.value.id != null
              ? {
                  HttpHeaders.contentTypeHeader: "application/json",
                  "api-token": currentUser.value.apiToken ?? '',
                  "language-code": languageCode.value.language ?? '',
                }
              : {
                  HttpHeaders.contentTypeHeader: "application/json",
                  "language-code": languageCode.value.language ?? '',
                });
      final data = json.decode(result.body);
      anotherBlog = DataCollection.fromJson(data);

      if (nextpageurl != null) {
        for (var i = 0; i < anotherBlog.categories!.length; i++) {
          //for (var i = 0; i < _blog.; i++) {
          _blog!.categories![i].data!.currentPage =
              anotherBlog.categories![i].data!.currentPage;
          _blog.categories![i].data!.firstPageUrl =
              anotherBlog.categories![i].data!.firstPageUrl;
          _blog.categories![i].data!.lastPageUrl =
              anotherBlog.categories![i].data!.lastPageUrl;
          _blog.categories![i].data!.nextPageUrl =
              anotherBlog.categories![i].data!.nextPageUrl;
          _blog.categories![i].data!.to =
              anotherBlog.categories![i].data!.currentPage;
          _blog.categories![i].data!.prevPageUrl =
              anotherBlog.categories![i].data!.prevPageUrl;
          _blog.categories![i].data!.lastPage =
              anotherBlog.categories![i].data!.currentPage;
          _blog.categories![i].data!.from =
              anotherBlog.categories![i].data!.currentPage;
          _blog.categories![i].data!.blogs
              .addAll(anotherBlog.categories![i].data!.blogs);

          // }
        }
      }

      if (data['success'] == true) {
        debugPrint(data.toString());
        DataModel? allNews, feed;
        List<Blog> allNewsBlogs = [], feedBlogs = [];

        // prefs!.setString('collection', result.body);

        for (var i = 0; i < anotherBlog.categories!.length; i++) {
          // if (anotherBlog.categories![i].isFeed == true) {
          //     provider.selectedFeed.add(anotherBlog.categories![i].id);
          //  }

          for (var j = 0;
              j < anotherBlog.categories![i].data!.blogs.length;
              j++) {
            if (anotherBlog.categories![i].isFeed == true) {
              if (!provider.feedBlogs
                  .contains(anotherBlog.categories![i].data!.blogs[j])) {
                feedBlogs.add(anotherBlog.categories![i].data!.blogs[j]);
              }
            }

            if (anotherBlog.categories![i].data!.blogs[j].isFeatured == 1 &&
                provider.featureBlogs.length != 11) {
              if (!provider.featureBlogs
                  .contains(anotherBlog.categories![i].data!.blogs[j])) {
                provider.featureBlogs
                    .add(anotherBlog.categories![i].data!.blogs[j]);
              }
            }

            if (!provider.allNewsBlogs
                .contains(anotherBlog.categories![i].data!.blogs[j])) {
              allNewsBlogs.add(anotherBlog.categories![i].data!.blogs[j]);
            }
          }
        }
        provider.setCalledUrl(nextpageurl);

        allNewsBlogs.sort((a, b) {
          return DateTime.parse(b.scheduleDate.toString())
              .compareTo(DateTime.parse(a.scheduleDate.toString()));
        });
        feedBlogs.sort((a, b) {
          return DateTime.parse(b.scheduleDate.toString())
              .compareTo(DateTime.parse(a.scheduleDate.toString()));
        });
        //
        if (blogAds.value.isNotEmpty) {
          provider.allNewsBlogs.addAll(await provider.arrangeAds(allNewsBlogs));
          provider.feedBlogs.addAll(await provider.arrangeAds(feedBlogs));
        } else {
          provider.allNewsBlogs.addAll(allNewsBlogs);
          provider.feedBlogs.addAll(feedBlogs);
        }

        feed = DataModel(
            currentPage: _blog!.categories![0].data!.currentPage,
            firstPageUrl: _blog.categories![0].data!.firstPageUrl,
            lastPageUrl: _blog.categories![0].data!.lastPageUrl,
            nextPageUrl: _blog.categories![0].data!.nextPageUrl,
            to: _blog.categories![0].data!.to,
            prevPageUrl: _blog.categories![0].data!.prevPageUrl,
            lastPage: _blog.categories![0].data!.lastPage,
            from: _blog.categories![0].data!.from,
            blogs: provider.feedBlogs);

        allNews = DataModel(
            currentPage: _blog.categories![0].data!.currentPage,
            firstPageUrl: _blog.categories![0].data!.firstPageUrl,
            lastPageUrl: _blog.categories![0].data!.lastPageUrl,
            nextPageUrl: _blog.categories![0].data!.nextPageUrl,
            to: _blog.categories![0].data!.to,
            prevPageUrl: _blog.categories![0].data!.prevPageUrl,
            lastPage: _blog.categories![0].data!.lastPage,
            from: _blog.categories![0].data!.from,
            blogs: provider.allNewsBlogs);

        if (blogListHolder.getBlogType() == BlogType.feed) {
          blogListHolder.updateList(feed);
        } else if (blogListHolder.getBlogType() == BlogType.allnews) {
          blogListHolder.updateList(allNews);
        } else {
          blogListHolder.updateList(provider
              .blog!.categories![provider.categoryIndex].data as DataModel);
        }

        provider.setCategoryBlog(_blog);
        provider.setAllNews(load: allNews);
        provider.setMyFeed(load: feed);
      }
    } on SocketException {
      showCustomToast(context,
          allMessages.value.noInternetConnection ?? 'No Internet Connection');
    } catch (e) {
    } finally {}
  }

  void addCategoryLast(AppProvider provider) {
    if (provider.calledPageurl ==
            provider
                .blog!.categories![provider.categoryIndex].data!.lastPageUrl &&
        !provider.blog!.categories![provider.categoryIndex].data!.blogs
            .contains(Blog(
                categoryName:
                    provider.blog!.categories![provider.categoryIndex].name,
                id: provider.blog!.categories![provider.categoryIndex].id,
                title: 'Last-Category'))) {
      provider.blog!.categories![provider.categoryIndex].data!.blogs.add(Blog(
        categoryName: provider.blog!.categories![provider.categoryIndex].name,
        id: provider.blog!.categories![provider.categoryIndex].id,
        title: 'Last-Category',
      ));
    }
  }

  void addNewsLast(AppProvider provider) {
    if (provider.calledPageurl == provider.allNews!.lastPageUrl) {
      if (blogListHolder.getBlogType() == BlogType.allnews &&
          !blogListHolder.getList().blogs.contains(Blog(
                title: 'Last-News',
                categoryName: "All News",
                id: 1111111111111,
                sourceName: 'Great',
              ))) {
        blogListHolder.getList().blogs.add(Blog(
              title: 'Last-News',
              categoryName: "All News",
              id: 1111111111111,
              sourceName: 'Great',
            ));
      } else {
        if (blogListHolder.getBlogType() != BlogType.allnews &&
            blogListHolder.getList().blogs.contains(Blog(
                  title: 'Last-News',
                  categoryName: "All News",
                  id: 1111111111111,
                  sourceName: 'Great',
                ))) {
          blogListHolder.getList().blogs.remove(Blog(
                title: 'Last-News',
                categoryName: "All News",
                id: 1111111111111,
                sourceName: 'Great',
              ));
        }
      }
    }
  }

  void addFeedLast(AppProvider provider) {
    if (provider.calledPageurl == provider.feed!.lastPageUrl) {
      //  print(blogListHolder.getBlogType());

      if (blogListHolder.getBlogType() == BlogType.feed &&
          !blogListHolder.getList().blogs.contains(Blog(
                title: 'Last-Feed',
                categoryName: "My Feed",
                id: 234202120,
                sourceName: 'Great',
              ))) {
        print('adding feed');
        blogListHolder.getList().blogs.add(Blog(
              title: 'Last-Feed',
              categoryName: "My Feed",
              id: 234202120,
              sourceName: 'Great',
            ));
      } else {
        if (blogListHolder.getBlogType() != BlogType.feed &&
            blogListHolder.getList().blogs.contains(Blog(
                  title: 'Last-Feed',
                  categoryName: "My Feed",
                  id: 234202120,
                  sourceName: 'Great',
                ))) {
          blogListHolder.getList().blogs.remove(Blog(
                title: 'Last-Feed',
                categoryName: "My Feed",
                id: 234202120,
                sourceName: 'Great',
              ));
        }
      }
    }
  }

  @override
  bool get wantKeepAlive => isData;
}
