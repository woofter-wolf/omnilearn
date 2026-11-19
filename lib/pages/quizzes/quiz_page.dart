import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/style/style_options.dart';
import 'package:omnilearn/subpages/quiz_subpage.dart';
import 'package:omnilearn/subpages/quiz_score_subpage.dart';
import 'package:omnilearn/elements/dialog_boxes.dart';

// ==================================
// QUIZ RUNNER CONTAINER PAGE
// ==================================

/// Wrapper page switching between active quiz runner subpage and score summary subpage
class QuizPage extends StatefulWidget {
  int quizIndex;
  QuizPage({
    super.key,
    required this.quizIndex
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  double _score = 0.0;
  List _selectedOptions = [];
  bool _quizCompleted = false;

  Future<bool> _showExitConfirmation() async {
    bool value = false;
    await showDialog(
        context: context,
        builder: (context) {
          return ConfirmationDialogBox(
            title: AppLocalizations.of(context)!.exit_quiz,
            message: AppLocalizations.of(context)!.exit_quiz_confirmation,
            onYes: () {
              value = true;
              Navigator.of(context).pop();
            },
            onNo: () {
              value = false;
              Navigator.of(context).pop();
            }
          );
        }
    );
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _quizCompleted,
      onPopInvokedWithResult: (didPop, result) async {
        if(didPop) {
          return;
        }
        bool shouldExit = await _showExitConfirmation();
        if(context.mounted && shouldExit) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: NeumorphicAppBar(
          title: Text(AppLocalizations.of(context)!.quiz),
          leading: NeumorphicButton(
            style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.circle(),
                depth: StyleOptions.neumorphicDepth,
                intensity: StyleOptions.neumorphicIntensity,
                color: NeumorphicTheme.baseColor(context)
            ),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            child: Icon(
              BootstrapIcons.chevron_left,
              color: NeumorphicTheme.defaultTextColor(context),
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: StyleOptions.pageVerticalPadding, horizontal: StyleOptions.pageHorizontalPadding),
          // child: SingleChildScrollView(
          //   child: !_quizCompleted ? QuizSubpage(
          //       quizIndex: widget.quizIndex,
          //       onQuizCompleted: (score, selectedOptions) {
          //         setState(() {
          //           _score = score;
          //           _selectedOptions = selectedOptions;
          //           _quizCompleted = true;
          //         });
          //       }
          //   ) : QuizScoreSubpage(quizIndex: widget.quizIndex, score: _score, selectedOptions: _selectedOptions),
          // ),
          child: AnimatedSwitcher(
            duration: StyleOptions.animationDuration,
            switchInCurve: StyleOptions.switchInCurve,
            switchOutCurve: StyleOptions.switchOutCurve,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<bool>(_quizCompleted),
              child: SingleChildScrollView(
                child: !_quizCompleted ? QuizSubpage(
                    quizIndex: widget.quizIndex,
                    onQuizCompleted: (score, selectedOptions) {
                      setState(() {
                        _score = score;
                        _selectedOptions = selectedOptions;
                        _quizCompleted = true;
                      });
                    }
                  ) : QuizScoreSubpage(quizIndex: widget.quizIndex, score: _score, selectedOptions: _selectedOptions),
              ),
              ),

            ),
          ),
        ),
      );
  }
}
