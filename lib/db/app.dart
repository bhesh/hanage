import 'dart:io';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const int dbVersion = 1;

DatabaseFactory get dbFactory => (Platform.isLinux || Platform.isWindows)
    ? databaseFactoryFfi
    : databaseFactory;

class AppDatabase {
  static Database? _settingsDatabase;

  static Future initialize() async {
    sqfliteFfiInit();
    if (_settingsDatabase == null) await _initSettingsDatabase();
  }

  static Future<Database> get settingsDatabase async =>
      _settingsDatabase ?? await _initSettingsDatabase();

  static Future<Database> _initSettingsDatabase() async {
    final Directory directory = await getApplicationSupportDirectory();
    final dbPath = join(directory.path, 'settings.db');
    print('Settings database path: $dbPath');
    _settingsDatabase = await dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        onCreate: (db, version) async => await createSettingsDatabase(db),
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < dbVersion) await createSettingsDatabase(db);
        },
        version: dbVersion,
      ),
    );
    return _settingsDatabase!;
  }

  static Future createSettingsDatabase(Database db) async {
    var batch = db.batch();
    batch.execute('DROP TABLE IF EXISTS settings');
    batch.execute(
      '''
      CREATE TABLE settings (
          id INTEGER PRIMARY KEY,
          value INTEGER NOT NULL
      )
      ''',
    );
    batch.insert('settings', {'id': 1, 'value': 11});
    batch.insert('settings', {'id': 2, 'value': 0});
    await batch.commit(noResult: true);
  }
}
