import 'package:json_annotation/json_annotation.dart';

///
/// [className]  think_flutter
/// [author]     Administrator
/// [date]       2021/1/25

part 'User.g.dart';

@JsonSerializable()
class User {

  final String name;
  final String email;

  User(this.name, this.email)

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

}
