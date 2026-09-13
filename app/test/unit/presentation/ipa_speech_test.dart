import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/utils/ipa_sounds.dart';
import 'package:vocabnote/presentation/common/ipa_speech.dart';

/// What a screen reader says for IPA, in the English strings (M7 A3).
///
/// The wording was chosen by the owner on 11 Sep: learner names, with an
/// example word for each vowel.
void main() {
  final l10n = lookupAppL10n(const Locale('en'));

  test('a transcription is announced as its sounds', () {
    expect(spokenIpa(l10n, 'kɒf'), 'pronunciation: k, short o as in hot, f');
    expect(
      spokenIpa(l10n, 'θɪŋ', announce: false),
      'th as in thin, short i as in sit, ng as in sing',
    );
    expect(spokenIpa(l10n, 'ʃɪə', announce: false), 'sh, ear as in near');
  });

  test('a symbol with no name is read as itself', () {
    expect(spokenIpa(l10n, 'lɒx', announce: false), 'l, short o as in hot, x');
  });

  test('one symbol is named alone', () {
    expect(spokenSymbol(l10n, 'tʃ'), 'ch');
    expect(spokenSymbol(l10n, 'ɒ'), 'short o as in hot');
    expect(spokenSymbol(l10n, 'x'), 'x');
  });

  test('every sound has a name of its own', () {
    final names = <IpaSound, String>{
      for (final sound in IpaSound.values) sound: ipaSoundName(l10n, sound),
    };
    expect(names.values.where((name) => name.trim().isEmpty), isEmpty);
    // Two sounds sharing a name would read the same to a learner.
    expect(names.values.toSet(), hasLength(IpaSound.values.length));
  });
}
