import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omnilearn/elements/loading_box.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/data/database.dart';
import 'package:omnilearn/tools/ai.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:omnilearn/style/style_options.dart';

// ==================================
// ADD QUIZ GENERATION PAGE
// ==================================

/// Page for generating a new quiz set from images or existing flashcards using AI
class AddQuizPage extends StatefulWidget {
  AddQuizPage({super.key});

  @override
  State<AddQuizPage> createState() => _AddQuizPageState();
}

class _AddQuizPageState extends State<AddQuizPage> {
  List<XFile> _imageFiles = [];
  ImagePicker _picker = ImagePicker();
  final _appDb = AppDatabase();
  final _ai = AI();
  List<bool> _selectedFlashcards = [];

  Future<void> _pickImages() async {
    try {
      List<XFile> picked = await _picker.pickMultiImage();
      setState(() {
        _imageFiles.addAll(picked);
      });
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      XFile? picked = await _picker.pickImage(source: ImageSource.camera);
      if(picked != null){
        setState(() {
          _imageFiles.add(picked);
        });
      }
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  List<int> _getSelectedFlashcardsIndexes() {
    List<int> selectedIndexes = [];
    for (int i = 0; i < _selectedFlashcards.length; i++) {
      if (_selectedFlashcards[i]) {
        selectedIndexes.add(i);
      }
    }
    return selectedIndexes;
  }

  List _getSelectedFlashcards() {
    List selectedFlashcards = [];
    for(int i in _getSelectedFlashcardsIndexes()) {
      selectedFlashcards.add(_appDb.flashcards[i]);
    }
    return selectedFlashcards;
  }

  @override
  void initState() {
    _appDb.load();
    _ai.setProvider("openrouter");
    _ai.setApiKey(_appDb.aiAPIKey);
    _ai.setModelName(_appDb.aiModelName);
    _selectedFlashcards = List<bool>.filled(_appDb.flashcards.length, false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: Text(AppLocalizations.of(context)!.add_quiz),
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
        child: Column(
          children: [
            Text(AppLocalizations.of(context)!.add_quiz_description),
            SizedBox(height: StyleOptions.elementsSpacing * 2),
            Text(
                AppLocalizations.of(context)!.from_images,
              style: TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: StyleOptions.elementsSpacing),
            if(_imageFiles.length > 0)
              Neumorphic(

                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                  depth: StyleOptions.neumorphicDepth,
                  intensity: StyleOptions.neumorphicIntensity,
                ),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(StyleOptions.imageSelectionBoxBorderMargin),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: NeumorphicTheme.disabledColor(context),
                      ),
                      borderRadius: BorderRadius.circular(StyleOptions.elementRoundness)
                  ),
                  child: SizedBox(
                    height: 170,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: StyleOptions.imageSelectionBoxVerticalPadding, horizontal: StyleOptions.imageSelectionBoxHorizontalPadding),
                      child: ListView.builder(
                          itemCount: _imageFiles.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Neumorphic(
                                  margin: EdgeInsets.only(right: StyleOptions.imagesMargin),
                                  style: NeumorphicStyle(
                                    depth: 0,
                                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                                  ),
                                  child: Image.file(
                                    File(_imageFiles[index].path),
                                    height: 150,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Positioned(
                                    top: 18,
                                    right: 10 + StyleOptions.imagesMargin,
                                    child: NeumorphicButton(
                                        padding: EdgeInsets.all(2),
                                        style: NeumorphicStyle(
                                          boxShape: NeumorphicBoxShape.circle(),
                                          depth: 0,
                                          color: NeumorphicTheme.baseColor(context),
                                        ),
                                        onPressed: () {
                                          _removeImage(index);
                                        },
                                        child: Icon(
                                          BootstrapIcons.x_lg,
                                          color: NeumorphicTheme.defaultTextColor(context),
                                          size: 20,
                                        )
                                    )
                                )
                              ],
                            );
                          }
                      ),
                    ),
                  ),
                ),
              )
            else
              Neumorphic(
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                  depth: StyleOptions.neumorphicDepth,
                  intensity: StyleOptions.neumorphicIntensity,
                ),
                child: Container(
                  margin: EdgeInsets.all(StyleOptions.imageSelectionBoxBorderMargin),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: NeumorphicTheme.disabledColor(context),
                      ),
                      borderRadius: BorderRadius.circular(StyleOptions.elementRoundness)
                  ),
                  child: SizedBox(
                    height: 170,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            BootstrapIcons.file_earmark_image,
                            color: NeumorphicTheme.disabledColor(context),
                            size: 40,
                          ),
                          SizedBox(height: 10),
                          Text(
                            AppLocalizations.of(context)!.add_images,
                            style: TextStyle(
                              color: NeumorphicTheme.disabledColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(height: StyleOptions.elementsSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NeumorphicButton(
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                    depth: StyleOptions.neumorphicDepth,
                    intensity: StyleOptions.neumorphicIntensity,
                  ),
                  onPressed: () {
                    _pickImages();
                  },
                  child: Center(
                    child: Text(AppLocalizations.of(context)!.select_image),
                  ),
                ),
                NeumorphicButton(
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                    depth: StyleOptions.neumorphicDepth,
                    intensity: StyleOptions.neumorphicIntensity,
                  ),
                  onPressed: () {
                    _pickImageFromCamera();
                  },
                  child: Center(
                    child: Text(AppLocalizations.of(context)!.take_image),
                  ),
                ),
              ],
            ),
            SizedBox(height: StyleOptions.elementsSpacing * 2),
            Text(
                AppLocalizations.of(context)!.from_flashcards,
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: StyleOptions.elementsSpacing),
            _appDb.flashcards.length == 0 ? Center(
              child: Text(AppLocalizations.of(context)!.no_flashcards),
            )
            : GridView.builder(
              physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _appDb.flashcards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  mainAxisExtent: 120,
                  mainAxisSpacing: StyleOptions.gridGap,
                  crossAxisSpacing: StyleOptions.gridGap,
                ),
                itemBuilder: (context, index) {
                  return SizedBox(
                    child: NeumorphicButton(
                      style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                        depth: _selectedFlashcards[index] ? StyleOptions.neumorphicDepth * -1 : StyleOptions.neumorphicDepth,
                        intensity: StyleOptions.neumorphicIntensity,
                        color: _selectedFlashcards[index] ? NeumorphicTheme.accentColor(context) : NeumorphicTheme.baseColor(context),
                      ),
                        onPressed: () {
                          setState(() {
                            _selectedFlashcards[index] = !_selectedFlashcards[index];
                          });
                        },
                        child: Container(

                          alignment: Alignment.center,
                          child: Text(
                              _appDb.flashcards[index]['set_name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),
                            overflow: TextOverflow.fade,
                          )
                        ),
                    ),
                  );
                }
            ),
            NeumorphicButton(
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                depth: StyleOptions.neumorphicDepth,
                intensity: StyleOptions.neumorphicIntensity,
              ),
              onPressed: () async {
                if(_imageFiles.length == 0 && _getSelectedFlashcardsIndexes().length == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error + ": " + AppLocalizations.of(context)!.no_added_images_or_flashcards)));
                  return;
                }

                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => LoadingBox(message: AppLocalizations.of(context)!.generating_quiz)
                );
                String? responseText = null;
                responseText = await _ai.generateQuiz(context, _imageFiles, _getSelectedFlashcards());

                Navigator.of(context).pop();

                if(responseText == null) {
                  return;
                }

                final responseTextCleaned = responseText
                    .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
                    .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
                    .trim();
                Map<String, dynamic> responseMap = jsonDecode(responseTextCleaned) as Map<String, dynamic>;
                if(responseMap['quiz_name'] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.invalid_response_from_model)));
                  return;
                }

                _appDb.quizzes.add(responseMap);
                _appDb.save();

                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.next),
            )
          ],
        ),
      ),
    );
  }
}