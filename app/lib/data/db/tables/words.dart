import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/converters/converters.dart';

/// `words` - the aggregate root (`docs/DATABASE.md` §2).
///
/// Everything else hangs off [Words.id] and cascades from it. Deletion is soft
/// ([Words.deletedAt]); rows are only really removed by the 30-day purge
/// (F-008, `docs/RULES.md` §10).
// docs/DATABASE.md section 2 names both of these explicitly.
@TableIndex(name: 'idx_words_normalized', columns: {#headwordNormalized})
@TableIndex.sql('CREATE INDEX idx_words_updated ON words (updated_at DESC);')
@DataClassName('WordRow')
class Words extends Table {
  /// UUID v4, so two devices' exports can be merged without collisions.
  TextColumn get id => text()();

  /// Exactly as the user typed it.
  TextColumn get headword => text()();

  /// Lowercased and whitespace-collapsed, for dedupe (F-001) and search.
  TextColumn get headwordNormalized => text().named('headword_normalized')();

  /// Free text: noun, verb, or whatever the user prefers.
  TextColumn get partOfSpeech => text().named('part_of_speech').nullable()();

  /// British transcription, without slashes.
  TextColumn get ipaUk => text().named('ipa_uk').nullable()();

  /// American transcription, without slashes.
  TextColumn get ipaUs => text().named('ipa_us').nullable()();

  /// What the word means.
  TextColumn get definition => text().nullable()();

  /// A sentence using it.
  TextColumn get example => text().nullable()();

  /// `manual` | `api` | `offline` | `mixed`.
  TextColumn get source =>
      text().map(wordSourceConverter).withDefault(const Constant('manual'))();

  /// The credit line and source URL, when one is owed (RULES §16).
  TextColumn get sourceAttribution =>
      text().named('source_attribution').nullable()();

  /// Starred by the user (F-044).
  BoolColumn get isFavourite =>
      boolean().named('is_favourite').withDefault(const Constant(false))();

  /// Hidden from lists but kept in stats (F-045).
  BoolColumn get isArchived =>
      boolean().named('is_archived').withDefault(const Constant(false))();

  /// Epoch milliseconds UTC.
  IntColumn get createdAt =>
      integer().named('created_at').map(epochMillisConverter)();

  /// Epoch milliseconds UTC. Import merge resolves conflicts on this.
  IntColumn get updatedAt =>
      integer().named('updated_at').map(epochMillisConverter)();

  /// Set on soft delete; purged 30 days later.
  IntColumn get deletedAt => integer()
      .named('deleted_at')
      .map(nullableEpochMillisConverter)
      .nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
