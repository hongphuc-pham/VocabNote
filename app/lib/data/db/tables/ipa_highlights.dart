import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/converters/converters.dart';
import 'package:vocabnote/data/db/tables/words.dart';

/// `ipa_highlights` - the signature feature (F-022).
///
/// [IpaHighlights.startGrapheme] and [IpaHighlights.endGrapheme] are
/// **grapheme-cluster** offsets over the target transcription, never code
/// units (ADR-006). `end` is exclusive.
///
/// The two offsets are separate INTEGER columns, exactly as
/// `docs/DATABASE.md` §2 specifies, rather than one serialised range: they stay
/// queryable, and a range is reassembled into a `GraphemeRange` by the DAO.
// Highlights are always fetched for one word, usually for one target.
@TableIndex(name: 'idx_highlights_word', columns: {#wordId, #target})
@DataClassName('IpaHighlightRow')
class IpaHighlights extends Table {
  /// UUID v4.
  TextColumn get id => text()();

  /// Owning word. Cascades.
  TextColumn get wordId => text()
      .named('word_id')
      .references(Words, #id, onDelete: KeyAction.cascade)();

  /// `ipa_uk` | `ipa_us` - which transcription this marks.
  TextColumn get target => text().map(highlightTargetConverter)();

  /// First grapheme cluster, inclusive.
  IntColumn get startGrapheme => integer().named('start_grapheme')();

  /// One past the last grapheme cluster, exclusive.
  IntColumn get endGrapheme => integer().named('end_grapheme')();

  /// One of the five palette tokens, by name - never a hex value, so a theme
  /// change repaints existing highlights.
  TextColumn get colorToken =>
      text().named('color_token').map(ipaColorTokenConverter)();

  /// The user's label, e.g. "I say /s/ here". Up to 40 characters.
  TextColumn get label => text().nullable()();

  /// Epoch milliseconds UTC.
  IntColumn get createdAt =>
      integer().named('created_at').map(epochMillisConverter)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => <String>[
    // A zero-width or reversed run is never a real highlight. Enforced in
    // the database as well as in GraphemeRange, because a bad row here
    // corrupts the feature the whole app is built around.
    'CHECK (end_grapheme > start_grapheme)',
    'CHECK (start_grapheme >= 0)',
  ];
}
