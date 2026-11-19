import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('pl'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @accent_color.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get accent_color;

  /// No description provided for @add_flashcards.
  ///
  /// In en, this message translates to:
  /// **'Add Flashcards'**
  String get add_flashcards;

  /// No description provided for @add_flashcards_description.
  ///
  /// In en, this message translates to:
  /// **'Take a image or select images from gallery to make flashcard from them.'**
  String get add_flashcards_description;

  /// No description provided for @add_images.
  ///
  /// In en, this message translates to:
  /// **'Add images'**
  String get add_images;

  /// No description provided for @add_quiz.
  ///
  /// In en, this message translates to:
  /// **'Add quiz'**
  String get add_quiz;

  /// No description provided for @add_quiz_description.
  ///
  /// In en, this message translates to:
  /// **'Take a image or select images from gallery and/or select flashcards to make a quiz from them.'**
  String get add_quiz_description;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @change_student_data.
  ///
  /// In en, this message translates to:
  /// **'Change student data'**
  String get change_student_data;

  /// No description provided for @change_student_name.
  ///
  /// In en, this message translates to:
  /// **'Change student name'**
  String get change_student_name;

  /// No description provided for @chat_removal_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this chat?'**
  String get chat_removal_confirmation;

  /// No description provided for @check_answer.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get check_answer;

  /// No description provided for @configure_ai.
  ///
  /// In en, this message translates to:
  /// **'Configure AI'**
  String get configure_ai;

  /// No description provided for @configure_ai_description.
  ///
  /// In en, this message translates to:
  /// **'Get an API key and a model name from OpenRouter and enter them here.'**
  String get configure_ai_description;

  /// No description provided for @enter_student_data.
  ///
  /// In en, this message translates to:
  /// **'Enter student data'**
  String get enter_student_data;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @exit_quiz.
  ///
  /// In en, this message translates to:
  /// **'Exit quiz'**
  String get exit_quiz;

  /// No description provided for @exit_quiz_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the quiz?'**
  String get exit_quiz_confirmation;

  /// No description provided for @flashcard.
  ///
  /// In en, this message translates to:
  /// **'Flashcard'**
  String get flashcard;

  /// No description provided for @flashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcards;

  /// No description provided for @flashcards_description.
  ///
  /// In en, this message translates to:
  /// **'Scan the materials and create flashcards from them, or check out existing ones.'**
  String get flashcards_description;

  /// No description provided for @flashcards_removal_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove these flashcards?'**
  String get flashcards_removal_confirmation;

  /// No description provided for @from_flashcards.
  ///
  /// In en, this message translates to:
  /// **'From flashcards'**
  String get from_flashcards;

  /// No description provided for @from_images.
  ///
  /// In en, this message translates to:
  /// **'From images'**
  String get from_images;

  /// No description provided for @generating_answer.
  ///
  /// In en, this message translates to:
  /// **'Generating answer...'**
  String get generating_answer;

  /// No description provided for @generating_flashcards.
  ///
  /// In en, this message translates to:
  /// **'Generating flashcards'**
  String get generating_flashcards;

  /// No description provided for @generating_quiz.
  ///
  /// In en, this message translates to:
  /// **'Generating quiz'**
  String get generating_quiz;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @invalid_response_from_model.
  ///
  /// In en, this message translates to:
  /// **'Invalid response from model'**
  String get invalid_response_from_model;

  /// No description provided for @lang.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get lang;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @new_chat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get new_chat;

  /// No description provided for @new_chat_description.
  ///
  /// In en, this message translates to:
  /// **'Take a image or select images to make AI analyse them and help you with the task.'**
  String get new_chat_description;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @no_added_images.
  ///
  /// In en, this message translates to:
  /// **'No added images'**
  String get no_added_images;

  /// No description provided for @no_added_images_or_flashcards.
  ///
  /// In en, this message translates to:
  /// **'No added images or flashcards'**
  String get no_added_images_or_flashcards;

  /// No description provided for @no_chats.
  ///
  /// In en, this message translates to:
  /// **'No chats'**
  String get no_chats;

  /// No description provided for @no_flashcards.
  ///
  /// In en, this message translates to:
  /// **'No flashcards'**
  String get no_flashcards;

  /// No description provided for @no_quizzes.
  ///
  /// In en, this message translates to:
  /// **'No quizzes'**
  String get no_quizzes;

  /// No description provided for @no_response_from_model.
  ///
  /// In en, this message translates to:
  /// **'No response from model'**
  String get no_response_from_model;

  /// No description provided for @not_solved_yet.
  ///
  /// In en, this message translates to:
  /// **'Not solved yet'**
  String get not_solved_yet;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @please_select_answer.
  ///
  /// In en, this message translates to:
  /// **'Please select an answer'**
  String get please_select_answer;

  /// No description provided for @press_next_to_complete.
  ///
  /// In en, this message translates to:
  /// **'Press \"Next\" to complete'**
  String get press_next_to_complete;

  /// No description provided for @primary_school.
  ///
  /// In en, this message translates to:
  /// **'Primary school'**
  String get primary_school;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @quiz_removal_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this quiz?'**
  String get quiz_removal_confirmation;

  /// No description provided for @quizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzes;

  /// No description provided for @quizzes_description.
  ///
  /// In en, this message translates to:
  /// **'Scan the materials or select flashcards to make a quiz and check your knowledge.'**
  String get quizzes_description;

  /// No description provided for @remove_chat.
  ///
  /// In en, this message translates to:
  /// **'Remove chat'**
  String get remove_chat;

  /// No description provided for @remove_flashcards.
  ///
  /// In en, this message translates to:
  /// **'Remove flashcards'**
  String get remove_flashcards;

  /// No description provided for @remove_quiz.
  ///
  /// In en, this message translates to:
  /// **'Remove quiz'**
  String get remove_quiz;

  /// No description provided for @school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// No description provided for @school_class.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get school_class;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @secondary_school.
  ///
  /// In en, this message translates to:
  /// **'Secondary school'**
  String get secondary_school;

  /// No description provided for @select_image.
  ///
  /// In en, this message translates to:
  /// **'Select image'**
  String get select_image;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select a language'**
  String get select_language;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @set_ai_model.
  ///
  /// In en, this message translates to:
  /// **'Set AI model'**
  String get set_ai_model;

  /// No description provided for @set_api_key.
  ///
  /// In en, this message translates to:
  /// **'Set API key'**
  String get set_api_key;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @student_name.
  ///
  /// In en, this message translates to:
  /// **'Student name'**
  String get student_name;

  /// No description provided for @system_default.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get system_default;

  /// No description provided for @take_image.
  ///
  /// In en, this message translates to:
  /// **'Take image'**
  String get take_image;

  /// No description provided for @task_scanner.
  ///
  /// In en, this message translates to:
  /// **'Task scanner'**
  String get task_scanner;

  /// No description provided for @task_scanner_description.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the task and solve it step by step with a little help.'**
  String get task_scanner_description;

  /// No description provided for @this_field_is_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get this_field_is_required;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get try_again;

  /// No description provided for @type_here.
  ///
  /// In en, this message translates to:
  /// **'Type here...'**
  String get type_here;

  /// No description provided for @university.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get university;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @you_are_good_to_go.
  ///
  /// In en, this message translates to:
  /// **'You\'re good to go!'**
  String get you_are_good_to_go;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'pl',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pl':
      return AppLocalizationsPl();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
