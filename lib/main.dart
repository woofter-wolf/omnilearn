import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omnilearn/pages/first_configuration_page.dart';
import 'package:omnilearn/pages/main_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:omnilearn/data/database.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:omnilearn/style/style_options.dart';

// ==================================
// GLOBAL STATE NOTIFIERS
// ==================================

/// Notifier for dynamic app locale updates
final ValueNotifier<Locale?> appLocaleNotifier = ValueNotifier<Locale?>(null);

/// Notifier for tracking whether the app setup/first configuration is completed
final ValueNotifier<bool> appConfiguredNotifier = ValueNotifier<bool>(false);

// ==================================
// MAIN ENTRY POINT
// ==================================

/// Main entry point of the OmniLearn application
void main() async {
  await Hive.initFlutter();

  // Open Hive database box
  final appDb = await Hive.openBox("app_db");

  runApp(const MyApp());
}

// ==================================
// MAIN ROOT WIDGET
// ==================================

/// Root application widget configuring Neumorphic theme, localizations, and initial page routing
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    var _appDb = AppDatabase();
    if(!_appDb.isCreated()) {
      _appDb.createInitialDatabase();
    }
    _appDb.load();
    appLocaleNotifier.value = _appDb.lang == null ? null : Locale(_appDb.lang!);
    appConfiguredNotifier.value = _appDb.appConfigured;

    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocaleNotifier,
      builder: (context, currentLocale, child) {
        return ValueListenableBuilder<bool>(
            valueListenable: appConfiguredNotifier,
            builder: (context, isConfigured, child) {
              return NeumorphicApp(
                debugShowCheckedModeBanner: false,
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate
                ],
                // Available languages
                supportedLocales: [
                  Locale('en', 'EN'),
                  Locale('pl', 'PL'),
                  Locale('de', 'DE'),
                  Locale('es', 'ES'),
                  Locale('fr', 'FR'),
                  Locale('it', 'IT'),
                  Locale('ru', 'RU'),
                  Locale('ja', 'JA'),
                  Locale('zh', 'ZH')
                ],
                locale: currentLocale,
                title: 'OmniLearn',
                // Light theme
                theme: NeumorphicThemeData(
                  baseColor: neumorphicDefaultTheme.baseColor,
                  accentColor: _appDb.accentColor,
                  lightSource: LightSource.topLeft,
                  defaultTextColor: neumorphicDefaultTheme.defaultTextColor,
                  disabledColor: neumorphicDefaultTheme.disabledColor,
                  shadowLightColor: neumorphicDefaultTheme.shadowLightColor,
                  shadowDarkColor: neumorphicDefaultTheme.shadowDarkColor,
                  depth: StyleOptions.neumorphicDepth,
                ),
                // Dark theme
                darkTheme: NeumorphicThemeData(
                  baseColor: neumorphicDefaultDarkTheme.baseColor,
                  accentColor: _appDb.accentColor,
                  lightSource: LightSource.topLeft,
                  defaultTextColor: neumorphicDefaultDarkTheme.defaultTextColor,
                  disabledColor: neumorphicDefaultDarkTheme.disabledColor,
                  shadowLightColor: neumorphicDefaultDarkTheme.shadowLightColor,
                  shadowDarkColor: neumorphicDefaultDarkTheme.shadowDarkColor,
                  depth: StyleOptions.neumorphicDepth,
                ),
                // Startup page
                home: isConfigured ? MainPage() : FirstConfigurationPage(),
              );
            }
        );
      }
    );
  }
}