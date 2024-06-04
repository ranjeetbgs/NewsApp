class Users {
  String? id;
  String? name;
  String? email;
  String? password;
  String? apiToken;
  String? fbToken;
  String? phone;
  String? deviceToken;
  dynamic photo;
  bool? auth;
  bool? isPageHome;
  bool? isNewUser;
  String otp='';
  String? cpassword;
  String? langCode;
  String? loginFrom;
  Users();

  Users.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'] ?? '';
      email = jsonMap['email'] ?? '';
      phone = jsonMap['phone'] ?? '';
      apiToken = jsonMap['api_token'];
      fbToken = jsonMap['fb_token'] ?? '';
      otp = jsonMap['otp'] != null ? jsonMap['otp'].toString() : '';
      photo = jsonMap['photo'] ?? '';
      deviceToken = jsonMap['device_token'];
      isNewUser = jsonMap['is_new_user'];
      langCode = jsonMap['lang_code'];
      loginFrom = jsonMap['login_from'];
    } catch (e) {
      id = '';
      name = '';
      email = '';
      phone = '';
      apiToken = '';
      fbToken = '';
      photo = '';
      apiToken = '';
      deviceToken = '';
      isNewUser = false;
    }
  }
}

class SocialMedia {
  int? id;
  String? name;
  String? url;
  String? icon;
  String? iconBackgroundColor;
  String? iconTextColor;
  int? status;

  SocialMedia(
      {this.id,
      this.name,
      this.url,
      this.icon,
      this.iconBackgroundColor,
      this.iconTextColor,
      this.status
    });

  SocialMedia.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    url = json['url'];
    icon = json['icon'];
    iconBackgroundColor = json['icon_background_color'];
    iconTextColor = json['icon_text_color'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['url'] = url;
    data['icon'] = icon;
    data['icon_background_color'] = iconBackgroundColor;
    data['icon_text_color'] = iconTextColor;
    data['status'] = status;
    return data;
  }
}