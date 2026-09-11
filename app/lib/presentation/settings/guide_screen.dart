import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/settings/guide_targets.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/design/section.dart';
import 'package:vocabnote/presentation/settings/guide_illustrations.dart';

/// *How to use* (F-071, `docs/UI-UX.md` §4.10). Always in Settings (RULES
/// §4), and one tap from the empty words list.
///
/// One primary action per card: *Try it*, which lands on the real screen.
/// That is the part that teaches - help met in context is remembered, a deck
/// of cards read up front is not (NN/g, `plan.md` research for slice 5).
class GuideScreen extends StatelessWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.of(context).guideTitle)),
      body: GuideCards(
        onTry: (location) {
          // The practice hub is a tab: switch to it, rather than stacking a
          // second copy of it on top of Settings.
          if (location == Routes.practice) {
            context.go(location);
          } else {
            unawaited(context.push<void>(location));
          }
        },
      ),
    );
  }
}

/// The six cards, as a scrolling list.
///
/// A column rather than a pager: it survives 200% text, and a guide opened a
/// second time is scanned, not paged through. Shared with the end of
/// onboarding, which adds its own [footer].
class GuideCards extends ConsumerWidget {
  /// Creates the list.
  const new({required this.onTry, this.footer, super.key});

  /// Goes to a card's destination.
  final ValueChanged<String> onTry;

  /// Anything to put after the last card.
  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final targets = ref.watch(guideTargetsProvider).value ?? GuideTargets.none;

    final cards = <_Card>[
      _Card(
        title: l10n.guideAddTitle,
        body: l10n.guideAddBody,
        illustration: const AddWordIllustration(),
        destination: targets.addWord,
      ),
      _Card(
        title: l10n.guideLookupTitle,
        body: l10n.guideLookupBody,
        illustration: const LookupIllustration(),
        destination: targets.addWord,
      ),
      _Card(
        title: l10n.guideIpaTitle,
        body: l10n.guideIpaBody,
        // The honest line (`docs/DATA-SOURCES.md` §4): a synthesised
        // reference, good for stress and vowels, not a native speaker.
        aside: l10n.guideIpaVoice,
        illustration: const IpaKeysIllustration(),
        destination: targets.addWord,
      ),
      _Card(
        title: l10n.guideHighlightTitle,
        body: l10n.guideHighlightBody,
        illustration: const HighlightIllustration(),
        destination: targets.highlight,
      ),
      _Card(
        title: l10n.guideNoteTitle,
        body: l10n.guideNoteBody,
        illustration: const NoteIllustration(),
        destination: targets.note,
      ),
      _Card(
        title: l10n.guidePractiseTitle,
        body: l10n.guidePractiseBody,
        illustration: const PractiseIllustration(),
        destination: targets.practise,
      ),
    ];

    return ListView(
      padding: EdgeInsets.all(metrics.spaceLg),
      children: <Widget>[
        VnQuietText(l10n.guideIntro, emphasis: VnQuietEmphasis.body),
        const VnGap(VnSpace.lg),
        for (final card in cards)
          Padding(
            padding: EdgeInsets.only(bottom: metrics.spaceMd),
            child: _GuideCard(card: card, onTry: onTry),
          ),
        ?footer,
      ],
    );
  }
}

/// One card's content.
final class _Card {
  const new({
    required this.title,
    required this.body,
    required this.illustration,
    required this.destination,
    this.aside,
  });

  final String title;
  final String body;
  final String? aside;
  final Widget illustration;
  final String destination;
}

class _GuideCard extends StatelessWidget {
  const new({required this.card, required this.onTry});

  final _Card card;
  final ValueChanged<String> onTry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final aside = card.aside;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(context.metrics.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // A mock-up of controls that are not really here: read out, it
            // would sound like buttons. The sentence below says what it shows.
            ExcludeSemantics(child: card.illustration),
            const VnGap(VnSpace.md),
            Semantics(
              header: true,
              child: Text(card.title, style: theme.textTheme.titleMedium),
            ),
            const VnGap(VnSpace.xs),
            Text(card.body, style: theme.textTheme.bodyMedium),
            if (aside != null) ...<Widget>[
              const VnGap(VnSpace.sm),
              VnQuietText(aside, emphasis: VnQuietEmphasis.body),
            ],
            const VnGap(VnSpace.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton.tonal(
                onPressed: () => onTry(card.destination),
                // Six buttons all called "Try it" are one button to a screen
                // reader; each says which card it belongs to.
                child: Text(
                  l10n.guideTryIt,
                  semanticsLabel: l10n.guideTryItFor(card.title),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
