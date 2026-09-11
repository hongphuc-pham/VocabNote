/// What a screen reader says for IPA (`docs/UI-UX.md` §6, M7).
///
/// The sounds come from `core/utils/ipa_sounds.dart`; the names a learner
/// knows them by come from the ARB file, so a second locale names them in its
/// own words.
library;

import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/utils/ipa_sounds.dart';

/// [ipa] as a screen reader should say it: "pronunciation: k, short o as in
/// hot, f". Without [announce], only the sounds.
String spokenIpa(AppL10n l10n, String ipa, {bool announce = true}) {
  final sounds = <String>[
    for (final part in ipaSounds(ipa))
      switch (part) {
        IpaSoundPart(:final sound) => ipaSoundName(l10n, sound),
        IpaRawPart(:final text) => text,
      },
  ].join(l10n.ipaSoundSeparator);
  return announce ? l10n.ipaSpokenPronunciation(sounds) : sounds;
}

/// One symbol - a chip, a keyboard key - as a screen reader should say it:
/// its sound's name, or the symbol itself when it has none.
String spokenSymbol(AppL10n l10n, String symbol) =>
    switch (ipaSoundOf(symbol)) {
      final IpaSound sound => ipaSoundName(l10n, sound),
      null => symbol,
    };

/// The learner's name for [sound]. Exhaustive, so a sound added to the enum
/// cannot ship without one.
String ipaSoundName(AppL10n l10n, IpaSound sound) => switch (sound) {
  IpaSound.p => l10n.ipaSoundP,
  IpaSound.b => l10n.ipaSoundB,
  IpaSound.t => l10n.ipaSoundT,
  IpaSound.d => l10n.ipaSoundD,
  IpaSound.k => l10n.ipaSoundK,
  IpaSound.g => l10n.ipaSoundG,
  IpaSound.f => l10n.ipaSoundF,
  IpaSound.v => l10n.ipaSoundV,
  IpaSound.thVoiceless => l10n.ipaSoundThVoiceless,
  IpaSound.thVoiced => l10n.ipaSoundThVoiced,
  IpaSound.s => l10n.ipaSoundS,
  IpaSound.z => l10n.ipaSoundZ,
  IpaSound.sh => l10n.ipaSoundSh,
  IpaSound.zh => l10n.ipaSoundZh,
  IpaSound.ch => l10n.ipaSoundCh,
  IpaSound.judge => l10n.ipaSoundJudge,
  IpaSound.h => l10n.ipaSoundH,
  IpaSound.m => l10n.ipaSoundM,
  IpaSound.n => l10n.ipaSoundN,
  IpaSound.ng => l10n.ipaSoundNg,
  IpaSound.l => l10n.ipaSoundL,
  IpaSound.r => l10n.ipaSoundR,
  IpaSound.yes => l10n.ipaSoundYes,
  IpaSound.w => l10n.ipaSoundW,
  IpaSound.fleece => l10n.ipaSoundFleece,
  IpaSound.happy => l10n.ipaSoundHappy,
  IpaSound.kit => l10n.ipaSoundKit,
  IpaSound.dress => l10n.ipaSoundDress,
  IpaSound.trap => l10n.ipaSoundTrap,
  IpaSound.strut => l10n.ipaSoundStrut,
  IpaSound.palm => l10n.ipaSoundPalm,
  IpaSound.lot => l10n.ipaSoundLot,
  IpaSound.thought => l10n.ipaSoundThought,
  IpaSound.foot => l10n.ipaSoundFoot,
  IpaSound.goose => l10n.ipaSoundGoose,
  IpaSound.nurse => l10n.ipaSoundNurse,
  IpaSound.comma => l10n.ipaSoundComma,
  IpaSound.letter => l10n.ipaSoundLetter,
  IpaSound.face => l10n.ipaSoundFace,
  IpaSound.price => l10n.ipaSoundPrice,
  IpaSound.choice => l10n.ipaSoundChoice,
  IpaSound.goat => l10n.ipaSoundGoat,
  IpaSound.mouth => l10n.ipaSoundMouth,
  IpaSound.near => l10n.ipaSoundNear,
  IpaSound.square => l10n.ipaSoundSquare,
  IpaSound.cure => l10n.ipaSoundCure,
  IpaSound.primaryStress => l10n.ipaSoundPrimaryStress,
  IpaSound.secondaryStress => l10n.ipaSoundSecondaryStress,
  IpaSound.long => l10n.ipaSoundLong,
};
