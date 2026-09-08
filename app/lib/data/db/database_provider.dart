import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/data/db/app_database.dart';

part 'database_provider.g.dart';

/// The open database.
///
/// Has no default: `bootstrap.dart` opens the database (taking a backup and
/// running migrations first) and overrides this provider with the result.
/// Reading it without that override is a programming error, and throwing says
/// so immediately rather than quietly opening a second, unmigrated database
/// somewhere unexpected.
///
/// Tests override it with `AppDatabase.memory()`.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden in bootstrap() or in a test.',
  );
}
