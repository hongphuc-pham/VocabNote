/// English IPA read as sounds, for a screen reader (`docs/UI-UX.md` §6).
///
/// A screen reader cannot read IPA: at best it names the glyphs ("theta,
/// small capital I, eng"), which means nothing to a learner. This turns a
/// transcription into the sounds it spells, so each can be read out by a name
/// a learner knows ("th as in thin, short i as in sit, ng as in sing"). The
/// names themselves are UI strings and live in the ARB file; this file only
/// decides which sounds a string holds, so it stays pure and testable.
///
/// Sounds are found by longest match over graphemes - never code units
/// (RULES §21): a two-symbol sound (`tʃ`, `eɪ`, `iː`) is taken before its
/// parts, a tie bar is read as joining what it joins, and the length mark folds
/// into the vowel before it. Anything not recognised is read as itself.
library;

import 'package:flutter/foundation.dart' show immutable;
import 'package:vocabnote/core/extensions/grapheme.dart';

/// A sound of English, as a learner names it.
///
/// Vowels are named after John Wells' lexical sets (KIT, DRESS, TRAP…), the
/// standard keywords for English vowels; consonants after their usual letter.
enum IpaSound {
  /// p
  p,

  /// b
  b,

  /// t (also the tap ɾ, as in American "water")
  t,

  /// d
  d,

  /// k
  k,

  /// g (both `g` and `ɡ`)
  g,

  /// f
  f,

  /// v
  v,

  /// θ, as in "thin"
  thVoiceless,

  /// ð, as in "this"
  thVoiced,

  /// s
  s,

  /// z
  z,

  /// ʃ, as in "she"
  sh,

  /// ʒ, as in "measure"
  zh,

  /// tʃ, as in "church"
  ch,

  /// dʒ, as in "judge"
  judge,

  /// h
  h,

  /// m
  m,

  /// n
  n,

  /// ŋ, as in "sing"
  ng,

  /// l (also dark ɫ)
  l,

  /// r (both `r` and `ɹ`)
  r,

  /// j, as in "yes"
  yes,

  /// w
  w,

  /// iː, as in "see"
  fleece,

  /// i, as in "happy"
  happy,

  /// ɪ, as in "sit"
  kit,

  /// e or ɛ, as in "bed"
  dress,

  /// æ (or a), as in "cat"
  trap,

  /// ʌ, as in "cup"
  strut,

  /// ɑː or ɑ, as in "father"
  palm,

  /// ɒ, as in "hot"
  lot,

  /// ɔː or ɔ, as in "saw"
  thought,

  /// ʊ, as in "book"
  foot,

  /// uː or u, as in "food"
  goose,

  /// ɜː, ɜ or ɝ, as in "her"
  nurse,

  /// ə, as in "about"
  comma,

  /// ɚ, as in American "butter"
  letter,

  /// eɪ, as in "day"
  face,

  /// aɪ, as in "my"
  price,

  /// ɔɪ, as in "boy"
  choice,

  /// əʊ or oʊ, as in "go"
  goat,

  /// aʊ, as in "now"
  mouth,

  /// ɪə, as in "near"
  near,

  /// eə or ɛə, as in "hair"
  square,

  /// ʊə, as in "poor"
  cure,

  /// ˈ - the next syllable is stressed.
  primaryStress,

  /// ˌ - the next syllable carries a lighter stress.
  secondaryStress,

  /// ː after something it does not make one sound with.
  long,
}

/// One part of a transcription: a sound, or text read as it is.
@immutable
sealed class IpaPart {
  const new();
}

/// A recognised sound.
final class IpaSoundPart extends IpaPart {
  /// Creates the part.
  const new(this.sound);

  /// The sound.
  final IpaSound sound;

  @override
  bool operator ==(Object other) =>
      other is IpaSoundPart && other.sound == sound;

  @override
  int get hashCode => sound.hashCode;

  @override
  String toString() => sound.name;
}

/// A symbol with no learner name, read out as itself.
final class IpaRawPart extends IpaPart {
  /// Creates the part.
  const new(this.text);

  /// The symbol, as written.
  final String text;

  @override
  bool operator ==(Object other) => other is IpaRawPart && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'raw($text)';
}

/// The sounds in [ipa], in order.
List<IpaPart> ipaSounds(String ipa) {
  // Each grapheme reduced to its base: a tie bar (`t͡ʃ`) or a syllabic mark
  // (`n̩`) is a combining character riding on a letter, and says nothing a
  // learner's name would. The original is kept for anything unrecognised.
  final graphemes = <(String base, String original)>[
    for (final grapheme in ipa.graphemeClusters)
      if (!_skipped.contains(grapheme)) (_base(grapheme), grapheme),
  ];

  final parts = <IpaPart>[];
  var i = 0;
  while (i < graphemes.length) {
    final (base, original) = graphemes[i];
    if (i + 1 < graphemes.length) {
      final pair = _pairs['$base${graphemes[i + 1].$1}'];
      if (pair != null) {
        parts.add(IpaSoundPart(pair));
        i += 2;
        continue;
      }
    }
    final single = _singles[base];
    parts.add(single == null ? IpaRawPart(original) : IpaSoundPart(single));
    i += 1;
  }
  return parts;
}

/// The sound one symbol stands for - a chip in the highlight editor, a key on
/// the IPA keyboard (which offers `tʃ` and `dʒ` as one key each). Null when it
/// has no learner name.
IpaSound? ipaSoundOf(String symbol) => switch (ipaSounds(symbol)) {
  [IpaSoundPart(:final sound)] => sound,
  _ => null,
};

String _base(String grapheme) => String.fromCharCodes(
  grapheme.runes.where((rune) => rune < 0x0300 || rune > 0x036F),
);

/// Two symbols that make one sound.
const Map<String, IpaSound> _pairs = <String, IpaSound>{
  'tʃ': IpaSound.ch,
  'dʒ': IpaSound.judge,
  'eɪ': IpaSound.face,
  'ɛɪ': IpaSound.face,
  'aɪ': IpaSound.price,
  'ɑɪ': IpaSound.price,
  'ɔɪ': IpaSound.choice,
  'əʊ': IpaSound.goat,
  'oʊ': IpaSound.goat,
  'aʊ': IpaSound.mouth,
  'ɑʊ': IpaSound.mouth,
  'ɪə': IpaSound.near,
  'eə': IpaSound.square,
  'ɛə': IpaSound.square,
  'ʊə': IpaSound.cure,
  'iː': IpaSound.fleece,
  'ɑː': IpaSound.palm,
  'ɔː': IpaSound.thought,
  'uː': IpaSound.goose,
  'ɜː': IpaSound.nurse,
};

const Map<String, IpaSound> _singles = <String, IpaSound>{
  'p': IpaSound.p,
  'b': IpaSound.b,
  't': IpaSound.t,
  'ɾ': IpaSound.t,
  'd': IpaSound.d,
  'k': IpaSound.k,
  'g': IpaSound.g,
  'ɡ': IpaSound.g,
  'f': IpaSound.f,
  'v': IpaSound.v,
  'θ': IpaSound.thVoiceless,
  'ð': IpaSound.thVoiced,
  's': IpaSound.s,
  'z': IpaSound.z,
  'ʃ': IpaSound.sh,
  'ʒ': IpaSound.zh,
  'h': IpaSound.h,
  'm': IpaSound.m,
  'n': IpaSound.n,
  'ŋ': IpaSound.ng,
  'l': IpaSound.l,
  'ɫ': IpaSound.l,
  'r': IpaSound.r,
  'ɹ': IpaSound.r,
  'j': IpaSound.yes,
  'w': IpaSound.w,
  'i': IpaSound.happy,
  'ɪ': IpaSound.kit,
  'e': IpaSound.dress,
  'ɛ': IpaSound.dress,
  'æ': IpaSound.trap,
  'a': IpaSound.trap,
  'ʌ': IpaSound.strut,
  'ɐ': IpaSound.strut,
  'ɑ': IpaSound.palm,
  'ɒ': IpaSound.lot,
  'ɔ': IpaSound.thought,
  'ʊ': IpaSound.foot,
  'u': IpaSound.goose,
  'ɜ': IpaSound.nurse,
  'ɝ': IpaSound.nurse,
  'ə': IpaSound.comma,
  'ɚ': IpaSound.letter,
  'o': IpaSound.goat,
  'ˈ': IpaSound.primaryStress,
  'ˌ': IpaSound.secondaryStress,
  'ː': IpaSound.long,
};

/// Written but not spoken: syllable breaks, optional-sound brackets, spaces,
/// the slashes if a caller left them on.
const Set<String> _skipped = <String>{
  '.',
  '(',
  ')',
  ' ',
  '/',
  '[',
  ']',
  '‿',
  'ˑ',
  '-',
};
