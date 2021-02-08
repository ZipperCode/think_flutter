abstract class BaseBean {
  int id;

  BaseBean({this.id});

  Map<String, dynamic> toMap();
}

class UserBean extends BaseBean {
  String name;

  int age;

  UserBean({int id, this.name, this.age}) : super(id: id);

  @override
  Map<String, dynamic> toMap() {
    return {'id': id, "name": name, "age": age};
  }

  static UserBean toBean(Map<String, dynamic> map) {
    return UserBean(id: map['id'], name: map['name'], age: map['age']);
  }
}
