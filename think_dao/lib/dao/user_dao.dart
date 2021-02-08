import 'base_bean.dart';
import 'base_dao.dart';

class UserDao extends BaseDao<UserBean> {
  static const TABLE_NAME = "user";

  static const CREATE_TABLE = """
    CREATE TABLE IF NOT EXISTS $TABLE_NAME(
      id int primary key autoincrement,
      name text,
      age int
    );
  """;

  @override
  String get tableName => TABLE_NAME;
}
