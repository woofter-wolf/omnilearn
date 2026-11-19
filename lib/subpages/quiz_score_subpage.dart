import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/data/database.dart';
import 'package:omnilearn/style/style_options.dart';

// ==================================
// QUIZ SCORE SUMMARY SUBPAGE
// ==================================

/// Quiz score review subpage displaying final percentage score, detailed answer analysis, and explanations
class QuizScoreSubpage extends StatelessWidget {
  int quizIndex;
  double score;
  List selectedOptions;

  QuizScoreSubpage({
    super.key,
    required this.quizIndex,
    required this.score,
    required this.selectedOptions
  });

  final _appDb = AppDatabase();

  @override
  Widget build(BuildContext context) {
    _appDb.load();
    final _scorePercentage = (score / _appDb.quizzes[quizIndex]['questions'].length * 100).round();
    final _questions = _appDb.quizzes[quizIndex]['questions'];
    _appDb.quizzes[quizIndex]['score_percentage'] = _scorePercentage;
    _appDb.save();
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.quiz + ": " + _appDb.quizzes[quizIndex]['quiz_name'],
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: StyleOptions.elementsSpacing),
        Text(AppLocalizations.of(context)!.score + ": " + _scorePercentage.toString() + "%"),
        SizedBox(height: StyleOptions.elementsSpacing),
        NeumorphicButton(
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
            depth: StyleOptions.neumorphicDepth,
            intensity: StyleOptions.neumorphicIntensity
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.exit),
        ),
        SizedBox(height: StyleOptions.elementsSpacing * 2),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _questions.length,
          itemBuilder: (context, index) => Column(
            children: [
              SizedBox(height: StyleOptions.elementsSpacing),
              ListTile(
                title: Column(
                  children: [
                    Text(_questions[index]['question']),
                    Container(
                      child: selectedOptions[index].length == 1 ?
                      ScoreSubpageSingleChoiceOption(
                          options: _questions[index]['options'],
                          selectedOptionIndex: selectedOptions[index][0],
                          correctOptionIndex: _questions[index]['correct_options'][0]
                      )
                      : ScoreSubpageMultiChoiceOption(
                          options: _questions[index]['options'],
                          selectedOptions: selectedOptions[index],
                          correctOptionIndexes: _questions[index]['correct_options']
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ScoreSubpageSingleChoiceOption extends StatelessWidget {
  List options;
  int selectedOptionIndex;
  int correctOptionIndex;

  ScoreSubpageSingleChoiceOption({
    super.key,
    required this.options,
    required this.selectedOptionIndex,
    required this.correctOptionIndex
  });

  Color? _getTileColor(int index, context) {
    if(index == correctOptionIndex) {
      return Colors.green.shade500;
    }
    else if(index == selectedOptionIndex) {
      return Colors.red.shade500;
    }
    return NeumorphicTheme.baseColor(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: options.length,
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.only(bottom: StyleOptions.optionsSpacing, top: StyleOptions.optionsSpacing),
          child: NeumorphicRadio(
            style: NeumorphicRadioStyle(
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                selectedDepth: StyleOptions.neumorphicDepth * -1,
                unselectedDepth: StyleOptions.neumorphicDepth,
                selectedColor: _getTileColor(index, context),
                unselectedColor: _getTileColor(index, context)
            ),
            groupValue: selectedOptionIndex,
            value: index,
            isEnabled: false,
            child: Container(
                padding: EdgeInsets.symmetric(vertical: StyleOptions.optionVerticalPadding, horizontal: StyleOptions.optionHorizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      selectedOptionIndex == index ? BootstrapIcons.circle_fill : BootstrapIcons.circle,
                      color: selectedOptionIndex == index ? NeumorphicTheme.accentColor(context) : NeumorphicTheme.disabledColor(context),
                      size: 18,
                    ),
                    SizedBox(width: StyleOptions.optionHorizontalPadding),
                    Expanded(
                      child: Text(
                        options[index],
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ],
                )
            ),

          ),
        )
    );
  }
}

class ScoreSubpageMultiChoiceOption extends StatelessWidget {
  List options;
  List selectedOptions;
  List correctOptionIndexes;

  ScoreSubpageMultiChoiceOption({
    super.key,
    required this.options,
    required this.selectedOptions,
    required this.correctOptionIndexes
  });

  Color? _getTileColor(int index, context) {
    if(correctOptionIndexes.contains(index)) {
      return Colors.green.shade500;
    }
    else if (selectedOptions[index] == true) {
      return Colors.red.shade500;
    }
    return NeumorphicTheme.baseColor(context);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: options.length,
        itemBuilder: (context, index) => Container(
            padding: EdgeInsets.only(bottom: StyleOptions.optionsSpacing / 2, top: StyleOptions.optionsSpacing / 2),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: false,
              title: Neumorphic(
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                    depth: 0,
                    intensity: StyleOptions.neumorphicIntensity,
                    color: _getTileColor(index, context),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: StyleOptions.optionVerticalPadding, horizontal: StyleOptions.optionHorizontalPadding),
                    child: Center(
                      child: Text(
                          options[index],
                        style: TextStyle(
                          color: NeumorphicTheme.defaultTextColor(context),
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  )
              ),
            )
        ),
      ),
    );
  }
}