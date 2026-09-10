import 'package:flutter/material.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/presentation/design/gap.dart';

/// A headed block of content.
///
/// Word detail, settings and the guide all draw the same thing: a title in
/// `titleMedium`, a small gap, then content. Each was rebuilding it privately,
/// which is how three "identical" sections end up with three different gaps
/// after a few edits.
///
/// Spacing comes from [AppMetricsContext], not from constants, so restyling the
/// app changes this in one place.
class VnSection extends StatelessWidget {
  /// Creates a section.
  const new({
    required this.heading,
    required this.child,
    this.trailing,
    this.padded = true,
    super.key,
  });

  /// The section title.
  final String heading;

  /// What sits under the heading.
  final Widget child;

  /// An optional action on the heading row, e.g. an *Add* button.
  final Widget? trailing;

  /// Whether to leave a gap beneath the section. False for the last one.
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = context.metrics;

    return Padding(
      padding: EdgeInsets.only(bottom: padded ? metrics.spaceLg : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(heading, style: theme.textTheme.titleMedium),
              ),
              ?trailing,
            ],
          ),
          const VnGap(VnSpace.xs),
          child,
        ],
      ),
    );
  }
}

/// A quiet line of secondary text — attribution, hints, captions.
///
/// One widget rather than a `Text` with a hand-rolled
/// `bodySmall.copyWith(color: outline)` at every call site, so "quiet" means
/// one thing everywhere.
class VnQuietText extends StatelessWidget {
  /// Creates quiet text.
  const new(this.text, {this.emphasis = VnQuietEmphasis.small, super.key});

  /// What to say.
  final String text;

  /// How quiet.
  final VnQuietEmphasis emphasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = switch (emphasis) {
      VnQuietEmphasis.small => theme.textTheme.bodySmall,
      VnQuietEmphasis.body => theme.textTheme.bodyMedium,
    };

    return Text(text, style: style?.copyWith(color: theme.colorScheme.outline));
  }
}

/// How loud a [VnQuietText] is.
enum VnQuietEmphasis {
  /// Captions and attribution.
  small,

  /// Body-sized, still secondary.
  body,
}
