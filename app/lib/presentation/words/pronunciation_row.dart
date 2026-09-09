import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/words/pronunciation_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/core/theme/tokens.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/presentation/common/ipa_text.dart';

/// One accent's transcription with its play button (`docs/UI-UX.md` §4.3).
///
/// `UK  /kɒf/  [▶]` — the accent label, the transcription with the user's
/// highlight colours, and a play button. Tap speaks it; **long-press speaks it
/// at 0.6×** for imitation practice (F-021).
///
/// The long-press is a shortcut, not the only route: `docs/UI-UX.md` §1 forbids
/// hiding an action behind a gesture, so slow replay is also offered in the
/// button's own menu for anyone who cannot long-press — a screen-reader user
/// among them.
class PronunciationRow extends ConsumerWidget {
  /// Creates a row for one transcription.
  const new({
    required this.headword,
    required this.ipa,
    required this.locale,
    required this.highlights,
    this.emphasisedHighlightId,
    super.key,
  });

  /// The word being spoken. Spoken aloud, and named in the button's label.
  final String headword;

  /// The transcription to display, without slashes.
  final String ipa;

  /// Which accent this row is.
  final TtsLocale locale;

  /// The highlights on this transcription only.
  final List<IpaHighlight> highlights;

  /// The highlight the legend is currently pointing at (F-024).
  final String? emphasisedHighlightId;

  /// The row's accent label.
  String _accentLabel(AppL10n l10n) => switch (locale) {
    TtsLocale.enGb => l10n.detailAccentUk,
    TtsLocale.enUs => l10n.detailAccentUs,
  };

  Future<void> _play(
    BuildContext context,
    WidgetRef ref, {
    required bool slow,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);

    final result = await ref
        .read(pronunciationProvider.notifier)
        .play(headword, locale: locale, slow: slow);

    if (result.isErr && context.mounted) {
      // A missing voice is worth telling the user about: it is a thing they can
      // fix in OS settings, and silence with no explanation reads as a bug.
      messenger.showSnackBar(SnackBar(content: Text(l10n.detailSpeechFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final playback = ref.watch(pronunciationProvider);
    final isSpeaking = playback.isSpeaking(locale);
    final accent = _accentLabel(l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 32,
            child: Text(
              accent,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: IpaText(
              ipa: ipa,
              highlights: highlights,
              style: context.type.ipaLarge,
              emphasisedHighlightId: emphasisedHighlightId,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _PlayButton(
            isSpeaking: isSpeaking,
            label: isSpeaking
                ? l10n.detailStopLabel
                : l10n.detailPlayLabel(headword, accent),
            slowLabel: l10n.detailPlaySlowLabel(headword, accent),
            onPlay: () => isSpeaking
                ? ref.read(pronunciationProvider.notifier).stop()
                : _play(context, ref, slow: false),
            onPlaySlow: () => _play(context, ref, slow: true),
          ),
        ],
      ),
    );
  }
}

/// The play button, with slow replay on long-press and in its menu.
class _PlayButton extends StatelessWidget {
  const new({
    required this.isSpeaking,
    required this.label,
    required this.slowLabel,
    required this.onPlay,
    required this.onPlaySlow,
  });

  final bool isSpeaking;
  final String label;
  final String slowLabel;
  final VoidCallback onPlay;
  final VoidCallback onPlaySlow;

  /// The minimum touch target `docs/RULES.md` §7 and F-093 require.
  static const double _target = 48;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: label,
      // The long-press is duplicated as a semantic action so a screen-reader
      // user reaches slow replay too, without having to hold a gesture.
      customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
        CustomSemanticsAction(label: slowLabel): onPlaySlow,
      },
      child: ExcludeSemantics(
        child: Tooltip(
          message: label,
          child: InkResponse(
            onTap: onPlay,
            onLongPress: onPlaySlow,
            radius: _target / 2,
            child: SizedBox(
              width: _target,
              height: _target,
              child: Icon(
                isSpeaking ? Icons.stop_circle_outlined : Icons.play_circle,
                size: AppSpacing.xl + AppSpacing.xs,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
