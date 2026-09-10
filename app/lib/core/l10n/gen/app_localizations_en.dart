// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'VocabNote';

  @override
  String get navWords => 'Words';

  @override
  String get navPractice => 'Practice';

  @override
  String get navLists => 'Lists';

  @override
  String get wordsTitle => 'My words';

  @override
  String get practiceTitle => 'Practice';

  @override
  String get listsTitle => 'Lists';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsOpenLabel => 'Open settings';

  @override
  String get backLabel => 'Go back';

  @override
  String get guideTitle => 'How to use';

  @override
  String get helpTitle => 'Help & feedback';

  @override
  String get backupTitle => 'Backup';

  @override
  String get licencesTitle => 'Data sources & licences';

  @override
  String get onboardingTitle => 'Welcome';

  @override
  String get wordDetailTitle => 'Word';

  @override
  String get wordEditTitle => 'Edit word';

  @override
  String get ipaEditorTitle => 'Edit IPA highlights';

  @override
  String get listDetailTitle => 'List';

  @override
  String get practiceRunTitle => 'Practice';

  @override
  String get practiceSummaryTitle => 'Summary';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonBody => 'This screen arrives in a later milestone.';

  @override
  String comingSoonRoute(String route) {
    return 'Route: $route';
  }

  @override
  String get routeNotFoundTitle => 'Page not found';

  @override
  String get routeNotFoundBody =>
      'We couldn\'t find that page. Let\'s get you back to your words.';

  @override
  String get routeNotFoundAction => 'Go to my words';

  @override
  String get recoverySchemaTooNewTitle =>
      'This data was made by a newer VocabNote';

  @override
  String get recoverySchemaTooNewBody =>
      'Please update VocabNote to open your words. Opening them with this older version could damage them, so we haven\'t tried.';

  @override
  String get recoveryMigrationTitle =>
      'We couldn\'t finish updating your words';

  @override
  String get recoveryMigrationBody =>
      'Something went wrong while moving your words to the new version. Your original database is still on your phone, exactly as it was.';

  @override
  String get recoveryMigrationBodyRestored =>
      'Something went wrong while moving your words to the new version, so we put the backup we took beforehand straight back. Nothing was lost.';

  @override
  String get recoveryGenericTitle => 'We couldn\'t open your words';

  @override
  String get recoveryGenericBody =>
      'The file holding your words couldn\'t be read. It\'s still on your phone and nothing has been removed.';

  @override
  String get recoveryNothingDeleted =>
      'Nothing has been deleted. VocabNote never resets your database to recover from a problem.';

  @override
  String get recoveryExportAction => 'Export my data';

  @override
  String get wordsSearchHint => 'Search your words';

  @override
  String get wordsSearchLabel => 'Search';

  @override
  String get wordsCloseSearchLabel => 'Close search';

  @override
  String get wordsSortLabel => 'Sort';

  @override
  String get filterAll => 'All';

  @override
  String get filterFavourites => 'Favourites';

  @override
  String get filterDueToday => 'Due today';

  @override
  String get filterNoIpa => 'No IPA yet';

  @override
  String get sortRecent => 'Recently updated';

  @override
  String get sortAlphabetical => 'A to Z';

  @override
  String get sortLeastKnown => 'Least known';

  @override
  String get addWordAction => 'Add word';

  @override
  String get emptyWordsTitle => 'Your first word goes here';

  @override
  String get emptyWordsBody =>
      'Save a word, write how it sounds, and mark the part you keep getting wrong.';

  @override
  String get emptyWordsAction => 'Add a word';

  @override
  String get emptyWordsGuide => 'See how it works';

  @override
  String get emptyFilterTitle => 'Nothing here yet';

  @override
  String get emptyFilterBody =>
      'No words match this filter. Try another one, or add a new word.';

  @override
  String get emptySearchTitle => 'No matches';

  @override
  String emptySearchBody(String term) {
    return 'Nothing matched $term. Check the spelling, or add it as a new word.';
  }

  @override
  String get emptyFilterClear => 'Clear filters';

  @override
  String get listsLoadFailedTitle => 'Couldn\'t load your lists';

  @override
  String get listsLoadFailedBody =>
      'Something went wrong reading them. Your lists are still saved.';

  @override
  String get listSaveFailed => 'Couldn\'t save that list. Please try again.';

  @override
  String get listEmptyTitle => 'Nothing in this list yet';

  @override
  String get listEmptyBody =>
      'Add a word to this list from the word\'s own screen.';

  @override
  String get gameFlashcardTitle => 'Flashcards';

  @override
  String get gameFlashcardDescription =>
      'See a word, recall it, then say how it went.';

  @override
  String get flashcardTapToReveal => 'Tap to reveal';

  @override
  String get flashcardFrontLabel => 'Card front. Tap to reveal the answer.';

  @override
  String get flashcardBackLabel => 'Card back. Choose how well you knew it.';

  @override
  String get gradeAgain => 'Again';

  @override
  String get gradeGood => 'Good';

  @override
  String get gradeEasy => 'Easy';

  @override
  String get listsEmptyTitle => 'No lists yet';

  @override
  String get listsEmptyBody =>
      'Lists group words however you like - a course, a topic, the sounds you keep getting wrong.';

  @override
  String get newListAction => 'New list';

  @override
  String get createListTitle => 'New list';

  @override
  String get editListTitle => 'Edit list';

  @override
  String get listNameLabel => 'Name';

  @override
  String get listNameHint => 'IELTS speaking';

  @override
  String get listNameRequired => 'Give the list a name.';

  @override
  String get moveListUpAction => 'Move up';

  @override
  String get moveListDownAction => 'Move down';

  @override
  String get renameListAction => 'Rename or recolour';

  @override
  String get deleteListAction => 'Delete list';

  @override
  String get deleteListTitle => 'Delete this list?';

  @override
  String get deleteListBody =>
      'The list goes, but every word in it stays in your words.';

  @override
  String listActionsLabel(String name) {
    return 'Actions for $name';
  }

  @override
  String get practiseListAction => 'Practise this list';

  @override
  String get editNoteAction => 'Edit note';

  @override
  String get saveNoteAction => 'Save';

  @override
  String listWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
      zero: 'No words',
    );
    return '$_temp0';
  }

  @override
  String listDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count due',
      one: '1 due',
    );
    return '$_temp0';
  }

  @override
  String filterCountLabel(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return '$label, $_temp0';
  }

  @override
  String wordNoteCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
    );
    return '$_temp0';
  }

  @override
  String wordFavouriteLabel(String word) {
    return 'Add $word to favourites';
  }

  @override
  String wordUnfavouriteLabel(String word) {
    return 'Remove $word from favourites';
  }

  @override
  String get wordsLoadFailedTitle => 'We could not load your words';

  @override
  String get wordsLoadFailedBody =>
      'Something went wrong reading your database. Nothing has been lost.';

  @override
  String get retryAction => 'Try again';

  @override
  String get deleteWordAction => 'Delete';

  @override
  String wordDeletedSnack(String word) {
    return 'Deleted $word';
  }

  @override
  String get undoAction => 'Undo';

  @override
  String get editorTitleAdd => 'Add word';

  @override
  String get editorTitleEdit => 'Edit word';

  @override
  String get saveAction => 'Save';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get fieldWord => 'Word';

  @override
  String get fieldWordHint => 'The word you are studying';

  @override
  String get lookUpAction => 'Look up';

  @override
  String get lookUpHint => 'optional - typing it yourself helps you remember';

  @override
  String get fieldIpaUk => 'IPA (UK)';

  @override
  String get fieldIpaUs => 'IPA (US)';

  @override
  String get fieldPartOfSpeech => 'Part of speech';

  @override
  String get fieldDefinition => 'Definition';

  @override
  String get fieldExample => 'Example';

  @override
  String get fieldNote => 'Note';

  @override
  String get fieldNoteHint => 'Something to remind yourself';

  @override
  String get fieldLists => 'Add to lists';

  @override
  String get fieldListsEmpty => 'No lists yet';

  @override
  String get posNoun => 'noun';

  @override
  String get posVerb => 'verb';

  @override
  String get posAdjective => 'adjective';

  @override
  String get posAdverb => 'adverb';

  @override
  String get posOther => 'other';

  @override
  String get ipaKeyboardLabel => 'IPA symbols';

  @override
  String ipaSymbolLabel(String symbol) {
    return 'Insert $symbol';
  }

  @override
  String duplicateBanner(String word) {
    return 'You already have $word';
  }

  @override
  String get duplicateBannerOpen => 'Open it';

  @override
  String get duplicateBannerDismiss => 'Keep both';

  @override
  String lookupSearching(String word) {
    return 'Looking up $word...';
  }

  @override
  String get lookupResultsTitle => 'From the dictionary';

  @override
  String lookupNoResults(String word) {
    return 'No entry found for $word. You can still type it in yourself.';
  }

  @override
  String get lookupFailed =>
      'Could not reach the dictionary - you can still type it in.';

  @override
  String get lookupDismiss => 'Dismiss';

  @override
  String get lookupViewSource => 'View source';

  @override
  String lookupAttributionLine(String source, String license) {
    return '$source - $license';
  }

  @override
  String get lookupOfflineBadge => 'offline';

  @override
  String lookupApplyLabel(String value) {
    return 'Use $value';
  }

  @override
  String get overwriteTitle => 'Replace what you typed?';

  @override
  String overwriteBody(String current, String replacement) {
    return 'This will replace $current with $replacement.';
  }

  @override
  String get overwriteReplace => 'Replace';

  @override
  String get overwriteKeep => 'Keep mine';

  @override
  String get detailAccentUk => 'UK';

  @override
  String get detailAccentUs => 'US';

  @override
  String detailPlayLabel(String word, String accent) {
    return 'Play $word in $accent';
  }

  @override
  String detailPlaySlowLabel(String word, String accent) {
    return 'Play $word slowly in $accent';
  }

  @override
  String get detailStopLabel => 'Stop';

  @override
  String detailPlayingLabel(String word) {
    return 'Speaking $word';
  }

  @override
  String get detailSlowHint => 'Hold to hear it slowly';

  @override
  String get detailSpeechFailed => 'This device has no speech voice available.';

  @override
  String get detailSpeechSettingsAction => 'Voice settings';

  @override
  String get detailNoIpaTitle => 'No pronunciation yet';

  @override
  String get detailNoIpaBody =>
      'Add a transcription to hear this word and to colour the sounds you find hard.';

  @override
  String get detailAddIpaAction => 'Add pronunciation';

  @override
  String get detailEditHighlightsAction => 'Edit IPA highlights';

  @override
  String get detailNotesHeading => 'My notes';

  @override
  String get detailAddNoteAction => 'Add';

  @override
  String get detailNoNotesBody => 'No notes yet.';

  @override
  String get detailNoteDeleteAction => 'Delete note';

  @override
  String get detailNoteDeletedSnack => 'Note deleted';

  @override
  String get detailNoteHeading => 'Add a note';

  @override
  String get detailNotFoundTitle => 'This word is gone';

  @override
  String get detailNotFoundBody =>
      'It was deleted. You can undo a deletion from the words list for a few seconds.';

  @override
  String get detailLoadFailedTitle => 'Could not open this word';

  @override
  String get detailLoadFailedBody =>
      'Something went wrong reading it from your device.';

  @override
  String get detailEditAction => 'Edit';

  @override
  String get detailLegendHeading => 'Sounds you marked';

  @override
  String detailLegendEntry(String color, String label) {
    return '$color: $label';
  }

  @override
  String detailLegendJumpLabel(String label) {
    return 'Show $label in the transcription';
  }

  @override
  String get ipaColorAmber => 'amber';

  @override
  String get ipaColorCoral => 'coral';

  @override
  String get ipaColorViolet => 'violet';

  @override
  String get ipaColorTeal => 'teal';

  @override
  String get ipaColorBlue => 'blue';

  @override
  String get detailCambridgeAction => 'Open in Cambridge Dictionary';

  @override
  String get detailCambridgeFailed => 'Could not open your browser.';

  @override
  String get ipaEditorIntro =>
      'Tap a symbol, or drag across several, then choose a colour.';

  @override
  String ipaEditorSelectedLabel(String symbols) {
    return 'selected $symbols';
  }

  @override
  String get ipaEditorNothingSelected => 'Nothing selected yet';

  @override
  String get ipaEditorDoneAction => 'Done';

  @override
  String get ipaEditorUndoAction => 'Undo';

  @override
  String get ipaEditorColorHeading => 'Colour this sound';

  @override
  String get ipaEditorLabelHint => 'Why is it hard? (optional)';

  @override
  String get ipaEditorDeleteAction => 'Delete highlight';

  @override
  String ipaEditorColorLabel(String color) {
    return 'Use $color';
  }

  @override
  String get ipaEditorSaveFailed => 'Could not save your highlights.';

  @override
  String get ipaEditorNoIpaTitle => 'Nothing to highlight yet';

  @override
  String get ipaEditorNoIpaBody =>
      'Add a transcription first, then come back to colour the sounds you find hard.';

  @override
  String get ipaEditorDiscardTitle => 'Discard your colours?';

  @override
  String get ipaEditorDiscardBody =>
      'You have changes that have not been saved.';

  @override
  String get ipaEditorDiscardAction => 'Discard';

  @override
  String get ipaEditorKeepEditingAction => 'Keep editing';

  @override
  String get ipaRevalidateTitle => 'Some highlights no longer fit';

  @override
  String ipaRevalidateBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count coloured runs no longer match the new transcription and will be removed.',
      one: 'One coloured run no longer matches the new transcription and will be removed.',
    );
    return '$_temp0';
  }

  @override
  String get ipaRevalidateConfirm => 'Remove them';

  @override
  String get ipaRevalidateCancel => 'Keep editing';

  @override
  String get voiceFallbackNotice =>
      'This device has no British English voice, so words are spoken in the closest voice it does have. You can add voices in your device settings, under Text-to-speech.';

  @override
  String get voiceFallbackDismiss => 'Got it';
}
