import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/main.dart';
import 'package:omnilearn/pages/language_page.dart';
import 'package:omnilearn/data/database.dart';
import 'package:omnilearn/elements/dialog_boxes.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:omnilearn/style/style_options.dart';

// ==================================
// PROFILE & APP SETTINGS PAGE
// ==================================

/// User profile and application settings page (language, student data, accent color, AI credentials)
class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _appDb = AppDatabase();

  final List<List<Color>> _accentColors = [
    [Color(0xFFFF0000), Color(0xFFFFFFFF)],
    [Color(0xFFFF6A00), Color(0xFFFFFFFF)],
    [Color(0xFFC8C800), Color(0xFF000000)],
    [Color(0xFF00C800), Color(0xFF000000)],
    [Color(0xFF0066FF), Color(0xFFFFFFFF)],
    [Color(0xFF6A00FF), Color(0xFFFFFFFF)],
    [Color(0xFFFD19FD), Color(0xFFFFFFFF)],
    [Color(0xFF858585), Color(0xFFFFFFFF)],
  ];

  @override
  void initState() {
    _appDb.load();
    super.initState();
  }

  TextEditingController _studentNameController = TextEditingController();
  TextEditingController _studentClassController = TextEditingController();
  TextEditingController _aiAPIKeyController = TextEditingController();
  TextEditingController _aiModelNameController = TextEditingController();

  void _changeStudentDataDialog() {
    _studentNameController.text = _appDb.studentName;
    _studentClassController.text = _appDb.studentClass;
    showDialog(
        context: context,
        builder: (context) {
          return StudentDialogBox(
            nameController: _studentNameController,
            classController: _studentClassController,
            onOK: (selectedSchool) {
              _saveStudentData(selectedSchool);
              Navigator.of(context).pop();
            },
            onCancel: () {
              Navigator.of(context).pop();
            },

          );
        }
    );
  }
  
  void _changeAiAPIKeyDialog() {
    _aiAPIKeyController.text = _appDb.aiAPIKey;
    showDialog(context: context, 
        builder: (context) {
          return PasswordDialogBox(
              title: AppLocalizations.of(context)!.set_api_key,
              controller: _aiAPIKeyController,
              onOK: () {
                _saveAiAPIKey();
                Navigator.of(context).pop();
              },
              onCancel: () {
                Navigator.of(context).pop();
              }
          );
        },
    );
  }

  void _changeAiModelNameDialog() {
    _aiModelNameController.text = _appDb.aiModelName;
    showDialog(context: context,
      builder: (context) {
        return TextDialogBox(
            title: AppLocalizations.of(context)!.set_ai_model,
            controller: _aiModelNameController,
            onOK: () {
              _saveAiModelName();
              Navigator.of(context).pop();
            },
            onCancel: () {
              Navigator.of(context).pop();
            }
        );
      },
    );
  }

  void _saveStudentData(selectedSchool) {
    setState(() {
      _appDb.studentName = _studentNameController.text.trim();
      _appDb.studentSchool = selectedSchool;
      _appDb.studentClass = _studentClassController.text.trim();
      _appDb.save();
    });
  }

  void _saveAiAPIKey() {
    setState(() {
      _appDb.aiAPIKey = _aiAPIKeyController.text.trim();
      _appDb.save();
    });
  }

  void _saveAiModelName() {
    setState(() {
      _appDb.aiModelName = _aiModelNameController.text.trim();
      _appDb.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: StyleOptions.pageHorizontalPadding, vertical: StyleOptions.pageVerticalPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeumorphicButton(
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                  depth: StyleOptions.neumorphicDepth,
                  intensity: StyleOptions.neumorphicIntensity,
                ),
                onPressed: () {
                  _changeStudentDataDialog();
                },
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _appDb.studentName,
                            style: TextStyle(fontSize: 28),
                          ),
                          Text(
                              "${AppLocalizations.of(context)!.school}: ${switch (_appDb.studentSchool) {
                                'primary' => AppLocalizations.of(context)!.primary_school,
                                'secondary' => AppLocalizations.of(context)!.secondary_school,
                                'university' => AppLocalizations.of(context)!.university,
                                _ => '',
                              }}"
                          ),
                          Text(
                              "${AppLocalizations.of(context)!.school_class}: ${_appDb.studentClass}"
                          ),
                        ],
                      ),
                      NeumorphicIcon(
                        BootstrapIcons.person_circle,
                        size: 80,
                        style: NeumorphicStyle(
                          depth: StyleOptions.neumorphicDepth,
                          intensity: StyleOptions.neumorphicIntensity,
                          color: NeumorphicTheme.defaultTextColor(context)
                        ),
                      ),
          
                    ],
                  ),
                ),
              ),
              SizedBox(height: StyleOptions.elementsSpacing),
              NeumorphicButton(
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                  depth: StyleOptions.neumorphicDepth,
                  intensity: StyleOptions.neumorphicIntensity,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage()));
                },
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          AppLocalizations.of(context)!.language,
                        style: TextStyle(
                          fontSize: StyleOptions.buttonTitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: NeumorphicTheme.defaultTextColor(context)
                        ),
                      ),
                      Text(AppLocalizations.of(context)!.lang, 
                        style: TextStyle(
                            fontSize: StyleOptions.buttonDescriptionFontSize,
                            fontWeight: FontWeight.normal,
                          color: NeumorphicTheme.disabledColor(context)
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: StyleOptions.elementsSpacing),
              Text(
                  "AI",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: StyleOptions.elementsSpacing),
              NeumorphicButton(
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                  depth: StyleOptions.neumorphicDepth,
                  intensity: StyleOptions.neumorphicIntensity,
                ),
                onPressed: () {
                  _changeAiAPIKeyDialog();
                },
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          AppLocalizations.of(context)!.set_api_key,
                        style: TextStyle(
                            fontSize: StyleOptions.buttonTitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: NeumorphicTheme.defaultTextColor(context)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: StyleOptions.elementsSpacing),
              NeumorphicButton(
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                  depth: StyleOptions.neumorphicDepth,
                  intensity: StyleOptions.neumorphicIntensity,
                ),
                onPressed: () {
                  _changeAiModelNameDialog();
                },
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          AppLocalizations.of(context)!.set_ai_model,
                        style: TextStyle(
                            fontSize: StyleOptions.buttonTitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: NeumorphicTheme.defaultTextColor(context)
                        ),
                      ),
                      Text(
                        _appDb.aiModelName,
                        style: TextStyle(
                          fontSize: StyleOptions.buttonDescriptionFontSize,
                          fontWeight: FontWeight.normal,
                          color: NeumorphicTheme.disabledColor(context)
                      ),
                    )
                    ],
                  ),
                ),
              ),
              SizedBox(height: StyleOptions.elementsSpacing),
              Text(
                AppLocalizations.of(context)!.appearance,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: StyleOptions.elementsSpacing),
              Neumorphic(
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                  depth: StyleOptions.neumorphicDepth,
                  intensity: StyleOptions.neumorphicIntensity,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: StyleOptions.settingsOptionHorizontalPadding, vertical: StyleOptions.settingsOptionVerticalPadding),
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.accent_color,
                        style: TextStyle(
                            fontSize: StyleOptions.buttonTitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: NeumorphicTheme.defaultTextColor(context)
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 5),
                      Wrap(
                        spacing: 30,
                        runSpacing: 10,
                        direction: Axis.horizontal,
                        children: _accentColors.map((color) {
                          return NeumorphicButton(
                            style: NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.circle(),
                              depth: StyleOptions.neumorphicDepth * -1,
                              intensity: StyleOptions.neumorphicIntensity,
                              color: color[0],
                            ),
                            onPressed: () {
                              setState(() {
                                _appDb.accentColor = color[0];
                                _appDb.textOnAccentColor = color[1];
                                _appDb.save();
                                NeumorphicTheme.of(context)?.updateCurrentTheme(
                                  NeumorphicTheme.of(context)!.current!.copyWith(
                                    accentColor: color[0],
                                  ),
                                );
          
                              });
                            },
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: _appDb.accentColor == color[0] ? Icon(
                                BootstrapIcons.check_lg,
                                color: color[1],
                                size: 15,
                              ) : Container(),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}