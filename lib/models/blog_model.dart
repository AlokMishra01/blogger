class BlogModel {
  BlogModel({
    this.image,
    this.description,
    this.title,
  });

  BlogModel.fromJson(dynamic json) {
    image = json['image'];
    description = json['description'];
    title = json['title'];
  }
  String? image;
  String? description;
  String? title;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['image'] = image;
    map['description'] = description;
    map['title'] = title;
    return map;
  }
}
