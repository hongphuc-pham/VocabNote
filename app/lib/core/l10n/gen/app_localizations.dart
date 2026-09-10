import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application name. Not translated.
  ///
  /// In en, this message translates to:
  /// **'VocabNote'**
  String get appTitle;

  /// Bottom navigation label for the words tab.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get navWords;

  /// Bottom navigation label for the practice tab.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get navPractice;

  /// Bottom navigation label for the lists tab.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get navLists;

  /// App bar title on the words (home) screen.
  ///
  /// In en, this message translates to:
  /// **'My words'**
  String get wordsTitle;

  /// App bar title on the practice hub.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTitle;

  /// App bar title on the lists screen.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get listsTitle;

  /// App bar title on the settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Accessibility label for the icon-only settings button in the app bar.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get settingsOpenLabel;

  /// Accessibility label for an icon-only back button.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get backLabel;

  /// Title of the six-card usage guide. Always present in Settings.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get guideTitle;

  /// Title of the help and feedback screen. Always present in Settings.
  ///
  /// In en, this message translates to:
  /// **'Help & feedback'**
  String get helpTitle;

  /// Title of the backup export/import screen.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupTitle;

  /// Title of the licences and attribution screen.
  ///
  /// In en, this message translates to:
  /// **'Data sources & licences'**
  String get licencesTitle;

  /// Title of the onboarding flow.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingTitle;

  /// Placeholder app bar title for the word detail screen.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get wordDetailTitle;

  /// App bar title when adding or editing a word.
  ///
  /// In en, this message translates to:
  /// **'Edit word'**
  String get wordEditTitle;

  /// App bar title for the IPA highlight editor.
  ///
  /// In en, this message translates to:
  /// **'Edit IPA highlights'**
  String get ipaEditorTitle;

  /// Placeholder app bar title for a single list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listDetailTitle;

  /// App bar title while a practice session is running.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceRunTitle;

  /// App bar title on the session summary screen.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get practiceSummaryTitle;

  /// Heading on a placeholder screen that is not built yet.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonTitle;

  /// Body text on a placeholder screen that is not built yet.
  ///
  /// In en, this message translates to:
  /// **'This screen arrives in a later milestone.'**
  String get comingSoonBody;

  /// Shows which route a placeholder screen is standing in for. Developer-facing, removed once the real screens land.
  ///
  /// In en, this message translates to:
  /// **'Route: {route}'**
  String comingSoonRoute(String route);

  /// Heading shown when a route cannot be resolved.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get routeNotFoundTitle;

  /// Body text shown when a route cannot be resolved.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that page. Let\'s get you back to your words.'**
  String get routeNotFoundBody;

  /// Button that returns the user to the words screen from an unresolved route.
  ///
  /// In en, this message translates to:
  /// **'Go to my words'**
  String get routeNotFoundAction;

  /// Heading when the database on disk was written by a newer version of the app.
  ///
  /// In en, this message translates to:
  /// **'This data was made by a newer VocabNote'**
  String get recoverySchemaTooNewTitle;

  /// Body when the database was written by a newer version. Explains why the app refuses to open it.
  ///
  /// In en, this message translates to:
  /// **'Please update VocabNote to open your words. Opening them with this older version could damage them, so we haven\'t tried.'**
  String get recoverySchemaTooNewBody;

  /// Heading when a database migration failed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t finish updating your words'**
  String get recoveryMigrationTitle;

  /// Body when a migration failed and no backup was restored.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while moving your words to the new version. Your original database is still on your phone, exactly as it was.'**
  String get recoveryMigrationBody;

  /// Body when a migration failed and the pre-migration backup was successfully restored.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while moving your words to the new version, so we put the backup we took beforehand straight back. Nothing was lost.'**
  String get recoveryMigrationBodyRestored;

  /// Heading when the database could not be opened for some other reason.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open your words'**
  String get recoveryGenericTitle;

  /// Body when the database could not be opened for some other reason.
  ///
  /// In en, this message translates to:
  /// **'The file holding your words couldn\'t be read. It\'s still on your phone and nothing has been removed.'**
  String get recoveryGenericBody;

  /// Reassurance shown on the recovery screen. States the app's data-safety promise plainly.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been deleted. VocabNote never resets your database to recover from a problem.'**
  String get recoveryNothingDeleted;

  /// Button that exports whatever can be read, from the recovery screen.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get recoveryExportAction;

  /// Placeholder in the words search field.
  ///
  /// In en, this message translates to:
  /// **'Search your words'**
  String get wordsSearchHint;

  /// Accessibility label for the search icon button.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get wordsSearchLabel;

  /// Accessibility label for the button that closes the search field.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get wordsCloseSearchLabel;

  /// Accessibility label for the sort menu button.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get wordsSortLabel;

  /// Filter chip showing every word. Not a stored list.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter chip showing starred words only.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get filterFavourites;

  /// Filter chip showing words whose practice card is due.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get filterDueToday;

  /// Filter chip showing words with no pronunciation typed yet.
  ///
  /// In en, this message translates to:
  /// **'No IPA yet'**
  String get filterNoIpa;

  /// Sort option: most recently changed first.
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get sortRecent;

  /// Sort option: alphabetical.
  ///
  /// In en, this message translates to:
  /// **'A to Z'**
  String get sortAlphabetical;

  /// Sort option: weakest practice cards first.
  ///
  /// In en, this message translates to:
  /// **'Least known'**
  String get sortLeastKnown;

  /// Label on the floating button that opens the add-word form.
  ///
  /// In en, this message translates to:
  /// **'Add word'**
  String get addWordAction;

  /// Heading of the empty state when the user has no words at all.
  ///
  /// In en, this message translates to:
  /// **'Your first word goes here'**
  String get emptyWordsTitle;

  /// Body of the empty state when the user has no words at all.
  ///
  /// In en, this message translates to:
  /// **'Save a word, write how it sounds, and mark the part you keep getting wrong.'**
  String get emptyWordsBody;

  /// Primary button in the empty state.
  ///
  /// In en, this message translates to:
  /// **'Add a word'**
  String get emptyWordsAction;

  /// Secondary link in the empty state, opening the guide.
  ///
  /// In en, this message translates to:
  /// **'See how it works'**
  String get emptyWordsGuide;

  /// Heading when a filter matches no words.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyFilterTitle;

  /// Body when a filter matches no words.
  ///
  /// In en, this message translates to:
  /// **'No words match this filter. Try another one, or add a new word.'**
  String get emptyFilterBody;

  /// Heading when a search returns nothing.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get emptySearchTitle;

  /// Body when a search returns nothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing matched {term}. Check the spelling, or add it as a new word.'**
  String emptySearchBody(String term);

  /// Button that resets the filter and search.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get emptyFilterClear;

  /// Error state title on the lists grid.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your lists'**
  String get listsLoadFailedTitle;

  /// Error state body on the lists grid. Reassures that nothing was lost.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong reading them. Your lists are still saved.'**
  String get listsLoadFailedBody;

  /// Snackbar shown when creating or editing a list fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save that list. Please try again.'**
  String get listSaveFailed;

  /// Empty state title on a list's detail screen.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this list yet'**
  String get listEmptyTitle;

  /// Empty state body on a list's detail screen.
  ///
  /// In en, this message translates to:
  /// **'Add a word to this list from the word\'s own screen.'**
  String get listEmptyBody;

  /// Name of the flashcard game on the practice hub.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get gameFlashcardTitle;

  /// One-line description of the flashcard game.
  ///
  /// In en, this message translates to:
  /// **'See a word, recall it, then say how it went.'**
  String get gameFlashcardDescription;

  /// Hint on the first card of a session only.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get flashcardTapToReveal;

  /// Screen-reader label for the unflipped card.
  ///
  /// In en, this message translates to:
  /// **'Card front. Tap to reveal the answer.'**
  String get flashcardFrontLabel;

  /// Screen-reader label for the flipped card.
  ///
  /// In en, this message translates to:
  /// **'Card back. Choose how well you knew it.'**
  String get flashcardBackLabel;

  /// Grading button: the user did not know the word.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get gradeAgain;

  /// Grading button: the user knew the word.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get gradeGood;

  /// Grading button: the user knew the word easily.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get gradeEasy;

  /// Empty state title on the practice hub when there are no words.
  ///
  /// In en, this message translates to:
  /// **'Nothing to practise yet'**
  String get practiceEmptyTitle;

  /// Empty state body on the practice hub.
  ///
  /// In en, this message translates to:
  /// **'Add a few words and they\'ll show up here ready to review.'**
  String get practiceEmptyBody;

  /// Button that opens the quick-test config sheet.
  ///
  /// In en, this message translates to:
  /// **'Quick test'**
  String get practiceQuickTest;

  /// Encouraging line when no cards are due. Never a warning (UI-UX 4.6).
  ///
  /// In en, this message translates to:
  /// **'Nothing due right now - a quick test still counts.'**
  String get practiceNothingDue;

  /// Shown when a daily review is started with nothing due.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get practiceNothingDueTitle;

  /// Body when a daily review has no cards.
  ///
  /// In en, this message translates to:
  /// **'Nothing is due today. Try a quick test if you\'d like more.'**
  String get practiceNothingDueBody;

  /// Shown when a quick test finds no matching words.
  ///
  /// In en, this message translates to:
  /// **'No cards here'**
  String get practiceNoCardsTitle;

  /// Body when a quick test pool is empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing matched that choice. Try a different source.'**
  String get practiceNoCardsBody;

  /// Screen-reader label for the close button during a session.
  ///
  /// In en, this message translates to:
  /// **'Close practice'**
  String get practiceCloseLabel;

  /// Title of the confirm dialog when abandoning a daily review.
  ///
  /// In en, this message translates to:
  /// **'Leave this review?'**
  String get practiceAbandonTitle;

  /// Body of the abandon dialog. Says plainly that nothing is lost.
  ///
  /// In en, this message translates to:
  /// **'The cards you\'ve already answered stay answered. The rest keep their current schedule.'**
  String get practiceAbandonBody;

  /// Button that dismisses the abandon dialog.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get practiceAbandonStay;

  /// Button that abandons the session.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get practiceAbandonLeave;

  /// Title of the quick-test config sheet.
  ///
  /// In en, this message translates to:
  /// **'Quick test'**
  String get quickTestTitle;

  /// Label for the source chips in the quick-test sheet.
  ///
  /// In en, this message translates to:
  /// **'Words from'**
  String get quickTestSource;

  /// Label for the size chips in the quick-test sheet.
  ///
  /// In en, this message translates to:
  /// **'How many'**
  String get quickTestSize;

  /// Label for the prompt-side chips in the quick-test sheet.
  ///
  /// In en, this message translates to:
  /// **'Show me first'**
  String get quickTestPromptSide;

  /// Toggle for text-to-speech autoplay during a quick test.
  ///
  /// In en, this message translates to:
  /// **'Say the word when I reveal it'**
  String get quickTestAutoplay;

  /// Button that starts the quick test.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get quickTestStart;

  /// Prompt side: show the headword first.
  ///
  /// In en, this message translates to:
  /// **'The word'**
  String get promptSideWord;

  /// Prompt side: show the transcription first.
  ///
  /// In en, this message translates to:
  /// **'The sounds'**
  String get promptSideIpa;

  /// Prompt side: show the definition first.
  ///
  /// In en, this message translates to:
  /// **'The meaning'**
  String get promptSideMeaning;

  /// Button that starts a daily review, with how many cards are due.
  ///
  /// In en, this message translates to:
  /// **'Daily review ({count} due)'**
  String practiceDailyReview(int count);

  /// Says how many words are still needed before a game unlocks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 more word to unlock this} other{Add {count} more words to unlock this}}'**
  String practiceLockedHint(int count);

  /// The All size chip, naming the hard cap out loud.
  ///
  /// In en, this message translates to:
  /// **'All (max {max})'**
  String quickTestSizeAll(int max);

  /// Empty state title on the lists grid.
  ///
  /// In en, this message translates to:
  /// **'No lists yet'**
  String get listsEmptyTitle;

  /// Empty state body on the lists grid.
  ///
  /// In en, this message translates to:
  /// **'Lists group words however you like - a course, a topic, the sounds you keep getting wrong.'**
  String get listsEmptyBody;

  /// Button that creates a list.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get newListAction;

  /// Title of the sheet that creates a list.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get createListTitle;

  /// Title of the sheet that renames or recolours a list.
  ///
  /// In en, this message translates to:
  /// **'Edit list'**
  String get editListTitle;

  /// Text field label for a list name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get listNameLabel;

  /// Example list name shown in the empty field.
  ///
  /// In en, this message translates to:
  /// **'IELTS speaking'**
  String get listNameHint;

  /// Validation message when a list name is blank.
  ///
  /// In en, this message translates to:
  /// **'Give the list a name.'**
  String get listNameRequired;

  /// Menu item that moves a list one place earlier in the grid.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveListUpAction;

  /// Menu item that moves a list one place later in the grid.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveListDownAction;

  /// Menu item that edits a list.
  ///
  /// In en, this message translates to:
  /// **'Rename or recolour'**
  String get renameListAction;

  /// Menu item that deletes a list.
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get deleteListAction;

  /// Title of the delete-list confirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete this list?'**
  String get deleteListTitle;

  /// Body of the delete-list confirmation. States plainly that words survive (F-042).
  ///
  /// In en, this message translates to:
  /// **'The list goes, but every word in it stays in your words.'**
  String get deleteListBody;

  /// Screen-reader label for the button that opens a list's actions.
  ///
  /// In en, this message translates to:
  /// **'Actions for {name}'**
  String listActionsLabel(String name);

  /// App bar action on a list's detail screen.
  ///
  /// In en, this message translates to:
  /// **'Practise this list'**
  String get practiseListAction;

  /// Menu item that edits an existing note.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNoteAction;

  /// Button that saves an edited note.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveNoteAction;

  /// Word count on a list card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No words} =1{1 word} other{{count} words}}'**
  String listWordCount(int count);

  /// Due-today badge on a list card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 due} other{{count} due}}'**
  String listDueCount(int count);

  /// Screen-reader label for a filter chip that shows a word count.
  ///
  /// In en, this message translates to:
  /// **'{label}, {count, plural, =1{1 word} other{{count} words}}'**
  String filterCountLabel(String label, int count);

  /// Screen-reader label for the note count on a word row.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 note} other{{count} notes}}'**
  String wordNoteCountLabel(int count);

  /// Accessibility label for the star button when the word is not a favourite.
  ///
  /// In en, this message translates to:
  /// **'Add {word} to favourites'**
  String wordFavouriteLabel(String word);

  /// Accessibility label for the star button when the word is already a favourite.
  ///
  /// In en, this message translates to:
  /// **'Remove {word} from favourites'**
  String wordUnfavouriteLabel(String word);

  /// Heading when the words list fails to load.
  ///
  /// In en, this message translates to:
  /// **'We could not load your words'**
  String get wordsLoadFailedTitle;

  /// Body when the words list fails to load.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong reading your database. Nothing has been lost.'**
  String get wordsLoadFailedBody;

  /// Generic retry button.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryAction;

  /// Menu item that deletes a word.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteWordAction;

  /// Snackbar shown after deleting a word.
  ///
  /// In en, this message translates to:
  /// **'Deleted {word}'**
  String wordDeletedSnack(String word);

  /// Button that restores a just-deleted word.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// App bar title when adding a word.
  ///
  /// In en, this message translates to:
  /// **'Add word'**
  String get editorTitleAdd;

  /// App bar title when editing a word.
  ///
  /// In en, this message translates to:
  /// **'Edit word'**
  String get editorTitleEdit;

  /// App bar action that saves the form.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// Generic cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// Label for the headword field.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get fieldWord;

  /// Hint for the headword field.
  ///
  /// In en, this message translates to:
  /// **'The word you are studying'**
  String get fieldWordHint;

  /// Button that queries the dictionary for the typed word.
  ///
  /// In en, this message translates to:
  /// **'Look up'**
  String get lookUpAction;

  /// Quiet subtitle under the Look up button.
  ///
  /// In en, this message translates to:
  /// **'optional - typing it yourself helps you remember'**
  String get lookUpHint;

  /// Label for the British pronunciation field.
  ///
  /// In en, this message translates to:
  /// **'IPA (UK)'**
  String get fieldIpaUk;

  /// Label for the American pronunciation field.
  ///
  /// In en, this message translates to:
  /// **'IPA (US)'**
  String get fieldIpaUs;

  /// Label for the part-of-speech chips.
  ///
  /// In en, this message translates to:
  /// **'Part of speech'**
  String get fieldPartOfSpeech;

  /// Label for the definition field.
  ///
  /// In en, this message translates to:
  /// **'Definition'**
  String get fieldDefinition;

  /// Label for the example sentence field.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get fieldExample;

  /// Label for the first-note field, shown only when adding.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get fieldNote;

  /// Hint for the first-note field.
  ///
  /// In en, this message translates to:
  /// **'Something to remind yourself'**
  String get fieldNoteHint;

  /// Label for the list-membership chips.
  ///
  /// In en, this message translates to:
  /// **'Add to lists'**
  String get fieldLists;

  /// Shown in place of list chips when the user has no lists.
  ///
  /// In en, this message translates to:
  /// **'No lists yet'**
  String get fieldListsEmpty;

  /// Part-of-speech chip.
  ///
  /// In en, this message translates to:
  /// **'noun'**
  String get posNoun;

  /// Part-of-speech chip.
  ///
  /// In en, this message translates to:
  /// **'verb'**
  String get posVerb;

  /// Part-of-speech chip.
  ///
  /// In en, this message translates to:
  /// **'adjective'**
  String get posAdjective;

  /// Part-of-speech chip.
  ///
  /// In en, this message translates to:
  /// **'adverb'**
  String get posAdverb;

  /// Part-of-speech chip for anything else.
  ///
  /// In en, this message translates to:
  /// **'other'**
  String get posOther;

  /// Accessibility label for the row of IPA symbol buttons above the keyboard.
  ///
  /// In en, this message translates to:
  /// **'IPA symbols'**
  String get ipaKeyboardLabel;

  /// Accessibility label for one IPA symbol button.
  ///
  /// In en, this message translates to:
  /// **'Insert {symbol}'**
  String ipaSymbolLabel(String symbol);

  /// Non-blocking banner shown when the typed word already exists.
  ///
  /// In en, this message translates to:
  /// **'You already have {word}'**
  String duplicateBanner(String word);

  /// Button in the duplicate banner that opens the existing word.
  ///
  /// In en, this message translates to:
  /// **'Open it'**
  String get duplicateBannerOpen;

  /// Button in the duplicate banner that dismisses it and lets the user save anyway.
  ///
  /// In en, this message translates to:
  /// **'Keep both'**
  String get duplicateBannerDismiss;

  /// Shown while a dictionary look-up is in flight.
  ///
  /// In en, this message translates to:
  /// **'Looking up {word}...'**
  String lookupSearching(String word);

  /// Heading of the look-up results card.
  ///
  /// In en, this message translates to:
  /// **'From the dictionary'**
  String get lookupResultsTitle;

  /// Shown when the dictionary has no entry.
  ///
  /// In en, this message translates to:
  /// **'No entry found for {word}. You can still type it in yourself.'**
  String lookupNoResults(String word);

  /// Quiet inline message when a look-up fails. The form stays fully usable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the dictionary - you can still type it in.'**
  String get lookupFailed;

  /// Button that hides the look-up results card.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get lookupDismiss;

  /// Link to the Wiktionary page a result came from.
  ///
  /// In en, this message translates to:
  /// **'View source'**
  String get lookupViewSource;

  /// Attribution line under look-up results.
  ///
  /// In en, this message translates to:
  /// **'{source} - {license}'**
  String lookupAttributionLine(String source, String license);

  /// Badge on a suggestion that came from the bundled offline dictionary.
  ///
  /// In en, this message translates to:
  /// **'offline'**
  String get lookupOfflineBadge;

  /// Accessibility label for a suggestion chip.
  ///
  /// In en, this message translates to:
  /// **'Use {value}'**
  String lookupApplyLabel(String value);

  /// Title of the dialog shown before a suggestion overwrites typed text.
  ///
  /// In en, this message translates to:
  /// **'Replace what you typed?'**
  String get overwriteTitle;

  /// Body of the overwrite confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'This will replace {current} with {replacement}.'**
  String overwriteBody(String current, String replacement);

  /// Confirm button in the overwrite dialog.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get overwriteReplace;

  /// Cancel button in the overwrite dialog.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get overwriteKeep;

  /// Short label on the British transcription row of the word detail screen.
  ///
  /// In en, this message translates to:
  /// **'UK'**
  String get detailAccentUk;

  /// Short label on the American transcription row of the word detail screen.
  ///
  /// In en, this message translates to:
  /// **'US'**
  String get detailAccentUs;

  /// Accessibility label for the play button on a transcription row.
  ///
  /// In en, this message translates to:
  /// **'Play {word} in {accent}'**
  String detailPlayLabel(String word, String accent);

  /// Accessibility label for the slow replay, reached by long-pressing play.
  ///
  /// In en, this message translates to:
  /// **'Play {word} slowly in {accent}'**
  String detailPlaySlowLabel(String word, String accent);

  /// Accessibility label for the play button while it is speaking.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get detailStopLabel;

  /// Announced while a word is being spoken.
  ///
  /// In en, this message translates to:
  /// **'Speaking {word}'**
  String detailPlayingLabel(String word);

  /// Hint under the play buttons explaining the long-press slow replay.
  ///
  /// In en, this message translates to:
  /// **'Hold to hear it slowly'**
  String get detailSlowHint;

  /// Shown when the device speech engine could not speak the word.
  ///
  /// In en, this message translates to:
  /// **'This device has no speech voice available.'**
  String get detailSpeechFailed;

  /// Button that opens the operating system voice settings.
  ///
  /// In en, this message translates to:
  /// **'Voice settings'**
  String get detailSpeechSettingsAction;

  /// Heading shown on word detail when neither transcription is filled in.
  ///
  /// In en, this message translates to:
  /// **'No pronunciation yet'**
  String get detailNoIpaTitle;

  /// Body shown on word detail when neither transcription is filled in.
  ///
  /// In en, this message translates to:
  /// **'Add a transcription to hear this word and to colour the sounds you find hard.'**
  String get detailNoIpaBody;

  /// Button that opens the word editor to add a transcription.
  ///
  /// In en, this message translates to:
  /// **'Add pronunciation'**
  String get detailAddIpaAction;

  /// Button that opens the IPA highlight editor from word detail.
  ///
  /// In en, this message translates to:
  /// **'Edit IPA highlights'**
  String get detailEditHighlightsAction;

  /// Heading of the notes section on word detail.
  ///
  /// In en, this message translates to:
  /// **'My notes'**
  String get detailNotesHeading;

  /// Button that adds a note to the word.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get detailAddNoteAction;

  /// Shown in the notes section when the word has none.
  ///
  /// In en, this message translates to:
  /// **'No notes yet.'**
  String get detailNoNotesBody;

  /// Accessibility label for removing one note.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get detailNoteDeleteAction;

  /// Confirmation shown after a note is removed.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get detailNoteDeletedSnack;

  /// Title of the sheet that adds a note.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get detailNoteHeading;

  /// Heading shown when the word being viewed no longer exists.
  ///
  /// In en, this message translates to:
  /// **'This word is gone'**
  String get detailNotFoundTitle;

  /// Body shown when the word being viewed no longer exists.
  ///
  /// In en, this message translates to:
  /// **'It was deleted. You can undo a deletion from the words list for a few seconds.'**
  String get detailNotFoundBody;

  /// Heading shown when the word detail screen fails to load.
  ///
  /// In en, this message translates to:
  /// **'Could not open this word'**
  String get detailLoadFailedTitle;

  /// Body shown when the word detail screen fails to load.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong reading it from your device.'**
  String get detailLoadFailedBody;

  /// Button that opens the word editor from word detail.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get detailEditAction;

  /// Heading above the list of labelled IPA highlights on word detail.
  ///
  /// In en, this message translates to:
  /// **'Sounds you marked'**
  String get detailLegendHeading;

  /// One legend line: the colour name and the label the user wrote.
  ///
  /// In en, this message translates to:
  /// **'{color}: {label}'**
  String detailLegendEntry(String color, String label);

  /// Accessibility label for a tappable legend line.
  ///
  /// In en, this message translates to:
  /// **'Show {label} in the transcription'**
  String detailLegendJumpLabel(String label);

  /// Name of the amber IPA highlight colour. Shown as text so colour is never the only cue.
  ///
  /// In en, this message translates to:
  /// **'amber'**
  String get ipaColorAmber;

  /// Name of the coral IPA highlight colour.
  ///
  /// In en, this message translates to:
  /// **'coral'**
  String get ipaColorCoral;

  /// Name of the violet IPA highlight colour.
  ///
  /// In en, this message translates to:
  /// **'violet'**
  String get ipaColorViolet;

  /// Name of the teal IPA highlight colour.
  ///
  /// In en, this message translates to:
  /// **'teal'**
  String get ipaColorTeal;

  /// Name of the blue IPA highlight colour.
  ///
  /// In en, this message translates to:
  /// **'blue'**
  String get ipaColorBlue;

  /// Button that opens the word on dictionary.cambridge.org in the browser.
  ///
  /// In en, this message translates to:
  /// **'Open in Cambridge Dictionary'**
  String get detailCambridgeAction;

  /// Shown when no app on the device could open the dictionary link.
  ///
  /// In en, this message translates to:
  /// **'Could not open your browser.'**
  String get detailCambridgeFailed;

  /// Instruction at the top of the IPA highlight editor.
  ///
  /// In en, this message translates to:
  /// **'Tap a symbol, or drag across several, then choose a colour.'**
  String get ipaEditorIntro;

  /// Announced when a run of IPA symbols is selected. UI-UX section 4.4.
  ///
  /// In en, this message translates to:
  /// **'selected {symbols}'**
  String ipaEditorSelectedLabel(String symbols);

  /// Shown where the selection would be announced, before anything is chosen.
  ///
  /// In en, this message translates to:
  /// **'Nothing selected yet'**
  String get ipaEditorNothingSelected;

  /// App bar action that saves the highlight session.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ipaEditorDoneAction;

  /// App bar action that steps back one change in the editor.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get ipaEditorUndoAction;

  /// Title of the sheet that colours the selected run.
  ///
  /// In en, this message translates to:
  /// **'Colour this sound'**
  String get ipaEditorColorHeading;

  /// Hint on the optional label field in the colour sheet.
  ///
  /// In en, this message translates to:
  /// **'Why is it hard? (optional)'**
  String get ipaEditorLabelHint;

  /// Button that removes the highlight being edited.
  ///
  /// In en, this message translates to:
  /// **'Delete highlight'**
  String get ipaEditorDeleteAction;

  /// Accessibility label for one colour swatch.
  ///
  /// In en, this message translates to:
  /// **'Use {color}'**
  String ipaEditorColorLabel(String color);

  /// Shown when writing the highlight session to the database failed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your highlights.'**
  String get ipaEditorSaveFailed;

  /// Heading when the editor is opened for a word with no transcription.
  ///
  /// In en, this message translates to:
  /// **'Nothing to highlight yet'**
  String get ipaEditorNoIpaTitle;

  /// Body when the editor is opened for a word with no transcription.
  ///
  /// In en, this message translates to:
  /// **'Add a transcription first, then come back to colour the sounds you find hard.'**
  String get ipaEditorNoIpaBody;

  /// Title of the confirmation shown when leaving the editor unsaved.
  ///
  /// In en, this message translates to:
  /// **'Discard your colours?'**
  String get ipaEditorDiscardTitle;

  /// Body of the confirmation shown when leaving the editor unsaved.
  ///
  /// In en, this message translates to:
  /// **'You have changes that have not been saved.'**
  String get ipaEditorDiscardBody;

  /// Button that leaves the editor without saving.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get ipaEditorDiscardAction;

  /// Button that returns to the editor instead of discarding.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get ipaEditorKeepEditingAction;

  /// Title of the dialog shown when an IPA edit invalidates highlights (F-023).
  ///
  /// In en, this message translates to:
  /// **'Some highlights no longer fit'**
  String get ipaRevalidateTitle;

  /// Body of the F-023 confirmation, listing how many highlights would be dropped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{One coloured run no longer matches the new transcription and will be removed.} other{{count} coloured runs no longer match the new transcription and will be removed.}}'**
  String ipaRevalidateBody(int count);

  /// Button that accepts dropping the highlights that no longer fit.
  ///
  /// In en, this message translates to:
  /// **'Remove them'**
  String get ipaRevalidateConfirm;

  /// Button that returns to the word form instead of dropping highlights.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get ipaRevalidateCancel;

  /// One-time notice shown when the preferred speech voice is unavailable.
  ///
  /// In en, this message translates to:
  /// **'This device has no British English voice, so words are spoken in the closest voice it does have. You can add voices in your device settings, under Text-to-speech.'**
  String get voiceFallbackNotice;

  /// Button that dismisses the one-time voice notice for good.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get voiceFallbackDismiss;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
