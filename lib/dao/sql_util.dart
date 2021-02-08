
import 'package:xml/xml.dart';

class Config {
  List<DataBase> databases;
}

class DataBase {
  String databaseName;

  int version;

  OnCreate onCreate;

  OnUpgrade onUpgrade;
}

class OnCreate {
  List<Table> tables;
}

class OnUpgrade {
  List<Table> tables;
}

class Table {
  String name;

  List<String> sql;
}

void main() {
  parseXml(content);
}

void parseXml(String xmlContent) {
  final document = XmlDocument.parse(xmlContent);
  var databases = document.findElements("database");
  Config db = Config();
  Map<String, List<dynamic>> map = {};
  databases.forEach((element) {
    print("element = $element");
    print("element.name = ${element.name}");
  });
}

String content = """
<?xml version="1.0" encoding="utf-8" ?>
<db-config>
    <database databaseName="test1" version="1">
        <onCreate>
            <table tableName="user">
                <sql>create table if not exists user(id int, name text);</sql>
            </table>
            <table tableName="table2">
                <sql>create table if not exists table2(id int, name text);</sql>
            </table>
        </onCreate>

    </database>

    <database databaseName="test1" version="2">
        <onCreate>
            <table tableName="user">
                <sql>create table if not exists user(id int, name text);</sql>
            </table>
            <table tableName="table2">
                <sql>create table if not exists table2(id int, name text);</sql>
            </table>
        </onCreate>
        <onUpgrade>
            <table tableName="user">
                <sql>ALTER TABLE user RENAME TO t_user;</sql>
                <sql>CREATE TABLE IF NOT EXISTS user(
                    id int primary key autoincrement,
                    name text,
                    age int
                    );</sql>
                <sql>INSERT INTO user SELECT * from t_user;</sql>
                <sql>DROP TABLE t_user</sql>
            </table>
        </onUpgrade>
    </database>
</db-config>
""";
