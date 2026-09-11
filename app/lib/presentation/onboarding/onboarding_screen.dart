import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/settings/settings_actions.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/tokens.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/settings/guide_illustrations.dart';
import 'package:vocabnote/presentation/settings/guide_screen.dart';

/// First-run onboarding (F-077): three short slides, then the guide.
///
/// Shown once, and only to someone with no words yet - `bootstrap` decides
/// before the first frame. *Skip* is on every slide (Apple HIG: "fast, fun,
/// and optional"), and the slides are short on purpose: help met in context
/// is what people remember, so they only set the scene and the guide's
/// *Try it* does the teaching.
///
/// Nothing depends on swiping: *Next* and *Skip* are buttons, and the
/// position is read out as "Page 2 of 3" (`docs/UI-UX.md` §1).
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _slideCount = 3;

  final PageController _pages = PageController();
  int _page = 0;
  bool _showingGuide = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// Marks onboarding done, then goes to [location].
  ///
  /// Done first: however the user leaves - Skip, Done, or a card's Try it -
  /// they are not greeted again.
  Future<void> _finish(String location) async {
    final router = GoRouter.of(context);
    await ref.read(settingsActionsProvider.notifier).completeOnboarding();
    router.go(location);
  }

  void _next() {
    if (_page == _slideCount - 1) {
      setState(() => _showingGuide = true);
      return;
    }
    final target = _page + 1;
    // UI-UX §2: every animation is skipped when the platform asks.
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(target);
    } else {
      _pages.animateToPage(
        target,
        duration: context.metrics.enter,
        curve: AppMotion.enterCurve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;

    if (_showingGuide) {
      // Back returns to the slides rather than leaving the app.
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _showingGuide = false);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.guideTitle),
            automaticallyImplyLeading: false,
          ),
          body: GuideCards(
            onTry: (location) => unawaited(_finish(location)),
            footer: Padding(
              padding: EdgeInsets.only(top: metrics.spaceSm),
              child: FilledButton(
                onPressed: () => unawaited(_finish(Routes.words)),
                child: Text(l10n.onboardingStart),
              ),
            ),
          ),
        ),
      );
    }

    final slides = <_Slide>[
      _Slide(
        illustration: const AddWordIllustration(),
        title: l10n.onboardingSlide1Title,
        body: l10n.onboardingSlide1Body,
      ),
      _Slide(
        illustration: const HighlightIllustration(),
        title: l10n.onboardingSlide2Title,
        body: l10n.onboardingSlide2Body,
      ),
      _Slide(
        illustration: const PractiseIllustration(),
        title: l10n.onboardingSlide3Title,
        body: l10n.onboardingSlide3Body,
      ),
    ];
    final last = _page == _slideCount - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: EdgeInsets.all(metrics.spaceSm),
                child: TextButton(
                  onPressed: () => unawaited(_finish(Routes.words)),
                  child: Text(l10n.onboardingSkip),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (page) => setState(() => _page = page),
                children: slides,
              ),
            ),
            _PageDots(page: _page, count: _slideCount),
            Padding(
              padding: EdgeInsets.all(metrics.spaceLg),
              child: FilledButton(
                onPressed: _next,
                child: Text(last ? l10n.onboardingShowMe : l10n.onboardingNext),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One slide: an illustration, a title, a sentence.
///
/// Scrolls, so it holds together at 200% text on a small phone.
class _Slide extends StatelessWidget {
  const new({
    required this.illustration,
    required this.title,
    required this.body,
  });

  final Widget illustration;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = context.metrics;

    return SingleChildScrollView(
      padding: EdgeInsets.all(metrics.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // A mock-up of the real controls; the sentence says what it shows.
          ExcludeSemantics(
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(metrics.spaceLg),
                child: illustration,
              ),
            ),
          ),
          const VnGap(VnSpace.xl),
          Semantics(
            header: true,
            child: Text(title, style: theme.textTheme.headlineSmall),
          ),
          const VnGap(VnSpace.sm),
          Text(body, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

/// Where the user is in the slides, as dots - and, for a screen reader, as
/// words.
class _PageDots extends StatelessWidget {
  const new({required this.page, required this.count});

  final int page;
  final int count;

  @override
  Widget build(BuildContext context) {
    final metrics = context.metrics;
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: AppL10n.of(context).onboardingPage(page + 1, count),
      liveRegion: true,
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: metrics.spaceXs,
          children: <Widget>[
            for (var i = 0; i < count; i++)
              Container(
                width: i == page ? metrics.spaceLg : metrics.spaceSm,
                height: metrics.spaceSm,
                decoration: BoxDecoration(
                  color: i == page ? scheme.primary : scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(metrics.radiusPill),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
