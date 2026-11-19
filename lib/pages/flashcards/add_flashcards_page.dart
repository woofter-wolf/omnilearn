import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omnilearn/elements/loading_box.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/data/database.dart';
import 'package:omnilearn/style/style_options.dart';
import 'package:omnilearn/tools/ai.dart';

// ==================================
// ADD FLASHCARDS GENERATION PAGE
// ==================================

/// Page for generating a new flashcard set from user images using AI vision
class AddFlashcardsPage extends StatefulWidget {
  AddFlashcardsPage({super.key});

  @override
  State<AddFlashcardsPage> createState() => _AddFlashcardsPageState();
}

class _AddFlashcardsPageState extends State<AddFlashcardsPage> {
  List<XFile> _imageFiles = [];
  ImagePicker _picker = ImagePicker();
  final _appDb = AppDatabase();
  final _ai = AI();

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

  @override
  void initState() {
    _appDb.load();
    _ai.setProvider("openrouter");
    _ai.setApiKey(_appDb.aiAPIKey);
    _ai.setModelName(_appDb.aiModelName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: Text(AppLocalizations.of(context)!.add_flashcards),
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
            Text(AppLocalizations.of(context)!.add_flashcards_description),
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
            SizedBox(height: StyleOptions.elementsSpacing),
            NeumorphicButton(
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                depth: StyleOptions.neumorphicDepth,
                intensity: StyleOptions.neumorphicIntensity,
              ),
                onPressed: () async {
                  if(_imageFiles.length == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error + ": " + AppLocalizations.of(context)!.no_added_images)));
                    return;
                  }

                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => LoadingBox(message: AppLocalizations.of(context)!.generating_flashcards)
                  );
                  String? responseText = null;
                  responseText = await _ai.generateFlashcards(context, _imageFiles);

                  Navigator.of(context).pop();

                  if(responseText == null) {
                    return;
                  }

                  final responseTextCleaned = responseText
                      .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
                      .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
                      .trim();
                  Map<String, dynamic> responseMap = jsonDecode(responseTextCleaned) as Map<String, dynamic>;
                  if(responseMap['set_name'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.invalid_response_from_model)));
                    return;
                  }

                  _appDb.flashcards.add(responseMap);
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