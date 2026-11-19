import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/data/database.dart';
import 'package:omnilearn/style/style_options.dart';

// ==================================
// ACTIVE QUIZ QUESTIONS SUBPAGE
// ==================================

/// Interactive quiz execution subpage handling question progression, single/multi-choice selection, and explanations
class QuizSubpage extends StatefulWidget {
  int quizIndex;
  final void Function(double score, List selectedOptions) onQuizCompleted;

  QuizSubpage({
    super.key,
    required this.quizIndex,
    required this.onQuizCompleted
  });

  @override
  State<QuizSubpage> createState() => _QuizSubpageState();
}

class _QuizSubpageState extends State<QuizSubpage> {
  final _appDb = AppDatabase();
  int _questionIndex = 0;
  String _currentQuestion = "";
  List _currentOptions = [];
  List _currentCorrectOptions = [];
  String _currentExplanation = "";
  bool _singleChoiceQuestion = false;
  int _pickedSingleChoiceOption = -1;
  List<bool> _pickedMultiChoiceOptions = [];
  bool _showNotSelectedError = false;
  bool _answerSubmitted = false;
  int _completedQuestions = 0;
  List _selectedOptions = [];
  double _score = 0.0;


  void _showQuestion() {
    setState(() {
      _currentQuestion = _appDb.quizzes[widget.quizIndex]['questions'][_questionIndex]['question'];
      _currentOptions = _appDb.quizzes[widget.quizIndex]['questions'][_questionIndex]['options'];
      _currentCorrectOptions = _appDb.quizzes[widget.quizIndex]['questions'][_questionIndex]['correct_options'];
      _currentExplanation = _appDb.quizzes[widget.quizIndex]['questions'][_questionIndex]['explanation'];
      _singleChoiceQuestion = _currentCorrectOptions.length == 1;
    });
  }

  double _checkSingleChoiceOption(int pickedOptionIndex, int correctOption) {
    if(pickedOptionIndex == correctOption) {
      return 1.0;
    }
    else {
      return 0.0;
    }
  }

  double _checkMultiChoiceOption(List pickedOptions, List correctOptions) {
    if (pickedOptions.isEmpty || correctOptions.isEmpty) return 0.0;

    int correctPickedCount = 0;
    int wrongPickedCount = 0;

    final correctIndices = Set<int>.from(correctOptions);

    for (int i = 0; i < pickedOptions.length; i++) {
      if (pickedOptions[i] == true) {
        if (correctIndices.contains(i)) {
          correctPickedCount++;
        } else {
          wrongPickedCount++;
        }
      }
    }

    double score = (correctPickedCount - wrongPickedCount) / correctOptions.length;

    if (score < 0.0) score = 0.0;

    return (score * 10).round() / 10;
  }

  void _onCheckAnswerButtonPressed() {
    setState(() {
      _showNotSelectedError = _pickedSingleChoiceOption <= -1 && _singleChoiceQuestion;
    });
    if(_singleChoiceQuestion) {
      _score += _checkSingleChoiceOption(_pickedSingleChoiceOption, _currentCorrectOptions[0]);
      _selectedOptions.add([_pickedSingleChoiceOption]);
    }
    else {
      _score += _checkMultiChoiceOption(_pickedMultiChoiceOptions, _currentCorrectOptions);
      _selectedOptions.add(_pickedMultiChoiceOptions);
    }
    if(_pickedSingleChoiceOption <= -1 && _singleChoiceQuestion) {
      return;
    }
    _answerSubmitted = true;
  }

  void _onNextButtonPressed() {
    if(_questionIndex >= _appDb.quizzes[widget.quizIndex]['questions'].length - 1){
      widget.onQuizCompleted(_score, _selectedOptions);
    }
    else {
      setState(() {
        _questionIndex++;
        _pickedSingleChoiceOption = -1;
        _showQuestion();
        _answerSubmitted = false;
        _completedQuestions++;
      });
    }
  }

  @override
  void initState() {
    _appDb.load();
    super.initState();
    _showQuestion();
  }

  @override
  Widget build(BuildContext context) {
    var quiz = _appDb.quizzes[widget.quizIndex];
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.quiz + ": " + quiz['quiz_name'],
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: StyleOptions.elementsSpacing),
        Text(_completedQuestions.toString() + "/" + quiz['questions'].length.toString()),
        SizedBox(height: 6),
        NeumorphicProgress(
          style: ProgressStyle(
            depth: StyleOptions.neumorphicDepth * -1,
          ),
          percent: _completedQuestions / quiz['questions'].length,
        ),
        SizedBox(height: StyleOptions.elementsSpacing * 2),
        AnimatedSwitcher(
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
          child: Column(
            key: ValueKey<int>(_questionIndex),
            children: [
              Text(_currentQuestion),
              _singleChoiceQuestion
                  ? SingleChoiceOption(
                options: _currentOptions,
                onAnswerChanged: (i) {
                  setState(() {
                    _pickedSingleChoiceOption = i;
                  });
                },
                isSubmitted: _answerSubmitted,
                correctAnswerIndex: _currentCorrectOptions[0],
              )
                  : MultiChoiceOption(
                options: _currentOptions,
                onAnswerChanged: (selectedList) {
                  setState(() {
                    _pickedMultiChoiceOptions = selectedList;
                  });
                },
                isSubmitted: _answerSubmitted,
                correctOptionIndexes: _currentCorrectOptions,
              ),
              _showNotSelectedError
                  ? Text(AppLocalizations.of(context)!.please_select_answer)
                  : Container(),
              _answerSubmitted
                  ? Column(
                children: [
                  Text(_currentExplanation),
                ],
              )
                  : Container(),
            ],
          ),
        ),
        SizedBox(height: StyleOptions.elementsSpacing * 2),
        _answerSubmitted ? NeumorphicButton(
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
            depth: StyleOptions.neumorphicDepth,
            intensity: StyleOptions.neumorphicIntensity
          ),
          onPressed: _onNextButtonPressed,
          child: Text(AppLocalizations.of(context)!.next)
        )
            : NeumorphicButton(
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
            depth: StyleOptions.neumorphicDepth,
            intensity: StyleOptions.neumorphicIntensity
          ),
          onPressed: _onCheckAnswerButtonPressed,
          child: Text(AppLocalizations.of(context)!.check_answer)
        )
      ],
    );
  }
}

class SingleChoiceOption extends StatefulWidget {
  List options;
  ValueChanged<int> onAnswerChanged;
  bool isSubmitted;
  int correctAnswerIndex;

  SingleChoiceOption({
    super.key,
    required this.options,
    required this.onAnswerChanged,
    this.isSubmitted = false,
    required this.correctAnswerIndex
  });

  @override
  State<SingleChoiceOption> createState() => _SingleChoiceOptionState();
}

class _SingleChoiceOptionState extends State<SingleChoiceOption> {
  int _selectedOption = -1;

  Color? _getTileColor(int index) {
    if(widget.isSubmitted) {
      if(index == widget.correctAnswerIndex) {
        return Colors.green.shade500;
      }
      else if(index == _selectedOption) {
        return Colors.red.shade500;
      }
    }
    return NeumorphicTheme.baseColor(context);
  }

  @override
  void didUpdateWidget(covariant SingleChoiceOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options != widget.options) {
      setState(() {
        _selectedOption = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.options.length,
      itemBuilder: (context, index) => Container(
        padding: EdgeInsets.only(bottom: StyleOptions.optionsSpacing, top: StyleOptions.optionsSpacing),
        child: NeumorphicRadio(
            style: NeumorphicRadioStyle(
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
              selectedDepth: StyleOptions.neumorphicDepth * -1,
              unselectedDepth: StyleOptions.neumorphicDepth,
              selectedColor: _getTileColor(index),
              unselectedColor: _getTileColor(index)
            ),
            groupValue: _selectedOption,
            value: index,
            onChanged: (value) {
              if(widget.isSubmitted) {
                return;
              }
              setState(() {
                _selectedOption = index;
                widget.onAnswerChanged(_selectedOption);
              });
            },
            isEnabled: !widget.isSubmitted,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: StyleOptions.optionVerticalPadding, horizontal: StyleOptions.optionHorizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                        _selectedOption == index ? BootstrapIcons.circle_fill : BootstrapIcons.circle,
                      color: _selectedOption == index ? NeumorphicTheme.accentColor(context) : NeumorphicTheme.disabledColor(context),
                      size: 18,
                    ),
                    SizedBox(width: StyleOptions.optionHorizontalPadding),
                    Expanded(
                      child: Text(
                        widget.options[index],
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

class MultiChoiceOption extends StatefulWidget {
  List options;
  ValueChanged<List<bool>> onAnswerChanged;
  bool isSubmitted;
  List correctOptionIndexes;

  MultiChoiceOption({
    super.key,
    required this.options,
    required this.onAnswerChanged,
    this.isSubmitted = false,
    required this.correctOptionIndexes
  });

  @override
  State<MultiChoiceOption> createState() => _MultiChoiceOptionState();
}

class _MultiChoiceOptionState extends State<MultiChoiceOption> {
  late List<bool> _selectedOptions;

  @override
  void initState() {
    _initAnswers();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MultiChoiceOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options != widget.options) {
      _initAnswers();
    }
  }

  void _initAnswers() {
    _selectedOptions = List<bool>.filled(widget.options.length, false);
  }

  Color? _getTileColor(int index) {
    if(widget.isSubmitted) {
      if(widget.correctOptionIndexes.contains(index)) {
        return Colors.green.shade500;
      }
      else if (_selectedOptions[index] == true) {
        return Colors.red.shade500;
      }
    }
    else {
      if (_selectedOptions[index] == true) {
        return NeumorphicTheme.accentColor(context);
      }
      else {
        return NeumorphicTheme.baseColor(context);
      }
    }
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
          itemCount: widget.options.length,
          itemBuilder: (context, index) => Container(
            padding: EdgeInsets.only(bottom: StyleOptions.optionsSpacing / 2, top: StyleOptions.optionsSpacing / 2),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: !widget.isSubmitted,
              onTap: () {
                if (widget.isSubmitted) {
                  return;
                }
                setState(() {
                  _selectedOptions[index] = !_selectedOptions[index];
                  widget.onAnswerChanged(_selectedOptions);
                });
              },
              title: Neumorphic(
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                  depth: widget.isSubmitted ? 0 : _selectedOptions[index] ? StyleOptions.neumorphicDepth * -1 : StyleOptions.neumorphicDepth,
                  intensity: StyleOptions.neumorphicIntensity,
                  color: _getTileColor(index),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: StyleOptions.optionVerticalPadding, horizontal: StyleOptions.optionHorizontalPadding),
                  child: Center(
                    child: Text(
                        widget.options[index],
                      style: TextStyle(
                        color: NeumorphicTheme.defaultTextColor(context)
                      ),
                      overflow: TextOverflow.fade,
                    ),
                  ),
                )
              ),
            ),
          ),
      ),
    );
  }
}