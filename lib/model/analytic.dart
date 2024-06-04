class AnalyticData {
  String? type;
  int? count;
  List<int>? blogIds;
  List<BlogTime>? blogs;
  DateTime? startTime,endTime;

  AnalyticData({this.type, this.count, this.blogIds});

  AnalyticData.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    count = json['count'];
    blogIds = json['blog_ids'].cast<int>();
    blogs = json['blogs'];
  }

  Map<String, dynamic> toJson() {

    final Map<String, dynamic> data =  <String, dynamic>{};
   if (data['type'] == 'app_spent_time') {
    
    data['type'] = type;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    if (blogs != null) {
      data['blogs'] = blogs!.map((v) => v.toJson()).toList();
    }
   
   }else if (data['type'] == 'blog_spent_time') {
    
    data['type'] = type;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
   
   } else {
    
    data['type'] = type;
    data['count'] = count;
    data['blog_ids'] = blogIds;
    if (blogs != null) {
      data['blogs'] =
          blogs!.map((v) => v.toJson()).toList();
    }
   }
    return data;
  }
}


class  BlogTime{
   
   BlogTime ({
      this.id,
      this.startTime,
      this.endTime
   });

DateTime? endTime,startTime;
int? id;

BlogTime.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

Map<String, dynamic> toJson() {
  final Map<String, dynamic> data =  <String, dynamic>{};
  
    data["id"] = id;
    data["start_time"] = startTime;
    data["end_time"] = endTime;
  
  return data;
}

}