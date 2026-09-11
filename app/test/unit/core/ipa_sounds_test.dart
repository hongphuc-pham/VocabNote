import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/utils/ipa_sounds.dart';
import 'package:vocabnote/presentation/words/ipa_keyboard_row.dart';

/// English IPA read as sounds (`docs/UI-UX.md` §6, M7 A3).
void main() {
  List<String> sounds(String ipa) => <String>[
    for (final part in ipaSounds(ipa)) part.toString(),
  ];

  group('whole transcriptions', () {
    test('one symbol, one sound', () {
      expect(sounds('kɒf'), <String>['k', 'lot', 'f']);
    });

    test('a two-symbol sound is one sound', () {
      expect(sounds('tʃɜːtʃ'), <String>['ch', 'nurse', 'ch']);
      expect(sounds('ʃɪə'), <String>['sh', 'near']);
      expect(sounds('θɪŋ'), <String>['thVoiceless', 'kit', 'ng']);
      expect(sounds('dʒʌdʒ'), <String>['judge', 'strut', 'judge']);
    });

    test('a tie bar joins what it joins', () {
      // `t͡ʃ` is two graphemes, the first carrying a combining tie bar.
      expect(sounds('t͡ʃɜːt͡ʃ'), sounds('tʃɜːtʃ'));
    });

    test('British and American spellings of the same vowel agree', () {
      expect(sounds('ɡəʊ'), <String>['g', 'goat']);
      expect(sounds('ɡoʊ'), <String>['g', 'goat']);
      expect(sounds('ɹɛd'), <String>['r', 'dress', 'd']);
    });

    test('stress is said before the syllable it marks', () {
      expect(sounds('əˈbaʊt'), <String>[
        'comma',
        'primaryStress',
        'b',
        'mouth',
        't',
      ]);
      expect(sounds('ˌɪnˈtɛns').first, 'secondaryStress');
    });

    test('brackets, syllable dots and spaces are not read out', () {
      expect(sounds('ˈnæʃ(ə)n(ə)l'), <String>[
        'primaryStress',
        'n',
        'trap',
        'sh',
        'comma',
        'n',
        'comma',
        'l',
      ]);
      expect(sounds('ˈwɔː.tə'), <String>[
        'primaryStress',
        'w',
        'thought',
        't',
        'comma',
      ]);
    });

    test('a length mark with no vowel to join is read as "long"', () {
      expect(sounds('eː'), <String>['dress', 'long']);
    });

    test('a symbol with no learner name is read as itself', () {
      expect(sounds('lɒx'), <String>['l', 'lot', 'raw(x)']);
      expect(ipaSounds('lɒx').last, const IpaRawPart('x'));
    });

    test('nothing to read is nothing', () {
      expect(ipaSounds(''), isEmpty);
    });
  });

  group('one symbol at a time', () {
    test('every key on the IPA keyboard has a learner name', () {
      final unnamed = <String>[
        for (final symbol in IpaKeyboardRow.symbols)
          if (ipaSoundOf(symbol) == null) symbol,
      ];
      expect(unnamed, isEmpty);
    });

    test('the two-letter keys are one sound each', () {
      expect(ipaSoundOf('tʃ'), IpaSound.ch);
      expect(ipaSoundOf('dʒ'), IpaSound.judge);
    });

    test('a chip holding a length mark alone is "long"', () {
      expect(ipaSoundOf('ː'), IpaSound.long);
    });

    test('an unnamed symbol has no sound', () {
      expect(ipaSoundOf('x'), isNull);
      expect(ipaSoundOf('kɒ'), isNull, reason: 'two sounds, not one');
    });
  });
}
