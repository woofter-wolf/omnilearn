import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:omnilearn/elements/dialog_boxes.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/data/database.dart';
import 'package:omnilearn/pages/quizzes/quiz_page.dart';
import 'package:omnilearn/pages/quizzes/add_quiz_page.dart';
import 'package:omnilearn/style/style_options.dart';
import 'package:omnilearn/tools/validity_correction/quizzes_validity_correction.dart';

// ==================================
// QUIZZES MAIN LIST PAGE
// ==================================

/// Main page displaying user quiz sets, best scores, creation shortcuts, and quiz deletion
class QuizzesMainPage extends StatefulWidget {
  QuizzesMainPage({super.key});

  @override
  State<QuizzesMainPage> createState() => _QuizzesMainPageState();
}

class _QuizzesMainPageState extends State<QuizzesMainPage> {
  final _appDb = AppDatabase();

  void _onPageEnter() {
    _appDb.load();
    QuizzesValidityCorrection().check();
  }

  @override
  void initState() {
    _onPageEnter();
    super.initState();
  }

  void _navigateToQuizPage(int quizIndex) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => QuizPage(quizIndex: quizIndex)));

    if(mounted) {
      setState(() {
        _onPageEnter();
      });
    }
  }

  void _navigateToAddQuizPage() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddQuizPage()));

    if(mounted) {
      setState(() {
        _onPageEnter();
      });
    }
  }

  void _showQuizRemovalConfirmation(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return ConfirmationDialogBox(
              title: AppLocalizations.of(context)!.remove_quiz,
              message: AppLocalizations.of(context)!.quiz_removal_confirmation,
              onYes: () {
                _removeQuiz(index);
                Navigator.of(context).pop();
              },
              onNo: () {
                Navigator.of(context).pop();
              }
          );
        }
    );
  }

  void _removeQuiz(int index) {
    setState(() {
      _appDb.quizzes.removeAt(index);
      _appDb.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: NeumorphicFloatingActionButton(
        style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
          depth: StyleOptions.neumorphicDepth,
          intensity: StyleOptions.neumorphicIntensity
        ),
        onPressed: () {
          _navigateToAddQuizPage();
        },
        child: Icon(
          BootstrapIcons.plus_lg,
          color: NeumorphicTheme.defaultTextColor(context),
        )
      ),
      body: _appDb.quizzes.length == 0 ?
        Center(
          child: Text(AppLocalizations.of(context)!.no_quizzes),
        )
        : ListView.builder(
          itemCount: _appDb.quizzes.length,
          itemBuilder: (context, index) => ListTile(
            title: NeumorphicButton(
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                depth: StyleOptions.neumorphicDepth,
                intensity: StyleOptions.neumorphicIntensity
              ),
              onPressed: () {
                _navigateToQuizPage(index);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: StyleOptions.listTileVerticalPadding, horizontal: StyleOptions.listTileHorizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                          _appDb.quizzes[index]['quiz_name'], textAlign: TextAlign.start,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _appDb.quizzes[index]['score_percentage'] < 0 ?
                            Text(
                                AppLocalizations.of(context)!.not_solved_yet,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),
                            )
                            : Text(
                                  _appDb.quizzes[index]['score_percentage'].toString() + "%",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                        GestureDetector(
                          onTap: () {
                            _showQuizRemovalConfirmation(index);
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: StyleOptions.sideButtonMargin),
                            child: NeumorphicIcon(
                                BootstrapIcons.trash_fill,
                              size: 23,
                              style: NeumorphicStyle(
                                depth: StyleOptions.neumorphicDepth,
                                intensity: StyleOptions.neumorphicIntensity,
                                color: NeumorphicTheme.defaultTextColor(context)
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ),
          )
        ),
    );
  }
}