import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/tokens.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_suggestion.dart';

/// The look-up results card (`docs/UI-UX.md` §4.2, F-004).
///
/// Two things this must get right, both licence obligations rather than
/// niceties (`docs/DATA-SOURCES.md` §1):
///
/// * results are offered as **per-field chips**. Tapping one fills that field
///   and nothing else, so whatever the user already typed elsewhere survives;
/// * the attribution line and *View source* link are always visible while
///   API-derived text is on screen.
class LookupCard extends StatelessWidget {
  /// Creates the card for [suggestions].
  const new({
    required this.suggestions,
    required this.onAccept,
    required this.onDismiss,
    super.key,
  });

  /// What the look-up found.
  final WordSuggestions suggestions;

  /// Called when the user taps a chip. The caller confirms first if accepting
  /// would overwrite typed text.
  final void Function(FieldSuggestion suggestion) onAccept;

  /// Hides the card.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    if (suggestions.isEmpty) {
      return _Notice(
        text: l10n.lookupNoResults(suggestions.headword),
        onDismiss: onDismiss,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.lookupResultsTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: l10n.lookupDismiss,
                  onPressed: onDismiss,
                ),
              ],
            ),
            for (final field in SuggestionField.values)
              _FieldRow(
                field: field,
                suggestions: suggestions.forField(field),
                onAccept: onAccept,
              ),
            if (suggestions.requiresAttribution) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              _AttributionLine(suggestions: suggestions),
            ],
          ],
        ),
      ),
    );
  }
}

/// One field's chips, or nothing if the dictionary offered none for it.
class _FieldRow extends StatelessWidget {
  const new({
    required this.field,
    required this.suggestions,
    required this.onAccept,
  });

  final SuggestionField field;
  final List<FieldSuggestion> suggestions;
  final void Function(FieldSuggestion) onAccept;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    final label = switch (field) {
      SuggestionField.ipaUk => l10n.fieldIpaUk,
      SuggestionField.ipaUs => l10n.fieldIpaUs,
      SuggestionField.partOfSpeech => l10n.fieldPartOfSpeech,
      SuggestionField.definition => l10n.fieldDefinition,
      SuggestionField.example => l10n.fieldExample,
    };

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final suggestion in suggestions)
                ActionChip(
                  label: Text(
                    _shorten(suggestion.value),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  avatar: suggestion.source == WordSource.offline
                      ? const Icon(Icons.cloud_off, size: 16)
                      : null,
                  tooltip: l10n.lookupApplyLabel(suggestion.value),
                  onPressed: () => onAccept(suggestion),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Definitions can run to a paragraph; a chip is not the place to read one.
  static String _shorten(String value) =>
      value.length <= 80 ? value : '${value.substring(0, 77)}...';
}

/// The credit line and source link CC BY-SA 4.0 requires.
class _AttributionLine extends StatelessWidget {
  const new({required this.suggestions});

  final WordSuggestions suggestions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final url = suggestions.sourceUrl;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      children: <Widget>[
        Text(
          suggestions.attribution!,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (url != null)
          TextButton(
            onPressed: () => launchUrl(
              Uri.parse(url),
              // The user's own browser, never an embedded view.
              mode: LaunchMode.externalApplication,
            ),
            child: Text(l10n.lookupViewSource),
          ),
      ],
    );
  }
}

/// The quiet inline message used for "no results" and for failure (F-006).
///
/// Deliberately not a dialog and not a snackbar: the form must stay completely
/// usable, and the user carries on typing the IPA themselves.
class _Notice extends StatelessWidget {
  const new({required this.text, required this.onDismiss});

  final String text;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadii.cardBorder,
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.lookupDismiss,
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}

/// The failure message, shown in place of the card (F-006).
class LookupFailureNotice extends StatelessWidget {
  /// Creates the notice.
  const new({required this.onDismiss, super.key});

  /// Hides the notice.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) =>
      _Notice(text: AppL10n.of(context).lookupFailed, onDismiss: onDismiss);
}
