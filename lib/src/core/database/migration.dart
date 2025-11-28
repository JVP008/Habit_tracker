import 'package:sqflite/sqflite.dart';

typedef MigrationCallback = Future<void> Function(
  Database db,
  int fromVersion,
  int toVersion,
);

class Migration {
  const Migration(this.startVersion, this.endVersion, this.migrate);

  final int startVersion;
  final int endVersion;
  final MigrationCallback migrate;
}

Future<Database> openDatabaseWithMigration(
  String path,
  int version,
  List<Migration> migrations, {
  OnDatabaseCreateFn? onCreate,
}) async {
  return openDatabase(
    path,
    version: version,
    onCreate: onCreate,
    onUpgrade: (db, oldVersion, newVersion) async {
      for (final migration in migrations) {
        if (migration.startVersion >= oldVersion &&
            migration.endVersion <= newVersion) {
          await migration.migrate(db, migration.startVersion, migration.endVersion);
        }
      }
    },
  );
}
