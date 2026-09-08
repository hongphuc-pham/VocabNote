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
}
