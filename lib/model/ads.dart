
class BlogAdModel {
  int? id;
  String? title;
  int? frequency;
  int? order;
  String? startDate;
  String? endDate;
  String? mediaType;
  String? media;
  String? videoUrl;
  String? sourceName;
  String? sourceLink;
  int? status;
  String? createdAt;

  BlogAdModel(
      {this.id,
      this.title,
      this.frequency,
      this.order,
      this.startDate,
      this.endDate,
      this.mediaType,
      this.media,
      this.videoUrl,
      this.sourceName,
      this.sourceLink,
      this.status,
      this.createdAt,
    });

  BlogAdModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    frequency = json['frequency'];
    order = json['order'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    mediaType = json['media_type'];
    media = json['media'];
    videoUrl = json['video_url'];
    sourceName = json['source_name'];
    sourceLink = json['source_link'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['title'] = title;
    data['frequency'] = frequency;
    data['order'] = order;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['media_type'] = mediaType;
    data['media'] = media;
    data['video_url'] = videoUrl;
    data['source_name'] = sourceName;
    data['source_link'] = sourceLink;
    data['status'] = status;
    data['created_at'] = createdAt;
    return data;
  }
}