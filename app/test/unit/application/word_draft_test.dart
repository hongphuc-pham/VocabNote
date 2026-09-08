import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/application/words/word_draft.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_suggestion.dart';
import 'package:vocabnote/presentation/words/ipa_keyboard_row.dart';

/// The add/edit form's logic (F-001, F-004, `docs/RULES.md` §16).
///
/// Two promises live here and are easy to break by accident: a look-up chip
/// never silently overwrites what the user typed, and attribution is owed only
/// on what was actually taken.
void main() {
  const results = WordSuggestions(
    headword: 'cough',
    source: WordSource.api,
    attribution: WordSuggestions.wiktionaryAttribution,
    sourceUrl: 'https://en.wiktionary.org/wiki/cough',
  );

  FieldSuggestion suggestion(
    SuggestionField field,
    String value, {
    WordSource source = WordSource.api,
  }) => FieldSuggestion(field: field, value: value, source: source);

  group('saving is gated on the headword', () {
    test('an empty draft cannot be saved', () {
      expect(const WordDraft().canSave, isFalse);
      expect(const WordDraft(headword: '   ').canSave, isFalse);
    });

    test('a headword is the only requirement', () {
      expect(const WordDraft(headword: 'cough').canSave, isTrue);
    });

    test('the headword is trimmed and normalised on save', () {
      final word = const WordDraft(headword: '  Cough  ')
          .toWord(id: 'w1', now: DateTime.utc(2026, 9, 9));

      expect(word.headword.value, 'Cough');
      expect(word.headword.normalized, 'cough');
    });
  });

  group('a chip never silently overwrites typed text', () {
    test('filling an empty field is not an overwrite', () {
      const draft = WordDraft(headword: 'cough');
      expect(draft.wouldOverwrite(SuggestionField.ipaUk, 'kɒf'), isFalse);
    });

    test('replacing typed text IS an overwrite', () {
      const draft = WordDraft(headword: 'cough', ipaUk: 'kof');
      expect(draft.wouldOverwrite(SuggestionField.ipaUk, 'kɒf'), isTrue);
    });

    test('accepting the same value is not an overwrite', () {
      // Tapping the chip that matches what is already there should not put a
      // pointless dialog in the way.
      const draft = WordDraft(headword: 'cough', ipaUk: 'kɒf');
      expect(draft.wouldOverwrite(SuggestionField.ipaUk, 'kɒf'), isFalse);
      expect(draft.wouldOverwrite(SuggestionField.ipaUk, ' kɒf '), isFalse);
    });

    test('replacing a previously accepted suggestion is not an overwrite', () {
      // The value being replaced came from the dictionary, not from the user,
      // so there is nothing of theirs to protect.
      final draft = const WordDraft(headword: 'cough')
          .accept(suggestion(SuggestionField.ipaUk, 'kɒf'), results);

      expect(draft.wouldOverwrite(SuggestionField.ipaUk, 'kɔːf'), isFalse);
    });

    test("typing over an accepted field makes it the user's again", () {
      final draft = const WordDraft(headword: 'cough')
          .accept(suggestion(SuggestionField.ipaUk, 'kɒf'), results)
          .copyWith(ipaUk: 'my own')
          .markManual(SuggestionField.ipaUk);

      expect(draft.wouldOverwrite(SuggestionField.ipaUk, 'kɔːf'), isTrue);
    });
  });

  group('a chip fills exactly one field', () {
    test('accepting an IPA suggestion leaves the definition alone', () {
      final draft = const WordDraft(
        headword: 'cough',
        definition: 'mine',
      ).accept(suggestion(SuggestionField.ipaUk, 'kɒf'), results);

      expect(draft.ipaUk, 'kɒf');
      expect(draft.definition, 'mine', reason: 'nothing else may change');
      expect(draft.ipaUs, isEmpty);
      expect(draft.example, isEmpty);
    });

    test('each field can be accepted independently', () {
      final draft = const WordDraft(headword: 'cough')
          .accept(suggestion(SuggestionField.ipaUk, 'kɒf'), results)
          .accept(suggestion(SuggestionField.example, 'She coughed.'), results);

      expect(draft.ipaUk, 'kɒf');
      expect(draft.example, 'She coughed.');
      expect(draft.acceptedFields.keys, hasLength(2));
    });
  });

  group('attribution is owed only on what was taken', () {
    test('a wholly typed word carries none', () {
      final word = const WordDraft(
        headword: 'cough',
        ipaUk: 'kɒf',
        definition: 'my own words',
      ).toWord(id: 'w1', now: DateTime.utc(2026, 9, 9));

      expect(word.source, WordSource.manual);
      expect(
        word.sourceAttribution,
        isNull,
        reason: "the user's own writing owes nobody a credit",
      );
    });

    test('a wholly accepted word carries the credit and the source URL', () {
      final word = const WordDraft(headword: 'cough')
          .accept(suggestion(SuggestionField.ipaUk, 'kɒf'), results)
          .toWord(id: 'w1', now: DateTime.utc(2026, 9, 9));

      expect(word.source, WordSource.api);
      expect(word.sourceAttribution, contains('CC BY-SA 4.0'));
      expect(word.sourceAttribution, contains('en.wiktionary.org'));
    });

    test('mixing typed and accepted content is recorded as mixed', () {
      final word = const WordDraft(headword: 'cough', definition: 'my own')
          .accept(suggestion(SuggestionField.ipaUk, 'kɒf'), results)
          .toWord(id: 'w1', now: DateTime.utc(2026, 9, 9));

      expect(word.source, WordSource.mixed);
      expect(word.sourceAttribution, isNotNull);
    });

    test('an offline suggestion is credited to CMU, not Wiktionary', () {
      const offline = WordSuggestions(
        headword: 'cough',
        source: WordSource.offline,
        attribution: WordSuggestions.cmudictAttribution,
      );
      final word = const WordDraft(headword: 'cough')
          .accept(
            suggestion(
              SuggestionField.ipaUs,
              'kɑf',
              source: WordSource.offline,
            ),
            offline,
          )
          .toWord(id: 'w1', now: DateTime.utc(2026, 9, 9));

      expect(word.source, WordSource.offline);
      expect(word.sourceAttribution, contains('CMU'));
    });

    test('removing the last accepted field drops the attribution', () {
      final draft = const WordDraft(headword: 'cough')
          .accept(suggestion(SuggestionField.ipaUk, 'kɒf'), results)
          .markManual(SuggestionField.ipaUk);

      expect(draft.attribution, isNull);
      expect(
        draft.toWord(id: 'w1', now: DateTime.utc(2026, 9, 9)).source,
        WordSource.manual,
      );
    });
  });

  group('empty fields are stored as null, not as empty strings', () {
    test('blank optional fields become null', () {
      final word = const WordDraft(
        headword: 'cough',
        ipaUk: '   ',
        example: '  ',
      ).toWord(id: 'w1', now: DateTime.utc(2026, 9, 9));

      expect(word.ipaUk, isNull);
      expect(word.definition, isNull);
      expect(word.example, isNull);
      expect(word.hasNoIpa, isTrue);
    });

    test('slashes pasted into an IPA field are stripped', () {
      final word = const WordDraft(
        headword: 'cough',
        ipaUk: '/kɒf/',
      ).toWord(id: 'w1', now: DateTime.utc(2026, 9, 9));

      expect(word.ipaUk?.value, 'kɒf');
      expect(word.ipaUk?.display, '/kɒf/');
    });
  });

  group('IPA symbol row', () {
    test('offers the symbols UI-UX section 4.2 lists', () {
      expect(IpaKeyboardRow.symbols, hasLength(21));
      expect(IpaKeyboardRow.symbols.take(3), <String>['ˈ', 'ˌ', 'ː']);
      expect(IpaKeyboardRow.symbols, contains('tʃ'));
      expect(IpaKeyboardRow.symbols, contains('dʒ'));
      expect(IpaKeyboardRow.symbols, contains('ɹ'));
    });

    test('does not offer slashes - they are fixed affixes', () {
      expect(IpaKeyboardRow.symbols, isNot(contains('/')));
    });

    test('inserts at the cursor', () {
      const value = TextEditingValue(
        text: 'kf',
        selection: TextSelection.collapsed(offset: 1),
      );
      final next = IpaKeyboardRow.insert(value, 'ɒ');

      expect(next.text, 'kɒf');
      expect(next.selection.baseOffset, 2);
    });

    test('replaces the selection', () {
      const value = TextEditingValue(
        text: 'kof',
        selection: TextSelection(baseOffset: 1, extentOffset: 2),
      );
      final next = IpaKeyboardRow.insert(value, 'ɒ');

      expect(next.text, 'kɒf');
      expect(next.selection.baseOffset, 2);
    });

    test('appends when the field has never been focused', () {
      const value = TextEditingValue(text: 'k');
      final next = IpaKeyboardRow.insert(value, 'ɒ');

      expect(next.text, 'kɒ');
      expect(next.selection.baseOffset, 2);
    });

    test('a two-character symbol moves the cursor by two', () {
      // `tʃ` is one button and one sound, but two code units.
      const value = TextEditingValue(
        selection: TextSelection.collapsed(offset: 0),
      );
      final next = IpaKeyboardRow.insert(value, 'tʃ');

      expect(next.text, 'tʃ');
      expect(next.selection.baseOffset, 2);
    });
  });
}
