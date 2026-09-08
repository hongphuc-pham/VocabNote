import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_note.freezed.dart';

/// One of the user's own timestamped comments on a word (F-003, F-044).
///
/// Notes are the user's writing and carry no attribution, ever. They are also
/// indexed for search, so a note is a first-class way to find a word again
/// (F-041).
@freezed
abstract class WordNote with _$WordNote {
  /// Creates a note.
  const factory({
    /// UUID v4.
    required String id,

    /// The word this note belongs to. Cascades on delete.
    required String wordId,

    /// What the user wrote.
    required String body,

    /// When it was written - shown as "3 Sep" on the detail screen.
    required DateTime createdAt,

    /// When it was last edited.
    required DateTime updatedAt,

    /// Pinned notes sort above the rest (M4).
    @Default(false) bool pinned,
  }) = _WordNote;

  const new _();

  /// Whether the note has been edited since it was written.
  ///
  /// Compared at whole-millisecond resolution because that is the storage
  /// precision; a note saved and never touched has identical timestamps.
  bool get isEdited => updatedAt.isAfter(createdAt);
}
