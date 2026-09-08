import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';
import 'package:vocabnote/domain/value_objects/ipa.dart';
import 'package:vocabnote/domain/value_objects/storage_enum.dart';

part 'word.freezed.dart';

/// Where a word's content came from (`words.source`).
///
/// Attribution is per word, never assumed globally (`docs/RULES.md` §16):
/// a user who typed their own definition over an API one owes nobody a credit
/// for their own writing.
enum WordSource implements StorageEnum {
  /// The user typed it. Carries no attribution, because it is theirs.
  manual('manual'),

  /// Accepted from FreeDictionaryAPI.com (Wiktionary, CC BY-SA 4.0).
  api('api'),

  /// Filled from the bundled CMUdict-derived asset. US only.
  offline('offline'),

  /// Some fields typed, some accepted from a source.
  mixed('mixed');

  new(this.storageValue);

  /// The exact string written to `words.source`.
  ///
  /// Pinned here rather than derived from [name] so renaming the Dart constant
  /// can never rewrite what is already on disk.
  @override
  final String storageValue;

  /// Parses a stored value, falling back to [WordSource.manual].
  ///
  /// Never throws: a database written by a newer build may carry a source this
  /// one has not heard of, and that must not stop the word from being shown.
  /// `manual` is the safe fallback because it claims no attribution.
  static WordSource fromStorage(String value) {
    for (final source in WordSource.values) {
      if (source.storageValue == value) return source;
    }
    return WordSource.manual;
  }

  /// Whether a word from this source must display an attribution line.
  bool get requiresAttribution =>
      this == WordSource.api ||
      this == WordSource.offline ||
      this == WordSource.mixed;
}

/// A word the user is studying.
///
/// The aggregate root: notes, highlights, list membership and the study card
/// all hang off `words.id` and cascade when it is finally purged.
@freezed
abstract class Word with _$Word {
  /// Creates a word.
  const factory({
    /// UUID v4, so exports from two devices can be merged without collisions.
    required String id,

    /// What the user typed, plus the normalised form used for dedupe.
    required Headword headword,

    /// When the row was first written.
    required DateTime createdAt,

    /// When it last changed. Import merge resolves conflicts on this
    /// (`DATABASE.md` §5: newer `updated_at` wins).
    required DateTime updatedAt,

    /// Free text: noun, verb, adjective, or whatever the user prefers.
    String? partOfSpeech,

    /// British transcription, without slashes.
    Ipa? ipaUk,

    /// American transcription, without slashes.
    Ipa? ipaUs,

    /// What the word means.
    String? definition,

    /// A sentence using it.
    String? example,

    /// Where the content came from.
    @Default(WordSource.manual) WordSource source,

    /// The credit line and source URL, when one is owed.
    String? sourceAttribution,

    /// Starred by the user (F-044).
    @Default(false) bool isFavourite,

    /// Hidden from lists but kept in stats (F-045).
    @Default(false) bool isArchived,

    /// Set when soft-deleted; purged 30 days later (F-008, RULES §10).
    DateTime? deletedAt,
  }) = _Word;

  const new _();

  /// True once the user has deleted this word but before it is purged.
  bool get isDeleted => deletedAt != null;

  /// True when neither transcription has been filled in - the "No IPA yet"
  /// filter chip (F-043).
  bool get hasNoIpa => ipaUk == null && ipaUs == null;

  /// The transcription to show and speak by default.
  ///
  /// Prefers UK, because the offline fallback can only ever supply US, so a
  /// present UK value is one the user or the dictionary deliberately provided.
  Ipa? get preferredIpa => ipaUk ?? ipaUs;
}
