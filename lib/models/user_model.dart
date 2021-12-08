class UserModel {
  UserModel({
    this.name,
    this.email,
    this.image,
  });

  UserModel.fromJson(dynamic json) {
    name = json['name'];
    email = json['email'];
    image = json['image'];
  }
  String? name;
  String? email;
  String? image;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['email'] = email;
    map['image'] = image;
    return map;
  }
}
