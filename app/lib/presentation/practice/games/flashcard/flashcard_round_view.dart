import 'package:flutter/material.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/core/theme/tokens.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/presentation/common/ipa_text.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/practice/games/flashcard/flashcard_game.dart';

/// One flashcard: a front, a flip, a back, three grades (`UI-UX.md` §4.7).
///
/// A game owns its round widget and nothing else — no navigation, no database,
/// no progress bar. Everything it needs arrives in [round]; everything it wants
/// done goes through [callbacks].
class FlashcardRoundView extends StatefulWidget {
  /// Creates the view.
  const new({required this.round, required this.callbacks, super.key});

  /// The card being asked about.
  final FlashcardRound round;

  /// The only things this view may ask the runner to do.
  final GameRoundCallbacks callbacks;

  @override
  State<FlashcardRoundView> createState() => _FlashcardRoundViewState();
}

class _FlashcardRoundViewState extends State<FlashcardRoundView> {
  bool _revealed = false;
  final Stopwatch _elapsed = Stopwatch()..start();

  @override
  void didUpdateWidget(FlashcardRoundView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new round reuses this State when the runner swaps the card, so the
    // reveal has to be reset explicitly. Without this the second card of a
    // session opens already answered.
    if (oldWidget.round.index != widget.round.index) {
      _revealed = false;
      _elapsed
        ..reset()
        ..start();
    }
  }

  void _reveal() {
    if (_revealed) return;
    setState(() => _revealed = true);
    if (widget.callbacks.onSpeak case final VoidCallback speak) speak();
  }

  void _answer(ReviewOutcome result) {
    // Grading before revealing would record an answer the user never saw the
    // question for.
    if (!_revealed) return;
    _elapsed.stop();
    widget.callbacks.onAnswer(
      GameAnswer(result: result, elapsed: _elapsed.elapsed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = context.metrics;

    return Padding(
      padding: EdgeInsets.all(metrics.spaceLg),
      child: Column(
        children: <Widget>[
          Expanded(
            child: _Card(
              round: widget.round,
              revealed: _revealed,
              onReveal: _reveal,
              onSpeak: widget.callbacks.onSpeak,
            ),
          ),
          const VnGap(VnSpace.lg),
          _Grades(
            enabled: _revealed,
            intervalLabel: widget.callbacks.intervalLabel,
            onGrade: _answer,
          ),
        ],
      ),
    );
  }
}

/// The card itself, front or back.
class _Card extends StatelessWidget {
  const new({
    required this.round,
    required this.revealed,
    required this.onReveal,
    this.onSpeak,
  });

  final FlashcardRound round;
  final bool revealed;
  final VoidCallback onReveal;
  final VoidCallback? onSpeak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;

    return Semantics(
      // UI-UX §6: the flip card announces its state, rather than silently
      // changing what it says.
      label: revealed ? l10n.flashcardBackLabel : l10n.flashcardFrontLabel,
      button: !revealed,
      onTap: revealed ? null : onReveal,
      child: GestureDetector(
        onTap: onReveal,
        // Swipe up reveals, as an alternative to tapping - never the only way
        // (UI-UX §1).
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < 0) onReveal();
        },
        child: Card(
          child: SizedBox.expand(
            child: Padding(
              padding: EdgeInsets.all(metrics.spaceLg),
              child: AnimatedSwitcher(
                // Zero when the user has asked for reduced motion (F-093):
                // `durationFor` is the single place that check lives.
                duration: AppMotion.durationFor(context, metrics.flip),
                switchInCurve: AppMotion.flipCurve,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: revealed
                    ? _Back(key: const ValueKey<bool>(true), round: round)
                    : _Front(
                        key: const ValueKey<bool>(false),
                        round: round,
                        onSpeak: onSpeak,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The question side.
class _Front extends StatelessWidget {
  const new({required this.round, this.onSpeak, super.key});

  final FlashcardRound round;
  final VoidCallback? onSpeak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (round.frontIsIpa)
          IpaText(
            ipa: round.frontText,
            highlights: round.card.highlights,
            style: context.type.ipaLarge,
          )
        else
          Text(
            round.frontText,
            style: context.type.displayWord,
            textAlign: TextAlign.center,
          ),
        if (onSpeak != null) ...<Widget>[
          const VnGap(VnSpace.lg),
          IconButton.filledTonal(
            icon: const Icon(Icons.volume_up),
            tooltip: l10n.detailPlayLabel(
              round.card.word.headword.value,
              round.card.word.ipaUk != null
                  ? l10n.detailAccentUk
                  : l10n.detailAccentUs,
            ),
            onPressed: onSpeak,
          ),
        ],
        if (round.isFirstRound) ...<Widget>[
          const VnGap(VnSpace.xl),
          Text(
            l10n.flashcardTapToReveal,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// The answer side: word · IPA with highlights · definition · first note.
class _Back extends StatelessWidget {
  const new({required this.round, super.key});

  final FlashcardRound round;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final word = round.card.word;
    final ipa = word.preferredIpa;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Text(
            word.headword.value,
            style: context.type.displayWord,
            textAlign: TextAlign.center,
          ),
          if (ipa != null) ...<Widget>[
            const VnGap(VnSpace.sm),
            IpaText(
              ipa: ipa.value,
              highlights: round.card.highlights,
              style: context.type.ipaLarge,
            ),
          ],
          if (word.definition case final String definition
              when definition.isNotEmpty) ...<Widget>[
            const VnGap(VnSpace.lg),
            Text(
              definition,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
          if (round.card.firstNote case final String note
              when note.isNotEmpty) ...<Widget>[
            const VnGap(VnSpace.lg),
            Text(
              note,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Again · Good · Easy, each showing when the card returns.
class _Grades extends StatelessWidget {
  const new({required this.enabled, required this.onGrade, this.intervalLabel});

  final bool enabled;
  final String Function(ReviewOutcome outcome)? intervalLabel;
  final void Function(ReviewOutcome outcome) onGrade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;

    return Row(
      spacing: metrics.spaceSm,
      children: <Widget>[
        Expanded(
          child: _GradeButton(
            outcome: ReviewOutcome.again,
            label: l10n.gradeAgain,
            interval: intervalLabel?.call(ReviewOutcome.again),
            style: _GradeStyle.outlined,
            onPressed: enabled ? () => onGrade(ReviewOutcome.again) : null,
          ),
        ),
        Expanded(
          child: _GradeButton(
            outcome: ReviewOutcome.good,
            label: l10n.gradeGood,
            interval: intervalLabel?.call(ReviewOutcome.good),
            style: _GradeStyle.filled,
            onPressed: enabled ? () => onGrade(ReviewOutcome.good) : null,
          ),
        ),
        Expanded(
          child: _GradeButton(
            outcome: ReviewOutcome.easy,
            label: l10n.gradeEasy,
            interval: intervalLabel?.call(ReviewOutcome.easy),
            style: _GradeStyle.tonal,
            onPressed: enabled ? () => onGrade(ReviewOutcome.easy) : null,
          ),
        ),
      ],
    );
  }
}

enum _GradeStyle { outlined, filled, tonal }

class _GradeButton extends StatelessWidget {
  const new({
    required this.outcome,
    required this.label,
    required this.style,
    required this.onPressed,
    this.interval,
  });

  final ReviewOutcome outcome;
  final String label;
  final String? interval;
  final _GradeStyle style;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The interval is a hint, not a second label: a screen reader saying
    // "Good, 2d" is fine, but it must not read as two separate controls.
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label),
        if (interval case final String next)
          Text(next, style: theme.textTheme.labelSmall),
      ],
    );

    return switch (style) {
      _GradeStyle.outlined => OutlinedButton(
        key: ValueKey<String>('grade-${outcome.name}'),
        onPressed: onPressed,
        child: child,
      ),
      _GradeStyle.filled => FilledButton(
        key: ValueKey<String>('grade-${outcome.name}'),
        onPressed: onPressed,
        child: child,
      ),
      _GradeStyle.tonal => FilledButton.tonal(
        key: ValueKey<String>('grade-${outcome.name}'),
        onPressed: onPressed,
        child: child,
      ),
    };
  }
}
