import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/data/database.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:omnilearn/style/style_options.dart';

// ==================================
// FLASHCARD STUDY & SWIPER PAGE
// ==================================

/// Interactive swipable flashcard study page with flip cards and status marking (mastered/difficult)
class FlashcardPage extends StatefulWidget {
  int flashcardSetIndex;

  FlashcardPage({
    super.key,
    required this.flashcardSetIndex
  });

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  final _appDb = AppDatabase();

  List _sortedFlashcards = [];

  void _sortFlashcards(List flashcards) {
    List flashcardsUncovered = [];
    List flashcardsMastered = [];
    List flashcardsDifficult = [];

    for(var flashcard in flashcards) {
      if(flashcard['status'] == 0) {
        flashcardsUncovered.add(flashcard);
      }
      else if(flashcard['status'] == 1) {
        flashcardsMastered.add(flashcard);
      }
      else if(flashcard['status'] == 2) {
        flashcardsDifficult.add(flashcard);
      }
    }
    _sortedFlashcards.clear();
    _sortedFlashcards.addAll(flashcardsUncovered);
    _sortedFlashcards.addAll(flashcardsMastered);
    _sortedFlashcards.addAll(flashcardsDifficult);
  }

  bool _onCardSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if(direction == CardSwiperDirection.right) {
      _sortedFlashcards[previousIndex]['status'] = 1;
    }
    if(direction == CardSwiperDirection.left) {
      _sortedFlashcards[previousIndex]['status'] = 2;
    }
    // setState(() {
    //   _displayedFlashcards.removeAt(0);
    // });
    if(previousIndex == _sortedFlashcards.length - 1){
      setState(() {
        _sortFlashcards(_sortedFlashcards);
      });
    }
    _appDb.flashcards[widget.flashcardSetIndex]['flashcards'] = _sortedFlashcards;
    _appDb.save();
    return true;
  }

  @override
  void initState() {
    _appDb.load();
    _sortFlashcards(_appDb.flashcards[widget.flashcardSetIndex]['flashcards']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: Text(AppLocalizations.of(context)!.flashcards),
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
      body: Column(
        children: [
          SizedBox(
            width: 400,
            height: 400,
            child: CardSwiper(
              cardsCount: _sortedFlashcards.length,
              numberOfCardsDisplayed: _sortedFlashcards.length < 2 ? _sortedFlashcards.length : 2,
              allowedSwipeDirection: AllowedSwipeDirection.symmetric(horizontal: true),
              onSwipe: _onCardSwipe,
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                return Flashcard(question: _sortedFlashcards[index]['question'], answer: _sortedFlashcards[index]['answer'], status: _sortedFlashcards[index]['status'],);
              },
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                    BootstrapIcons.exclamation_circle_fill,
                  color: NeumorphicTheme.defaultTextColor(context),
                ),
                Icon(
                    BootstrapIcons.check_lg,
                  color: NeumorphicTheme.defaultTextColor(context),
                ),
              ],
            ),
          ),
        ]
      ),
    );
  }
}

class Flashcard extends StatefulWidget {
  final String question;
  final String answer;
  final int status;
  Flashcard({
    super.key,
    required this.question,
    required this.answer,
    required this.status
  });

  @override
  State<Flashcard> createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _rotateAnimation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;
  final double pi = 3.1415926535897932;
  final _appDb = AppDatabase();


  @override
  void initState() {
    _appDb.load();
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _rotateAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {

        });
      })
    ..addStatusListener((status) {
      _animationStatus = status;
    });
  }

  @override
  void didUpdateWidget(covariant Flashcard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.question != widget.question || oldWidget.answer != widget.answer) {
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(_animationStatus == AnimationStatus.dismissed) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateY(pi * _rotateAnimation.value),
        child: SizedBox(
          width: 200,
          height: 200,
          child: Card(
            color: _rotateAnimation.value <= 0.5 ? NeumorphicTheme.baseColor(context) : NeumorphicTheme.accentColor(context),
            surfaceTintColor: NeumorphicTheme.accentColor(context),
            child: _rotateAnimation.value <= 0.5
                ? Container(
                  child: Stack(
                                children: [
                  Positioned(
                      left: 10,
                      top: 10,
                      child: Icon(
                          widget.status == 0 ? BootstrapIcons.question_lg : widget.status == 1 ? BootstrapIcons.check_lg : BootstrapIcons.exclamation_circle_fill,
                        color: NeumorphicTheme.defaultTextColor(context),
                      )
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(vertical: StyleOptions.flashcardVerticalPadding, horizontal: StyleOptions.flashcardHorizontalPadding),
                      child: Center(
                          child: Text(
                              widget.question,
                            textAlign: TextAlign.center,
                          )
                      )
                  ),
                                ]
                              ),
                )
                : Transform.flip(
              flipX: true,
              child: Container(
                child: Stack(
                    children: [
                      Positioned(
                          left: 10,
                          top: 10,
                          child: Icon(
                              widget.status == 0 ? BootstrapIcons.question_lg : widget.status == 1 ? BootstrapIcons.check_lg : BootstrapIcons.exclamation_circle_fill,
                            color: _appDb.textOnAccentColor,
                          )
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: StyleOptions.flashcardVerticalPadding, horizontal: StyleOptions.flashcardHorizontalPadding),
                        child: Center(child: Text(
                            widget.answer,
                          style: TextStyle(
                            color: _appDb.textOnAccentColor
                          ),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ]
                ),
              )
            ),
          ),
        ),
      ),
    );
  }
}