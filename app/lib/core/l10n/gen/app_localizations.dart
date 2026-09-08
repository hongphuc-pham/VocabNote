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
