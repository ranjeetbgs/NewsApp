class CmsModel {
  int? id;
  String? pageName;
  String? title;
  String? image;
  String? description;

  CmsModel(
      {this.id,
      this.pageName,
      this.title,
      this.image,
      this.description,
      });

  CmsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pageName = json['page_name'];
    title = json['title'];
    image = json['image'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['page_name'] = pageName;
    data['title'] = title;
    data['image'] = image;
    data['description'] = description;
    return data;
  }
}