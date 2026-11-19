import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:omnilearn/elements/dialog_boxes.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/data/database.dart';
import 'package:omnilearn/pages/flashcards/add_flashcards_page.dart';
import 'package:omnilearn/pages/flashcards/flashcard_page.dart';
import 'package:omnilearn/style/style_options.dart';
import 'package:omnilearn/tools/validity_correction/flashcards_validity_correction.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

// ==================================
// FLASHCARDS MAIN LIST PAGE
// ==================================

/// Main page displaying available flashcard sets, creating new sets, and opening set viewer
class FlashcardsMainPage extends StatefulWidget {
  FlashcardsMainPage({super.key});

  @override
  State<FlashcardsMainPage> createState() => _FlashcardsMainPageState();
}

class _FlashcardsMainPageState extends State<FlashcardsMainPage> {
  final _appDb = AppDatabase();

  void _onPageEnter() {
    _appDb.load();
    FlashcardsValidityCorrection().check();
  }

  @override
  void initState() {
    _onPageEnter();
    super.initState();
  }

  void _navigateToAddFlashcardsPage() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddFlashcardsPage()));

    if(mounted) {
      setState(() {
        _onPageEnter();
      });
    }
  }

  void _navigateToFlashcardsPage(int flashcardSetIndex) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => FlashcardPage(flashcardSetIndex: flashcardSetIndex)));

    if(mounted) {
      setState(() {
        _onPageEnter();
      });
    }
  }

  void _showFlashcardsRemovalConfirmation(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return ConfirmationDialogBox(
              title: AppLocalizations.of(context)!.remove_flashcards,
              message: AppLocalizations.of(context)!.flashcards_removal_confirmation,
              onYes: () {
                _removeFlashcards(index);
                Navigator.of(context).pop();
              },
              onNo: () {
                Navigator.of(context).pop();
              }
          );
        }
    );
  }

  void _removeFlashcards(int index) {
    setState(() {
      _appDb.flashcards.removeAt(index);
      _appDb.save();
    });
  }

  int _countFlashcards(List flashcards, int status){
    int x = 0;
    for(Map flashcard in flashcards) {
      if(flashcard['status'] == status){
        x++;
      }
    }
    return x;
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
            _navigateToAddFlashcardsPage();
          },
          child: Icon(
            BootstrapIcons.plus_lg,
            color: NeumorphicTheme.defaultTextColor(context),
          )
      ),
      body: _appDb.flashcards.length == 0 ? 
          Center(
            child: Text(AppLocalizations.of(context)!.no_flashcards),
          )
          : Container(
            padding: EdgeInsets.symmetric(vertical: StyleOptions.pageVerticalPadding, horizontal: StyleOptions.pageHorizontalPadding),
            child: GridView.builder(
              itemCount: _appDb.flashcards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                return NeumorphicButton(
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                    depth: StyleOptions.neumorphicDepth,
                    intensity: StyleOptions.neumorphicIntensity,
                  ),
                  margin: EdgeInsets.symmetric(vertical: StyleOptions.gridGap / 2, horizontal: StyleOptions.gridGap / 2),
                    onPressed: () async {
                      _navigateToFlashcardsPage(index);
                    },
                    child: Column(
                      children: [
                        Expanded(child: Center(child:
                          Text(
                            _appDb.flashcards[index]['set_name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),
                          )
                        )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  BootstrapIcons.question_lg,
                                  size: 18,
                                  color: NeumorphicTheme.defaultTextColor(context),
                                ),
                                Text(
                                  " ${_countFlashcards(_appDb.flashcards[index]['flashcards'], 0)}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(
                                  BootstrapIcons.check_lg,
                                  size: 18,
                                  color: NeumorphicTheme.defaultTextColor(context),
                                ),
                                Text(
                                  " ${_countFlashcards(_appDb.flashcards[index]['flashcards'], 1)}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(
                                  BootstrapIcons.exclamation_circle_fill,
                                  size: 18,
                                  color: NeumorphicTheme.defaultTextColor(context),
                                ),
                                Text(
                                  " ${_countFlashcards(_appDb.flashcards[index]['flashcards'], 2)}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],

                            ),
                            GestureDetector(
                              onTap: () {
                                _showFlashcardsRemovalConfirmation(index);
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
                            )
                          ],
                        )
                      ],
                    ),
                );
              }
            ),
          ),
    );
  }
}
