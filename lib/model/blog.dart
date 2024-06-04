import 'dart:typed_data';

import 'package:incite/api_controller/user_controller.dart';

import 'home.dart';

class DataCollection {
 DataCollection({
      this.success,
      this.categories,
  });

bool? success;
List<Category>? categories;


  DataCollection.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
        categories = <Category>[];
      json['data'].forEach((v) {
        categories!.add(Category.fromJson(v));
      });
    }
  }
}



class Category{
    Category({
      this.id,
      this.name,
      this.image,
      this.color,
      this.data,
      this.isFeed,
      this.createdAt,
      this.isFeatured,
      this.updatedAt,
      this.parentId
    });

  String? name,image,color;
  int? id,parentId;
  int? isFeatured;
  bool? isFeed;
  DataModel? data;
  DateTime? createdAt,updatedAt;

    factory Category.fromJson(Map<String, dynamic> map){
     var blogs = map['blogs'];
     blogs['category_color'] = map['color'];
     blogs['category_name'] = map['name'];
    return Category(
      id:map['id'] ?? 0,
      name: map['name'],
      parentId: map["parent_id"],
      isFeatured: map['is_featured'] ?? 0, 
      image: map['image'] ?? '',
      color: map['color'] ?? '#000000',
      isFeed : map['is_feed'],
      data: DataModel.fromJson(blogs),
    );
  }


@override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          parentId == other.parentId;

}

class QuestionModel {
  int? id;
  String? question;
  List<PollOption>? options;

  QuestionModel({
      this.id,
      this.question,
      this.options
  });

  QuestionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    if (json['options'] != null) {
      options = <PollOption>[];
      json['options'].forEach((v) {
        options!.add( PollOption.fromJSON(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['question'] = question;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class Blog {
  int? id;
  String? type;
  String? title;
  String? description;
  String? sourceName;
  String? sourceLink;
  String? voice;
  String? accentCode;
  String? videoUrl;
  int? isVotingEnable;
  DateTime? scheduleDate;
  String? createdAt;
  String? updatedAt;
  String? backgroundImage;
  bool? isFeed;
  int? isVote;
  int? isFeatured;
  String? categoryColor;
  int? isBookmark;
  int? isUserViewed;
  List? visibilities;
  int? frequency;
  String? mediaType,media,imageUrl;
  QuestionModel? question;
  List? images;
  PostType? postType;
  List<BlogSubCategory>? blogSubCategory;
  String? categoryName;
  Uint8List? audioData; 
 

  Blog({
      this.id,
      this.frequency,
      this.type,
      this.title,
      this.description,
      this.sourceName,
      this.sourceLink,
      this.voice,
      this.isFeatured,
      this.accentCode,
      this.videoUrl,
      this.isVotingEnable,
      this.scheduleDate,
      this.createdAt,
      this.updatedAt,
      this.postType,
      this.backgroundImage,
      this.isFeed,
      this.categoryName,
      this.isVote,
      this.isBookmark,
      this.isUserViewed,
      this.visibilities,
      this.question,
      this.images,
      this.categoryColor,
      this.mediaType,
      this.media,
      this.audioData,
      this.blogSubCategory
  });


  Blog.fromJson(Map<String, dynamic> json,{isNotification = false,isCache = false,isAds=false}) {
    id = json['id'] ?? 0;
    type = json['type']?? 'post';
    title = json['title']??'';
    description =  isAds==true ? '' : json['description'] ?? '';
    sourceName =  json['source_name'];
    sourceLink = json['source_link']??'';
    isFeatured = json['is_featured'];
    if (allSettings.value.isVoiceEnabled == true && allSettings.value.googleApikey != null) {
         audioData = json['audioData'];
    }
    voice = isAds==true ? '' : json['voice']??'';
    imageUrl = isAds==true ? json["image_url"] ?? '': null;
    mediaType = isAds==true ?json["media_type"] ?? '': null;
    media  = isAds==true ? json["media"] ?? '': null;
    accentCode = isAds==true ? '' :json['accent_code']??'en';
    frequency = isAds==true ? json['frequency'] : 0;
    videoUrl =isAds==true ? '' : json['video_url']?? '';
    categoryColor = isNotification ? json['blog_category'] != null ? json['blog_category'][0]['category']['color'] : '' : json['category_color'] ?? "#000000" ;
    categoryName = isNotification ?  json['blog_category'] != null ? json['blog_category'][0]['category']['name'] : '' : json['category_name'] ?? "";
    isVotingEnable =isAds==true ? 0 :json['is_voting_enable'] ?? 0;
    postType = isAds ? PostType.ads : getPostType(json['type']) ;
    scheduleDate = isAds==true ? DateTime.now() : json['schedule_date'] != null ?  json['schedule_date'] != '' ? DateTime.parse(json['schedule_date']) : DateTime.now() : DateTime.now();
    createdAt = json['created_at'] ?? '';
    updatedAt = json['updated_at'] ?? '';
    backgroundImage = isAds==true ? '' : json['background_image'] ?? '';
    isFeed =  json['is_feed'] ?? false ;
    isVote = isAds==true ? 0 :json['is_vote'] ?? 0;
    isBookmark = isAds==true ? 0 : json['is_bookmark'] ?? 0;
    isUserViewed = isAds==true ? 0 :json['is_user_viewed'] ?? 0;
    visibilities = isAds==true ? [] : json['visibilities'] ?? [];
    question = isAds==true ? null : json['question'] != null? QuestionModel.fromJson(json['question']) : null;
    images = isAds==true ? [] :json['images'];
     if (json['blog_sub_category'] != []) {
    if (json.containsKey('blog_sub_category')) {
      blogSubCategory = [];
      json['blog_sub_category'].forEach((v) {
        if(v['category'] != null) {
         blogSubCategory!.add( BlogSubCategory.fromJson(v['category']));
        }
     
      });
    }
   }
  }

@override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Blog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description;

  PostType getPostType(data){
    switch (data) {
      case 'ads':
        return PostType.ads;
      case 'post':
        return PostType.image;
      case 'video':
         return PostType.video;
      case 'quote':
         return PostType.quote;
      default:
        return PostType.image;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['title'] = title;
    data['description'] = description;
    data['source_name'] = sourceName;
    data['source_link'] = sourceLink;
    data['voice'] = voice;
    data['accent_code'] = accentCode;
    data['video_url'] = videoUrl;
    if (allSettings.value.isVoiceEnabled == true && allSettings.value.googleApikey != '') {
      data["audioData"] = audioData;
    }
    data['is_voting_enable'] = isVotingEnable;
    data['schedule_date'] = scheduleDate != null ? scheduleDate!.toIso8601String() : null;
    data['created_at'] = createdAt;
    data["image_url"] = imageUrl;
    data["media_type"] = mediaType;
    data["media"] = media;
    data['category_color'] = categoryColor;
    data['category_name'] = categoryName;
    data['updated_at'] = updatedAt;
    data['background_image'] = backgroundImage;
    data['is_feed'] = isFeed;
    data['is_vote'] = isVote;
    data['is_bookmark'] = isBookmark;
    data['is_user_viewed'] = isUserViewed;
    data['visibilities'] = visibilities;
    data['question'] = question;
    data['images'] = images;
    if (blogSubCategory != null) {
      data['blog_sub_category'] =
          blogSubCategory!.map((v) => v.toJson()).toList();
    }
    if (question != null) {
      data['question'] = question!.toJson();
    }
    return data;
  }
  
  @override
  int get hashCode => id.hashCode;
  
}

class PollOption{
  PollOption({
     this.id,
     this.option,
     this.percentage
  });

  String? option;
  dynamic percentage;
  int? id;
  
  PollOption.fromJSON(Map<String,dynamic> map){
    id = map['id'];
    option= map['option'];
    percentage= map['percentage'];
  }

  Map toJson(){
   return {
       "id": id,
       "option": option,
       "percentage" : percentage
    };
  }

}

class DataModel {
   DataModel({
       this.currentPage,
       this.nextPageUrl,
       this.prevPageUrl,
       this.from,
       this.path,
       this.perPage,
       this.to,
       this.total,
       this.lastPage,
       this.blogs= const [],
       this.firstPageUrl,
       this.lastPageUrl
    });
     String? nextPageUrl,prevPageUrl,path,firstPageUrl,lastPageUrl;
     List<Blog> blogs=[];
     int? to,from,total,lastPage,perPage,currentPage;


  Map toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['current_page'] = currentPage;
    if( blogs.isNotEmpty ){
       data['data'] = blogs.map((e) => e.toJson()).toList();
    }
    data['to'] = to;
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;
    data['next_page_url']= nextPageUrl ;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url']=prevPageUrl ;
    data['total']=total;

    return data;
  }

   DataModel.fromJson(Map<String, dynamic> json,{bool isSearch = false}) {
    var cat;
    currentPage =json.containsKey('current_page') ?  json['current_page'] : 0;
    if (json['data'] != []) {
      blogs = <Blog>[];
      json['data'].forEach((v) {
        print(v['blog_category'].toString());
         if (v.containsKey('blog_category')) {
            if (v['blog_category'] != null) {
           v['blog_category'].forEach((e){
               cat = e['category'];
           });
             v["category_color"] = cat['color']; 
              v["category_name"] = cat['name']; 
            }
         }else{
        if (json.containsKey('category_color')) {
              v["category_color"] = json['category_color']; 
              v["category_name"] = json['category_name']; 
          }
         }
        blogs.add(Blog.fromJson(v));
      });
      // blogs.sort((a, b) => b.scheduleDate!.compareTo(a.scheduleDate as DateTime));
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
    
  }

}

class BlogSubCategory {
  int? id;
  int? parentId;
  String? name;
  String? slug;
  String? image;
  String? color;
  int? order;
  int? status;
  int? isFeatured;
  String? createdAt;

  BlogSubCategory(
      {this.id,
      this.parentId,
      this.name,
      this.slug,
      this.image,
      this.color,
      this.order,
      this.status,
      this.isFeatured,
      this.createdAt,
    });

  BlogSubCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    name = json['name'];
    slug = json['slug'];
    image = json['image'];
    color = json['color'];
    order = json['order'];
    status = json['status'];
    isFeatured = json['is_featured'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['parent_id'] = parentId;
    data['name'] = name;
    data['slug'] = slug;
    data['image'] = image;
    data['color'] = color;
    data['order'] = order;
    data['status'] = status;
    data['is_featured'] = isFeatured;
    data['created_at'] = createdAt;
    return data;
  }
}