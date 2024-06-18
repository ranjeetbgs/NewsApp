import 'dart:convert';

import 'package:incite/api_controller/manage_local.dart';

import '../model/blog.dart';
import '../urls/url.dart';

class BlogListHolder {
  DataModel _list = DataModel();
  BlogType blogType = BlogType.feed;
  int _index = 0;

  int getIndex() => _index;
  BlogType getBlogType() => blogType;
  DataModel getList() => _list;

  void setIndex(int index) {
    _index = index;
  }

  void setBlogType(BlogType list) {
    blogType = list;
  }

  void setList(DataModel list) {
    _list = list;
    // saveToLocal();
  }

  // saveToLocal() async {
  //   for (var e in _list.blogs) {
  //     final item = "${Urls.baseUrl}blog-detail/${e.id}";
  //     await ManageLocalData.saveToLocal(key: item, value: jsonEncode(e.toJson()));
  //   }
  // }

   void updateList(DataModel list) {
    _list.currentPage = list.currentPage;
    _list.firstPageUrl = list.firstPageUrl;
    _list.lastPageUrl = list.lastPageUrl;
    _list.nextPageUrl = list.nextPageUrl;
    _list.to = list.to;
    _list.prevPageUrl = list.prevPageUrl;
    _list.lastPage = list.lastPage;
    _list.from = list.from;

    _list.blogs.addAll(list.blogs);
  }


  void clearList() {
    _list = DataModel();
  }
}

BlogListHolder blogListHolder = BlogListHolder();
BlogListHolder blogListHolder2 = BlogListHolder();

enum BlogType{
  feed,
  allnews,
  featured,
  category,
  bookmarks,
  search
}