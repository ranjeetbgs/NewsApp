class LiveNews {
  int? id;
  String? image;
  String? companyName;
  String? url;
  String? createdAt;
  String? updatedAt;

  LiveNews({
      this.id,
      this.image,
      this.companyName,
      this.url,
      this.createdAt,
      this.updatedAt,
  });

  LiveNews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    companyName = json['company_name'];
    url = json['url'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['company_name'] = companyName;
    data['url'] = url;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class ENews {
  int? id;
  String? image;
  String? name;
  dynamic pdf;
  String? createdAt;
  String? updatedAt;

  ENews(
      {this.id,
      this.image,
      this.name,
      this.pdf,
      this.createdAt,
      this.updatedAt,
    });

  ENews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'];
    pdf = json['pdf'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['name'] = name;
    data['pdf'] = pdf;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

