import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/main.dart';
import 'package:omnilearn/data/database.dart';
import 'package:omnilearn/style/style_options.dart';

// ==================================
// LANGUAGE SELECTION PAGE
// ==================================

/// Page for selecting application localization language
class LanguagePage extends StatefulWidget {
  LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final _appDb = AppDatabase();

  final List<List<String?>> _languages = [
    [null, "System default"],
    ["en", "English"],
    ["pl", "Polski"],
    ["de", "Deutsch"],
    ["es", "Español"],
    ["fr", "Français"],
    ["it", "Italiano"],
    ["ru", "Русский"],
    ["ja", "日本語"],
    ["zh", "中文"]
  ];

  void _changeLanguage(int index) {
    setState(() {
      appLocaleNotifier.value = _languages[index][0] == null ? null : Locale(_languages[index][0]!);
      _appDb.lang = _languages[index][0];
      _appDb.save();
    });
  }

  @override
  void initState() {
    super.initState();
    _appDb.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: Text(
          AppLocalizations.of(context)!.language,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: NeumorphicTheme.defaultTextColor(context)
          ),
        ),
        leading: NeumorphicButton(
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.circle(),
            depth: StyleOptions.neumorphicDepth,
            intensity: StyleOptions.neumorphicIntensity,
            color: NeumorphicTheme.baseColor(context)
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            BootstrapIcons.chevron_left,
            color: NeumorphicTheme.defaultTextColor(context),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: StyleOptions.pageVerticalPadding, horizontal: StyleOptions.pageHorizontalPadding),
        child: SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final langCode = _languages[index][0];
              final langText = _languages[index][1];
              final currentLocale = appLocaleNotifier.value;
              final isSelected = langCode == null ? currentLocale == null : langCode == currentLocale.toString();
              
              return NeumorphicButton(
                margin: EdgeInsets.only(bottom: StyleOptions.elementsSpacing),
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                  depth: StyleOptions.neumorphicDepth,
                  intensity: StyleOptions.neumorphicIntensity,
                ),
                onPressed: () {
                  _changeLanguage(index);
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          langText!,
                        style: TextStyle(
                            fontSize: StyleOptions.buttonTitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: NeumorphicTheme.defaultTextColor(context)
                        ),
                      ),
                      Icon(
                        isSelected ? BootstrapIcons.check_lg : null,
                        color: NeumorphicTheme.defaultTextColor(context),
                      )
                    ],
                  ),
                )
              );
            }
          ),
        ),
      ),
    );
  }
}