// Refuses to build if migration code contains a destructive pattern.
//
// `docs/DATABASE.md` §3.8 and `docs/RULES.md` §7: never `deleteDatabase()`,
// never drop-and-recreate, never "if migration fails, start fresh". There is no
// backend to restore from, so a wiped database is a permanently lost user.
//
// Run locally with:
//
//   dart run tool/check_migration_safety.dart
//
// CI runs the same command on every push. This is a grep, not a proof - it
// cannot catch a cleverly named helper that deletes everything. It is here to
// stop the obvious mistake, which is the one that actually gets made at 1am
// while chasing a migration bug.
import 'dart:io';

/// Files that define or run migrations. Deliberately narrow: a grep over the
/// whole repository would drown in false positives from tests and tooling.
const List<String> _migrationPaths = <String>[
  'lib/data/db',
  'lib/bootstrap.dart',
];

/// Patterns that must never appear in migration code, with the reason shown
/// when one does.
final List<({RegExp pattern, String label, String why})> _forbidden = [
  (
    pattern: RegExp(r'deleteDatabase\s*\('),
    label: 'deleteDatabase(',
    why: "deletes the user's database. There is no backend to restore from.",
  ),
  (
    pattern: RegExp(r'\bdropTable\s*\('),
    label: 'dropTable(',
    why: 'drops a table. Schema changes are additive only (DATABASE.md §3.2).',
  ),
  (
    pattern: RegExp('DROP TABLE(?! IF EXISTS words_fts)', caseSensitive: false),
    label: 'DROP TABLE',
    why:
        'drops a table. Only the derived words_fts index may be dropped, and '
        'only through rebuildFtsIndex().',
  ),
  (
    pattern: RegExp(r'\brecreate\b', caseSensitive: false),
    label: 'recreate',
    why: 'suggests drop-and-recreate. Migrate the existing table instead.',
  ),
  (
    pattern: RegExp(r'if\s*\(\s*from\s*!=\s*to\s*\)'),
    label: 'if (from != to)',
    why: 'is the shape of "on any version change, start fresh".',
  ),
  (
    pattern: RegExp(r'\bdeleteAll\s*\(\s*\)'),
    label: 'deleteAll()',
    why:
        'empties a table wholesale. Delete by predicate, and only when the '
        'user asked or the 30-day retention has passed.',
  ),
];

/// Lines allowed to mention a forbidden pattern, because they are the
/// documentation of the rule rather than a breach of it.
bool _isExempt(String line) {
  final trimmed = line.trimLeft();
  // Comments explaining the rule are the whole point of the rule being
  // documented in the code that enforces it.
  if (trimmed.startsWith('//') || trimmed.startsWith('///')) return true;
  // The one sanctioned drop: the derived full-text index.
  if (trimmed.contains('DROP TABLE IF EXISTS words_fts')) return true;
  if (trimmed.contains('DROP TRIGGER IF EXISTS')) return true;
  return false;
}

void main() {
  final violations = <String>[];
  var scanned = 0;

  for (final path in _migrationPaths) {
    final entity = FileSystemEntity.typeSync(path);
    final files = <File>[
      if (entity == FileSystemEntityType.file) File(path),
      if (entity == FileSystemEntityType.directory)
        ...Directory(path)
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart')),
    ];

    for (final file in files) {
      // Generated code follows drift's conventions, not ours, and is verified
      // by the migration tests instead.
      if (file.path.endsWith('.g.dart')) continue;
      if (file.path.replaceAll(r'\', '/').endsWith('schema_versions.dart')) {
        continue;
      }

      scanned++;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (_isExempt(line)) continue;

        for (final rule in _forbidden) {
          if (rule.pattern.hasMatch(line)) {
            violations.add(
              '${file.path.replaceAll(r'\', '/')}:${i + 1}\n'
              '    ${line.trim()}\n'
              '    -> "${rule.label}" ${rule.why}',
            );
          }
        }
      }
    }
  }

  stdout.writeln('Scanned $scanned migration-related files.');

  if (violations.isEmpty) {
    stdout.writeln('No destructive migration patterns found.');
    return;
  }

  stderr
    ..writeln('\nDestructive migration patterns found:\n')
    ..writeln(violations.join('\n\n'))
    ..writeln(
      '\nDATABASE.md §3.8: upgrading must never destroy user data. '
      'If you believe an exception is warranted, it is not.',
    );
  exit(1);
}
