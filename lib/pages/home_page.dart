import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/pages/main_page.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:omnilearn/style/style_options.dart';

// ==================================
// HOME DASHBOARD PAGE
// ==================================

/// Home dashboard page providing quick shortcuts to Flashcards, Quizzes, and Task Scanner
class HomePage extends StatelessWidget {
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: StyleOptions.pageHorizontalPadding, vertical: StyleOptions.pageVerticalPadding),
        child: Column(
          children: [
            GridView.count(
              childAspectRatio: 0.8,
              mainAxisSpacing: StyleOptions.gridGap,
              crossAxisSpacing: StyleOptions.gridGap,
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                FunctionButton(
                    buttonTitle: AppLocalizations.of(context)!.flashcards,
                    buttonDescription: AppLocalizations.of(context)!.flashcards_description,
                    buttonIcon: BootstrapIcons.tags_fill,
                  onPressed: () {
                    pageIndex.value = 1;
                  },
                ),
                FunctionButton(
                  buttonTitle: AppLocalizations.of(context)!.quizzes,
                  buttonDescription: AppLocalizations.of(context)!.quizzes_description,
                  buttonIcon: BootstrapIcons.question_lg,
                  onPressed: () {
                    pageIndex.value = 2;
                  },
                ),
                FunctionButton(
                  buttonTitle: AppLocalizations.of(context)!.task_scanner,
                  buttonDescription: AppLocalizations.of(context)!.task_scanner_description,
                  buttonIcon: BootstrapIcons.camera_fill,
                  onPressed: () {
                    pageIndex.value = 3;
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// Reusable grid tile button representing a main feature module on the home dashboard
class FunctionButton extends StatelessWidget {
  String buttonTitle = "";
  String buttonDescription = "";
  IconData buttonIcon;
  VoidCallback onPressed;

  FunctionButton({
    super.key,
    required this.buttonTitle,
    required this.buttonDescription,
    required this.buttonIcon,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
        depth: StyleOptions.neumorphicDepth,
        intensity: StyleOptions.neumorphicIntensity,
        color: NeumorphicTheme.baseColor(context)
      ),
      onPressed: onPressed,
        child: SingleChildScrollView(
          child: Column(
            children: [
              NeumorphicIcon(
                  buttonIcon,
                size: 38,
                style: NeumorphicStyle(
                  depth: StyleOptions.neumorphicDepth,
                  intensity: StyleOptions.neumorphicIntensity,
                  color: NeumorphicTheme.defaultTextColor(context)
                ),
              ),
              Text(
                  buttonTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(buttonDescription, style: TextStyle(fontWeight: FontWeight.normal))
            ],
          ),
        )
    );
  }
}