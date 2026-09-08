/// ARPAbet to IPA, for the offline pronunciation fallback (F-005).
///
/// CMUdict transcribes with ARPAbet, a 39-phoneme ASCII scheme. This is the
/// committed mapping used by `build_ipa_fallback.dart`, kept in its own file
/// so it can be reviewed and tested as data rather than buried in a script.
///
/// **This is US English only**, and a broad transcription. CMUdict has no
/// British entries at all, which is why the offline path fills `ipa_us` and
/// leaves `ipa_uk` empty for the user to type (`docs/DATA-SOURCES.md` §2).
///
/// Source: CMU Pronouncing Dictionary, Carnegie Mellon University.
/// Unrestricted for research and commercial use; CMU asks that its origin be
/// acknowledged, which the app does in *Settings -> Data sources & licences*.
library;

/// The 39 ARPAbet phonemes, without stress digits.
///
/// Vowels carry a stress digit in CMUdict (`AA1`); the digit is stripped and
/// turned into an IPA stress mark before this table is consulted.
const Map<String, String> arpabetToIpa = <String, String>{
  // --- Vowels -------------------------------------------------------------
  'AA': 'ɑ', // odd      AA D
  'AE': 'æ', // at       AE T
  'AH': 'ʌ', // hut      HH AH T   (unstressed AH0 is remapped to schwa)
  'AO': 'ɔ', // ought    AO T
  'AW': 'aʊ', // cow     K AW
  'AY': 'aɪ', // hide    HH AY D
  'EH': 'ɛ', // Ed       EH D
  'ER': 'ɝ', // hurt     HH ER T   (unstressed ER0 is remapped to ɚ)
  'EY': 'eɪ', // ate     EY T
  'IH': 'ɪ', // it       IH T
  'IY': 'i', // eat      IY T
  'OW': 'oʊ', // oat     OW T
  'OY': 'ɔɪ', // toy     T OY
  'UH': 'ʊ', // hood     HH UH D
  'UW': 'u', // two      T UW
  // --- Consonants ---------------------------------------------------------
  'B': 'b', // be
  'CH': 'tʃ', // cheese
  'D': 'd', // dee
  'DH': 'ð', // thee
  'F': 'f', // fee
  'G': 'ɡ', // green   (U+0261 script g, the IPA letter - not ASCII 'g')
  'HH': 'h', // he
  'JH': 'dʒ', // gee
  'K': 'k', // key
  'L': 'l', // lee
  'M': 'm', // me
  'N': 'n', // knee
  'NG': 'ŋ', // ping
  'P': 'p', // pee
  'R': 'ɹ', // read    (U+0279, the alveolar approximant, not the trill 'r')
  'S': 's', // sea
  'SH': 'ʃ', // she
  'T': 't', // tea
  'TH': 'θ', // theta
  'V': 'v', // vee
  'W': 'w', // we
  'Y': 'j', // yield
  'Z': 'z', // zee
  'ZH': 'ʒ', // seizure
};

/// Unstressed vowels that reduce, keyed by phoneme.
///
/// CMUdict marks stress 0/1/2. A stress-0 `AH` is a schwa, not a STRUT vowel -
/// writing `ʌ` for the second syllable of `about` would be plainly wrong to
/// anyone reading the transcription.
const Map<String, String> unstressedOverrides = <String, String>{
  'AH': 'ə',
  'ER': 'ɚ',
};

/// The IPA primary stress mark (U+02C8).
const String primaryStress = 'ˈ';

/// The IPA secondary stress mark (U+02CC).
const String secondaryStress = 'ˌ';

/// Converts one CMUdict pronunciation to IPA.
///
/// [phonemes] is the whitespace-split pronunciation, e.g.
/// `['K', 'AO1', 'F']` for *cough*.
///
/// Stress marks are placed **before the syllable**, not before the vowel: IPA
/// convention puts `ˈ` at the syllable boundary. Syllabification is
/// approximated by attaching the mark before the consonants that lead into the
/// stressed vowel, which is right for the overwhelming majority of English
/// words and is the standard approach for a broad transcription.
///
/// Returns null if nothing could be converted.
String? arpabetLineToIpa(List<String> phonemes) {
  // Each element is (ipa, stressDigit) with the stress belonging to a vowel.
  final units = <({String ipa, int? stress})>[];

  for (final raw in phonemes) {
    final token = raw.trim().toUpperCase();
    if (token.isEmpty) continue;

    final match = RegExp(r'^([A-Z]+)([0-2])?$').firstMatch(token);
    if (match == null) return null;

    final phoneme = match.group(1)!;
    final stress = match.group(2) == null ? null : int.parse(match.group(2)!);

    var ipa = arpabetToIpa[phoneme];
    if (ipa == null) return null;

    if (stress == 0 && unstressedOverrides.containsKey(phoneme)) {
      ipa = unstressedOverrides[phoneme]!;
    }

    units.add((ipa: ipa, stress: stress));
  }

  if (units.isEmpty) return null;

  // Where each stressed vowel is.
  final buffer = StringBuffer();
  final markPositions = <int, String>{};

  for (var i = 0; i < units.length; i++) {
    final stress = units[i].stress;
    if (stress == null || stress == 0) continue;

    // Walk back over the consonants leading into this vowel, so the mark lands
    // at the syllable onset rather than immediately before the vowel.
    var onset = i;
    while (onset > 0 && units[onset - 1].stress == null) {
      onset--;
      // Never swallow the coda of the previous syllable: stop after one
      // consonant unless the previous unit is also a plausible onset.
      if (i - onset >= 2) break;
    }
    // A word-initial stress mark on a single-syllable word adds nothing.
    if (onset == 0 && units.length <= 3 && stress == 1) continue;

    markPositions[onset] = stress == 1 ? primaryStress : secondaryStress;
  }

  for (var i = 0; i < units.length; i++) {
    final mark = markPositions[i];
    if (mark != null) buffer.write(mark);
    buffer.write(units[i].ipa);
  }

  final result = buffer.toString();
  return result.isEmpty ? null : result;
}
