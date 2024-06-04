
class Language {
  String? name;
  int? id;
  String? language,pos;

  Language({this.name, this.id,this.language});

  Language.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    language = json['code'];
    pos = json['position'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['position'] = pos;
    data['name'] = name;
    data['code'] = language;
    return data;
  }

  List<Object> get props => [id.toString(),name.toString(), language.toString(),pos.toString()];
  bool get stringify => false;
}
