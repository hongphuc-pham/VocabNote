/// The IPA highlight editor's session state (F-022, `docs/UI-UX.md` §4.4).
library;

import 'package:meta/meta.dart';
// Riverpod 3 ships its own AsyncResult; ours is the Result-based one.
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;
import 'package:uuid/uuid.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/core/extensions/grapheme.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/value_objects/grapheme_range.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

part 'highlight_editor_controller.g.dart';

/// One editing session over one transcription.
///
/// **Nothing here is persisted.** `docs/UI-UX.md` §4.4 is explicit that the
/// whole session lives in memory with undo, and only *Done* writes — which is
/// also why the write is a whole-target replace rather than a set of inserts
/// and deletes.
@immutable
class HighlightEditorState {
  /// Creates a session state.
  const new({
    required this.ipa,
    required this.highlights,
    this.selection,
    this.canUndo = false,
    this.isLoaded = false,
  });

  /// The transcription being marked up, without slashes.
  final String ipa;

  /// The highlights as they currently stand in this session.
  final List<IpaHighlight> highlights;

  /// The run the user has selected, or null when nothing is selected.
  final GraphemeRange? selection;

  /// Whether there is a previous state to go back to.
  final bool canUndo;

  /// Whether the stored highlights have been seeded yet.
  ///
  /// Distinguishes "not loaded" from "the user deleted them all", which
  /// otherwise look identical and would let a late-arriving stream event wipe
  /// out an edit in progress.
  final bool isLoaded;

  /// The transcription split into grapheme clusters — one chip each.
  ///
  /// The editor deals **only** in indices into this list, never in code-unit
  /// offsets (RULES §21, ADR-006). That is what makes it impossible to split a
  /// tie bar off its base letter or orphan a combining diacritic.
  List<String> get chips => ipa.graphemeClusters;

  /// How many grapheme clusters there are.
  int get length => chips.length;

  /// The highlight covering [index], newest first — what a tap selects for
  /// editing rather than creating over the top of.
  IpaHighlight? highlightAt(int index) {
    IpaHighlight? found;
    for (final highlight in highlights) {
      if (highlight.range.contains(index)) found = highlight;
    }
    return found;
  }

  /// The selected symbols, e.g. `ʃ ɜː` — what a screen reader announces.
  ///
  /// Grapheme-safe by construction: the chips are already cluster-sized.
  String get selectionSymbols {
    final range = selection;
    if (range == null) return '';
    return chips.sublist(range.start, range.end).join(' ');
  }

  /// A copy with the given changes.
  HighlightEditorState copyWith({
    String? ipa,
    List<IpaHighlight>? highlights,
    GraphemeRange? selection,
    bool clearSelection = false,
    bool? canUndo,
    bool? isLoaded,
  }) => HighlightEditorState(
    ipa: ipa ?? this.ipa,
    highlights: highlights ?? this.highlights,
    selection: clearSelection ? null : (selection ?? this.selection),
    canUndo: canUndo ?? this.canUndo,
    isLoaded: isLoaded ?? this.isLoaded,
  );
}

/// Drives one pass through the highlight editor.
///
/// Undo covers the whole session and is a stack of previous highlight lists —
/// small enough that keeping every step costs nothing, and simple enough that
/// it cannot get out of step with the thing it is undoing.
@riverpod
class HighlightEditor extends _$HighlightEditor {
  /// Previous highlight lists, oldest last. Session-wide (`UI-UX.md` §4.4).
  final List<List<IpaHighlight>> _undo = <List<IpaHighlight>>[];

  static const Uuid _uuid = Uuid();

  /// Keyed on values only.
  ///
  /// The stored highlights are deliberately **not** a family argument. Riverpod
  /// identifies a family member by `==` on its arguments, and a `List` has
  /// identity equality — so passing one in would hand out a brand new
  /// controller, with an empty undo stack, on every rebuild. They arrive
  /// through [loadFrom] instead.
  @override
  HighlightEditorState build(
    String wordId,
    HighlightTarget target,
    String ipa,
  ) => HighlightEditorState(ipa: ipa, highlights: const <IpaHighlight>[]);

  /// Seeds the session from what is stored, once.
  ///
  /// Ignored after the first call: the screen watches a stream that re-emits
  /// whenever anything about the word changes, and re-seeding half way through
  /// would throw away the colours the user had just placed.
  void loadFrom(List<IpaHighlight> stored) {
    if (state.isLoaded) return;
    state = state.copyWith(
      // Only what belongs to this transcription and still fits it. A stale
      // range is dropped on the way in rather than painted onto the wrong
      // symbols (F-023).
      highlights: stored
          .where((highlight) => highlight.target == target)
          .where((highlight) => highlight.fits(ipa.graphemeLength))
          .toList(),
      isLoaded: true,
    );
  }

  /// Records the current highlights so the next change can be undone.
  void _pushUndo() {
    _undo.add(List<IpaHighlight>.unmodifiable(state.highlights));
  }

  /// Selects the single grapheme at [index].
  ///
  /// The start of every selection, whether the user goes on to drag or to tap
  /// a second chip.
  void selectAt(int index) {
    if (index < 0 || index >= state.length) return;
    state = state.copyWith(selection: GraphemeRange(index, index + 1));
  }

  /// Extends the selection to cover [index].
  ///
  /// Drives both the drag and the tap-a-second-chip path, so the two cannot
  /// disagree — `docs/UI-UX.md` §1 forbids an action that only a gesture can
  /// reach, and a pan is not available to a screen-reader user.
  ///
  /// Extending backwards past the anchor is allowed: the range is normalised
  /// so that start is always the lower index.
  void extendTo(int index) {
    final current = state.selection;
    if (current == null) {
      selectAt(index);
      return;
    }
    if (index < 0 || index >= state.length) return;

    // The anchor is whichever end the user did not just move.
    final anchor = index >= current.start ? current.start : current.end - 1;
    final start = index < anchor ? index : anchor;
    final end = (index > anchor ? index : anchor) + 1;
    state = state.copyWith(selection: GraphemeRange(start, end));
  }

  /// Drops the selection without changing anything.
  void clearSelection() => state = state.copyWith(clearSelection: true);

  /// Colours the current selection, or recolours [replacing] if given.
  ///
  /// Overlaps are allowed (`UI-UX.md` §4.4) — the newest wins visually and both
  /// show in the legend — so this never refuses because something is already
  /// there.
  void applyColor(IpaColorToken color, {String? label, String? replacing}) {
    final range = state.selection;
    if (range == null && replacing == null) return;

    _pushUndo();

    final trimmed = label?.trim();
    final cleaned = (trimmed == null || trimmed.isEmpty)
        ? null
        // Truncation rather than rejection: the field caps input at 40 anyway,
        // and losing what someone typed is worse than shortening it. Cut by
        // grapheme, so an accented letter never loses its diacritic.
        : trimmed.truncateGraphemes(IpaHighlight.maxLabelLength);

    final next = List<IpaHighlight>.of(state.highlights);

    if (replacing != null) {
      final index = next.indexWhere((highlight) => highlight.id == replacing);
      if (index >= 0) {
        next[index] = next[index].copyWith(color: color, label: cleaned);
        state = state.copyWith(
          highlights: next,
          canUndo: true,
          clearSelection: true,
        );
        return;
      }
    }

    next.add(
      IpaHighlight(
        id: _uuid.v4(),
        wordId: wordId,
        target: target,
        range: range!,
        color: color,
        createdAt: DateTime.now(),
        label: cleaned,
      ),
    );

    state = state.copyWith(
      highlights: next,
      canUndo: true,
      clearSelection: true,
    );
  }

  /// Removes one highlight.
  void removeHighlight(String id) {
    _pushUndo();
    state = state.copyWith(
      highlights: state.highlights
          .where((highlight) => highlight.id != id)
          .toList(),
      canUndo: true,
      clearSelection: true,
    );
  }

  /// Steps back one change. Session-wide, as far as the editor was opened.
  void undo() {
    if (_undo.isEmpty) return;
    final previous = _undo.removeLast();
    state = state.copyWith(
      highlights: List<IpaHighlight>.of(previous),
      canUndo: _undo.isNotEmpty,
      clearSelection: true,
    );
  }

  /// Writes the session to the database — what *Done* calls.
  ///
  /// One atomic replace scoped to this transcription, so a crash mid-save
  /// cannot leave half the user's colours behind and saving UK highlights
  /// never disturbs US ones.
  AsyncResult<void> save() => ref
      .read(wordRepositoryProvider)
      .replaceHighlights(
        wordId: wordId,
        target: target,
        highlights: state.highlights,
      );
}
