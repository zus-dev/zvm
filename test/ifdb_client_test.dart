import 'package:mysql1/mysql1.dart';
import 'package:test/test.dart';

void main() {
  var settings = ConnectionSettings(
    host: '172.17.0.2',
    port: 3306,
    user: 'root',
    password: 'my-secret-pw',
    db: 'ifdb',
  );
  MySqlConnection conn;

  setUp(() async {
    conn = await MySqlConnection.connect(settings);
  });

  tearDown(() {
    conn.close();
  });

  test("IFDB MySQL Data", () async {
    final query = '''
    select g.id, g.title, g.coverart, l.url
    from games as g 
    inner join gamelinks as l 
      where g.id = l.gameid and l.url like '%games/zcode/%' and (l.url like '%z_' or l.url like '%zblorb') 
    limit 10;''';
    var results = await conn.query(query);
    for (var row in results) {
      print(row);
    }
    expect(conn, isNotNull);
  });

  test("IFDB Genre", () async {
    final query = "select distinct genre from games;";
    var result = await conn.query(query);
    for (var row in result) {
      print(row);
    }
  });
}
