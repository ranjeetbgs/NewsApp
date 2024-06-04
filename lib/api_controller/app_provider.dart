import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/analytic.dart';
import '../model/blog.dart';
import '../splash_screen.dart';
import '../urls/url.dart';
import 'blog_controller.dart';

DateTime? signInStart;
DateTime? signInEnd;

class AppProvider with ChangeNotifier {
  bool _load = false;
 DataCollection? _blog;
  var _blogList;
  List selectedFeed =[];
  List<Map<String,dynamic>>  analytics = [];
  List<Map<String,dynamic>> blogTimeSpent = [];
  List<Map<String,dynamic>> ttsTimeline = [];
  List<Blog> bookmarks = [];
  List<int> permanentIds = [];
  List<int> shareIds=[],viewIds=[],bookmarkIds=[],pollIds=[],ttsIds=[];
  List<Blog> feedBlogs= [],allNewsBlogs = [],featureBlogs=[];
  DateTime? appStartTime;
  DataModel? feed,allNews;
  List<Blog> ads = [];
  //final _articlesController = PublishSubject<List<Blog>?>();
  // final _sourcesController = PublishSubject<List<Blog>?>();
  int categoryIndex=0;
  List<int> removeBookmarkIds=[];
  
  String? calledPageurl;
  
  //  void close() {
  //   _articlesController.close();
  // }

  // Stream<List<Blog>?> get articles => flipController.stream;
  
  AppProvider() {
    //_getCurrentUser();
    // getCategory();
    // getBlogData();
  }
  // StreamController<List<Blog>> flipController = StreamController<List<Blog>>.broadcast();
  
  // Stream<List<Blog>> get stream => flipController.stream;

  // void addToStream(List<Blog> data) {
  //   flipController.sink.add(data);
  // }

  // @override
  // void dispose() {
  //   flipController.close();
  //   super.dispose();
  // }

  DataCollection? get blog => _blog;
  // Blog? get blogList => _blogList;
  // Blog? get blogList2 => _blogList2;
   List<Blog>? get getFeed => feedBlogs ;

  List<Category> get blogList => _blogList ?? <Category>[];

  bool get load => _load;

  clearList() {
    _blog = null;
    _blogList = null;
    notifyListeners();
  }

  setNewsBlog(DataModel load) {
    allNews = load;
    notifyListeners();
  }

   setCalledUrl(String? load) {
    calledPageurl = load;
    notifyListeners();
  }

   setCategoryBlog(DataCollection load) {
    _blog = load;
    notifyListeners();
  }

   setCategoryIndex(int index) {
    categoryIndex = index;
    notifyListeners();
  }

  setLoading({bool? load}) {
    _load = load!;
    notifyListeners();
  }

 setAllNews({DataModel? load}) {
    allNews = load;
    notifyListeners();
  }

 setMyFeed({DataModel? load}) {
    feed = load;
    notifyListeners();
  }


  appTime(DateTime? time) {
    appStartTime=time;
     notifyListeners();
  }

  setBookmark({required Blog blog}) {
    // prefs!.remove('bookmarks');
    
     if (permanentIds.contains(blog.id)) {
        bookmarks.remove(blog);
        permanentIds.remove(blog.id);
     } else {
        bookmarks.add(blog);
        permanentIds.add(blog.id!.toInt());
     }
     if (bookmarks.contains(Blog(id: 2345678,title: 'Last-Bookmark'))) {
         bookmarks.remove(Blog(id: 2345678,title: 'Last-Bookmark'));
     }
    
     DataModel myModelJsonList = DataModel(blogs:bookmarks);
     var data = json.encode(myModelJsonList.toJson());
     prefs!.setString('bookmarks',data);
     bookmarks.add(Blog(id: 2345678,title: 'Last-Bookmark'));
     notifyListeners();
  }

   Future setAllBookmarks() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
      if (prefs!.containsKey('bookmarks') ) {
        var data = json.decode(pref.getString('bookmarks').toString());
        DataModel data2 = DataModel.fromJson(data);
        bookmarks = data2.blogs;
        permanentIds= [];
        data2.blogs.forEach((element) {
          permanentIds.add(element.id!.toInt());
        });
        bookmarks.add(Blog(id: 2345678,title: 'Last-Bookmark'));
        blogListHolder2.clearList();
        blogListHolder2.setList(data2);
        blogListHolder2.setBlogType(BlogType.bookmarks);
      } 
      notifyListeners();
    }

  Future<DataModel?>  getAllBookmarks() async{
       var url = "${Urls.baseUrl}get-bookmarks";
      // var client = InciteHttp().client;
       var result = await http.get(  
          Uri.parse(url),
          headers:{
            HttpHeaders.contentTypeHeader : "application/json",
            "api-token": currentUser.value.apiToken ?? '',
            "language-code" : languageCode.value.language ?? '',
          }
        );
        final data = json.decode(result.body);
       if (data['success']==true) {
        // debugPrint(data.toString());
        // print(data['data'] );
      //  bookmarks = data['data'].map((e) =>Blog.fromJson(e)).toList();
         if (data['data'] != null) {
            final list = DataModel.fromJson(data['data']);
          bookmarks = list.blogs;
          list.blogs.forEach((element) {
          permanentIds.add(element.id!.toInt());
        });

          prefs!.setBool('isBookmark', true);
          prefs!.setString('bookmarks',json.encode(data['data']));
          return list;
         }else{
           setAllBookmarks();
         }
          notifyListeners();
          
       }else{
        return null;
       }
      
    }


   Future getCategory({bool allowUpdate = true, bool headCall = true, String? nextpageurl}) async {
     var client = http.Client();
      try {
       
      //  await checkUpdate(route: 'blog-list',etag: 'blog-list-tag',headCall: headCall).then((value) async{
      //   if (value == true && allowUpdate == false) {
      //     getCacheBlog();
      //     // print('-------- Cache ==========');
      //     notifyListeners();
      //   } else {
        DataCollection? anotherBlog;
        var url = nextpageurl ?? "${Urls.baseUrl}blog-list";
       
        var result = await http.get(  
          Uri.parse(url),
          headers: currentUser.value.id != null ? 
           {
            HttpHeaders.contentTypeHeader : "application/json",
            "api-token": currentUser.value.apiToken ?? '',
            "language-code" : languageCode.value.language ?? '',
          }:{
            HttpHeaders.contentTypeHeader :"application/json",
            "language-code" : languageCode.value.language ?? '',
          }
        );

      //  print(languageCode.value.language);
        final data = json.decode(result.body);
        if (data['success']==true) {
        
        _blog = DataCollection.fromJson(data);

        feedBlogs = [];
      //  if(nextpageurl == null){
         featureBlogs = [];
      //  }
        allNewsBlogs = [];
        selectedFeed = [];
       
        notifyListeners();
        
        // print("_blog!.categories![0].name.toString()");
        // print(_blog!.categories![0].data!.blogs[0].title);
        prefs!.setString('collection', result.body);        
      if(nextpageurl == null){
        for (var i = 0; i < _blog!.categories!.length; i++) {
          if (_blog!.categories![i].isFeed == true) {
              selectedFeed.add(_blog!.categories![i].id);
           }
          for (var j = 0; j <  _blog!.categories![i].data!.blogs.length; j++) {
            if (_blog!.categories![i].isFeed==true) {
              if (!feedBlogs.contains( _blog!.categories![i].data!.blogs[j])) {
               feedBlogs.add(_blog!.categories![i].data!.blogs[j]);  
              }
            }
            if (_blog!.categories![i].data!.blogs[j].isFeatured == 1 && _blog!.categories![i].data!.blogs[j].type != 'quote') {
             if (!featureBlogs.contains( _blog!.categories![i].data!.blogs[j]) && featureBlogs.length < 10) {
               featureBlogs.add( _blog!.categories![i].data!.blogs[j]);
              }
            }
             if (!allNewsBlogs.contains( _blog!.categories![i].data!.blogs[j])) {
                 allNewsBlogs.add( _blog!.categories![i].data!.blogs[j]);
             }
            
           }
         }
          featureBlogs.sort((a, b) { 
             return DateTime.parse(b.scheduleDate.toString()).compareTo(DateTime.parse(a.scheduleDate.toString()));
          });
          
          allNewsBlogs.sort((a, b) { 
           return DateTime.parse(b.scheduleDate.toString()).compareTo(DateTime.parse(a.scheduleDate.toString()));
        });

         feedBlogs.sort((a, b) { 
           return DateTime.parse(b.scheduleDate.toString()).compareTo(DateTime.parse(a.scheduleDate.toString()));
        });

          calledPageurl = _blog!.categories![0].data!.firstPageUrl ??'';
         
         if(blogAds.value.isNotEmpty){   
             allNewsBlogs = await arrangeAds(allNewsBlogs);
             feedBlogs = await arrangeAds(feedBlogs);
          }
        
        notifyListeners();
        
        feed = DataModel(
          currentPage:  _blog!.categories![0].data!.currentPage,
          firstPageUrl:  _blog!.categories![0].data!.firstPageUrl,
          lastPageUrl: _blog!.categories![0].data!.lastPageUrl,
          nextPageUrl: _blog!.categories![0].data!.nextPageUrl,
          to:  _blog!.categories![0].data!.to,
           prevPageUrl: _blog!.categories![0].data!.prevPageUrl,
          lastPage: _blog!.categories![0].data!.lastPage,
          from: _blog!.categories![0].data!.from,
          blogs: feedBlogs
        );
  
        allNews = DataModel(
          currentPage:  _blog!.categories![0].data!.currentPage,
          firstPageUrl:  _blog!.categories![0].data!.firstPageUrl,
          lastPageUrl: _blog!.categories![0].data!.lastPageUrl,
          nextPageUrl: _blog!.categories![0].data!.nextPageUrl,
          to:  _blog!.categories![0].data!.to,
          prevPageUrl: _blog!.categories![0].data!.prevPageUrl,
          lastPage: _blog!.categories![0].data!.lastPage,
          from: _blog!.categories![0].data!.from,
          blogs: allNewsBlogs
        );
        } 

        if (feed!.blogs.isNotEmpty && _blog!.categories![0].data!.nextPageUrl == null) {
           feed!.blogs.add(Blog(
              title: 'Last-Feed',
              categoryName: "My Feed",
              id: 234202120,
              sourceName: 'Great',
        ));
      }
      
      featureBlogs.add(Blog(
        title: 'Last-Featured',
        id: 2345678876543212345,
        sourceName: 'Great',
        description: 'You have viewed all featured stories',
      )); 

        if (currentUser.value.id !=null) {
            blogListHolder.clearList();
            blogListHolder.setList(feed!);
            blogListHolder.setBlogType(BlogType.feed);
        } else {
            blogListHolder.clearList();
            blogListHolder.setList(allNews!);
            blogListHolder.setBlogType(BlogType.allnews);
        }
       
           //addToStream(blogListHolder.getList().blogs);
          
          // flipController.stream.asBroadcastStream();
         }
        notifyListeners();
      //   }
      //  });
       
      } on SocketException {
         getCacheBlog();
         notifyListeners();

      } catch (e) {
        //  final lines = stackTrace.toString().split('\n');
        // print('Exact line: $lines');
        debugPrint(e.toString());
        // setLoading(load: false);    
        getCacheBlog();
        notifyListeners();
      } finally {

          
          client.close();
      }
      // if (prefs!.containsKey('Category')) {
      //   String category = prefs!.getString('Category').toString();
      //   _blog = Category.fromJson(jsonDecode(category));
      // }
    
  // Future categoryBlogs(){
  //   notifyListeners();
  // }


}


Future updateBlogList(Blog newBlog, AppProvider provider) async {
  
  var data = DataModel();
  data.blogs = [];
  // provider.allNews!.blogs = [];
  // provider.allNews!.blogs.add(newBlog);
  // if (data.isNotEmpty && data.contains(newBlog)) {
  //   data.remove(newBlog);
  // }
  data.blogs.add(newBlog);
  blogListHolder.setList(data);
  blogListHolder.setBlogType(BlogType.allnews);
  notifyListeners();
}


   void getCacheBlog() async{
        feedBlogs = [];
        featureBlogs = [];
        allNewsBlogs = [];
        ads= [];
        selectedFeed = [];

      if (prefs!.containsKey('collection')) {
       String collection = prefs!.getString('collection').toString();
       _blog = DataCollection.fromJson(jsonDecode(collection));

          for (var i = 0; i < _blog!.categories!.length; i++) {
          for (var j = 0; j <  _blog!.categories![i].data!.blogs.length; j++) {
            if (_blog!.categories![i].data!.blogs[j].type != 'ads') {
               allNewsBlogs.add( _blog!.categories![i].data!.blogs[j]);
            }
           
            if ( _blog!.categories![i].isFeed==true && _blog!.categories![i].data!.blogs[j].type != 'ads') {
               selectedFeed.add(_blog!.categories![i].id);
               feedBlogs.add( _blog!.categories![i].data!.blogs[j]);  
            }

            if (_blog!.categories![i].data!.blogs[j].isFeatured == 1) {
               featureBlogs.add(_blog!.categories![i].data!.blogs[j]);
            }
           }
         }
         featureBlogs.sort((a, b) { 
           return DateTime.parse(b.createdAt.toString()).compareTo(DateTime.parse(b.createdAt.toString()));
          });
           allNewsBlogs.sort((a, b) { 
           return DateTime.parse(b.createdAt.toString()).compareTo(DateTime.parse(b.createdAt.toString()));
         });
         feedBlogs.sort((a, b) { 
           return DateTime.parse(b.createdAt.toString()).compareTo(DateTime.parse(b.createdAt.toString()));
        });
           if(blogAds.value.isNotEmpty){   
                allNewsBlogs = await arrangeAds(allNewsBlogs);
                feedBlogs = await arrangeAds(feedBlogs);
            }
     feed = _blog!.categories![0].data!;
     allNews = _blog!.categories![0].data!;
     
     allNews!.blogs = allNewsBlogs;
     feed!.blogs = feedBlogs;
      if (!featureBlogs.contains(Blog(
        title: 'Last-Featured',
        id: 2345678876543212345,
        sourceName: 'Great',
        description: 'You have viewed all featured stories',
      ))) {
         featureBlogs.add(Blog(
        title: 'Last-Featured',
        id: 2345678876543212345,
        sourceName: 'Great',
        description: 'You have viewed all featured stories',
      )); 
      } 
      blogListHolder.clearList();
      blogListHolder.setList(feed!);
      notifyListeners();
     }
   }


   void addShareData(int id){
    shareIds.add(id);
      analytics[3] = {
        'type': 'share',
        'blog_ids': shareIds
      };
     notifyListeners();
   }

     void addBookmarkData(int id){
    bookmarkIds.add(id);
      analytics[1] = {
        'type': 'bookmark',
        'blog_ids': bookmarkIds
    };
    notifyListeners();
   }
   
   void addTtsData(int id,String startTime,String endTime){
    ttsTimeline.add({
      "id" : id,
      "start_time" : startTime,
      "end_time" : endTime
    });
      analytics[7] = {
        "type": "tts",
        "blogs": ttsTimeline
    };
    notifyListeners();
   }

  void removeBookmarkData(int id){
    // if (bookmarkIds.contains(id)) {
    //   bookmarkIds.remove(id);
    // }
    removeBookmarkIds.add(id);
      analytics[6] = {
      "type": "remove_bookmark",
      "blog_ids": removeBookmarkIds
    };
  //  debugPrint(bookmarkIds.toString());
    notifyListeners();
   }
   
    void addPollShare(int id){
    pollIds.add(id);
      analytics[2] = {
        "type": "poll_share",
        "blog_ids": pollIds
    };
    notifyListeners();
   }
   

    void addviewData(int id){
    viewIds.add(id);
      analytics[4] = {
        "type": "view",
        "blog_ids": viewIds
    };
    notifyListeners();
   }

    void addBlogTimeSpent(BlogTime blogtime){
      var data = {
        "type": "blog_time_spent",
        "blogs" : blogTimeSpent
      };
      var data2=  {
        "id": blogtime.id,
        "start_time": blogtime.startTime!.toIso8601String(),
        "end_time": blogtime.endTime!.toIso8601String()
      };
      analytics[0] = data;
      blogTimeSpent.add(data2);
      notifyListeners();
   }

    void addAppTimeSpent({DateTime? startTime,DateTime? endTime}){
      var data = {
         'type': 'app_time_spent',
         'start_time': startTime,
         'end_time': endTime!.toIso8601String()
      } ;
      analytics.add(data);
      notifyListeners();
   }

   

  Future getAnalyticData()async{
    final msg = jsonEncode(analytics);
  final client = http.Client();
  

    try {
  final String url = '${Urls.baseUrl}add-analytics';
  final response = await client.post(Uri.parse(url),
    headers: currentUser.value.id != null ? {
      HttpHeaders.contentTypeHeader: 'application/json',
      "api-token" : currentUser.value.apiToken.toString(),
      //"language-code" : languageCode.value.language ?? '',
    }: {
      HttpHeaders.contentTypeHeader: 'application/json',
      // "language-code" : languageCode.value.language ?? '',
    },
    body: msg,
  // ignore: data_might_complete_normally_catch_error
  ).catchError((e) {
    debugPrint("register error $e");
  });
  debugPrint(analytics.toString());
  var res = json.decode(response.body);
    
//  print(res);

  if (res['success'] == true) {
      setAnalyticData();
     notifyListeners();
  }
} on Exception catch (e) {
     print(e);
  } finally {
    client.close();
}
    notifyListeners();
   }


   void setAnalyticData(){
    analytics = [{
           "type" : "blog_spent_time",
           "blogs" : []
       },{
          "type" :'bookmark',
          "blog_ids": []
       },{
          "type" :'poll_share',
          "blog_ids": []
       },{
          "type" : 'share',
          "blog_ids": []
       },{
          "type" :'view',
          "blog_ids":[]
       },{
          'type' : 'sign_in',
          'start_time':'',
       },{
          "type" : "remove_bookmark",
          "blog_ids" : [] 
       },{
          "type" : "tts",
          "blogs" : [] 
       }];
        viewIds = [];
        notifyListeners();
   }

   void addUserSession({bool isSignup=false,isSocialSignup = false,bool isSignin=false}){
      var data = {
        'type' : isSignup ? 'sign_up' :
         isSocialSignup ?  'social_media_signup' : 
         isSignup==false && isSocialSignup==false && isSignin==false ? 
        'social_media_signin' : 'sign_in',
        'start_time': DateTime.now().toIso8601String(),
      };
      analytics[5] = data;
      notifyListeners();
   }
     void logoutUserSession() {
      var data = {
        'type' : 'logout',
      };
      analytics.add(data);
      notifyListeners();
   }

   void clearLists(){
     selectedFeed = [];
     feedBlogs = [];
     bookmarks=[];
    notifyListeners();  
   }

// Future<List<Blog>> arrangeAds(List<Blog> feedss) async{

//   int count = 0;
//   int adCount=0;
//   List<Blog> blogWithAds = feedss;

//   for (var i = 0; i < blogWithAds.length; i++) {
//     //print(ads[i].title);
//     for (var j = 0; j < blogAds.value.length; j++) {
//       if (i == 0) {
//         adCount+=1;
//         count+= blogAds.value[j].frequency!.toInt();
//        } else if(count % blogAds.value[j].frequency!.toInt() == 0){
//         adCount+=1;
//         count+=blogAds.value[j].frequency!.toInt()+1;
//        }
//        if (count < blogWithAds.length && count % blogAds.value[j].frequency!.toInt()==0) {
//          blogWithAds.insert(count, blogAds.value[j]);
//          break;
//      }
//     }
//    }
//    return feedss;
//   }
Future<List<Blog>> arrangeAds(List<Blog> blogss) async{
  List<Blog> blogsWithAds = [];
  int adCount=0;
  int frequencyCount = blogAds.value[adCount].frequency!.toInt();
  for (int i = 0; i < blogss.length; i++) {
    blogsWithAds.add(blogss[i]);

 //  for (int j = 0; j < blogAds.value.length; j++) {
   // if(blogAds.value[adCount].frequency!.toInt()-1 >= i ) {
      if ((i+1) % frequencyCount == 0) {
        blogsWithAds.add(blogAds.value[adCount]);
         if (adCount == blogAds.value.length-1) {
           adCount=0;
        } else {
          adCount += 1;
        }
        frequencyCount += blogAds.value[adCount].frequency!.toInt();
       } 
   //  }
    //}
  }
  return blogsWithAds;
}

}