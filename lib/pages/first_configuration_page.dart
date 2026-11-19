import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/data/database.dart';
import 'package:omnilearn/main.dart';
import 'package:omnilearn/style/style_options.dart';

// ==================================
// FIRST TIME APP SETUP / ONBOARDING
// ==================================

/// Onboarding configuration wizard page shown when the app is launched for the first time
class FirstConfigurationPage extends StatefulWidget {
  FirstConfigurationPage({super.key});

  @override
  State<FirstConfigurationPage> createState() => _FirstConfigurationPageState();
}

class _FirstConfigurationPageState extends State<FirstConfigurationPage> {
  final _appDb = AppDatabase(); // App DB
  int _subpageIndex = 0;
  final _studentDataFormKey = GlobalKey<FormState>();
  final _aiModelFormKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController(text: "Student");
  String _selectedSchool = "primary";
  final _studentClassController = TextEditingController(text: "1");
  final _aiAPIKeyController = TextEditingController();
  final _aiModelNameController = TextEditingController();

  @override
  void initState() {
    _appDb.load(); // Load app database
    // Set default values
    _selectedSchool = _appDb.studentSchool;
    _studentNameController.text = _appDb.studentName;
    _studentClassController.text = _appDb.studentClass;
    _aiAPIKeyController.text = _appDb.aiAPIKey;
    _aiModelNameController.text = _appDb.aiModelName;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: StyleOptions.pageVerticalPadding, horizontal: StyleOptions.pageHorizontalPadding),
          child: Column(
            children: [
              Expanded(
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
                  child: _subpageIndex == 0 ? WelcomeSubpage() : _subpageIndex == 1 ? SelectLanguageSubpage() : _subpageIndex == 2 ? StudentDataSubpage(
                    formKey: _studentDataFormKey,
                    nameController: _studentNameController,
                    classController: _studentClassController,
                    onSchoolChange: (s) {
                      setState(() {
                        _selectedSchool = s;
                      });
                    },
                  ) : _subpageIndex == 3 ? AIModelSubpage(
                    formKey: _aiModelFormKey,
                    aiAPIKeyController: _aiAPIKeyController,
                    aiModelNameController: _aiModelNameController,
                  ) : EndSubpage(),
                ),
              ),
              _subpageIndex == 0 ? NeumorphicButton(
                style: NeumorphicStyle(
                  depth: StyleOptions.neumorphicDepth,
                  intensity: StyleOptions.neumorphicIntensity,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                ),
                onPressed: () {
                  setState(() {
                    _subpageIndex++;
                  });
                },
                child: Icon(
                    Icons.arrow_right_alt,
                  color: NeumorphicTheme.defaultTextColor(context),
                ),
              ) : ButtonsBar(
                onBack: () {
                  setState(() {
                    _subpageIndex--;
                  });
                },
                onNext: () {
                  bool isValid = true;

                  if (_subpageIndex == 4) {
                    isValid = false;
                    _appDb.appConfigured = true;
                    _appDb.save();
                    appConfiguredNotifier.value = true;
                  }
                  else if (_subpageIndex == 2) {
                    isValid = _studentDataFormKey.currentState?.validate() ?? false;
                    if (isValid) {
                      _appDb.studentName = _studentNameController.text.trim();
                      _appDb.studentSchool = _selectedSchool;
                      _appDb.studentClass = _studentClassController.text.trim();
                      _appDb.save();
                    }
                  }
                  else if (_subpageIndex == 3) {
                    isValid = _aiModelFormKey.currentState?.validate() ?? false;
                    if (isValid) {
                      _appDb.aiAPIKey = _aiAPIKeyController.text.trim();
                      _appDb.aiModelName = _aiModelNameController.text.trim();
                      _appDb.save();
                    }
                  }

                  if (isValid) {
                    setState(() {
                      _subpageIndex++;
                    });
                  }
                },
              )
            ],
          ),
        )
      ),
    );
  }
}

// Welcome subpage
class WelcomeSubpage extends StatelessWidget {
  WelcomeSubpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
              "OmniLearn",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 50
              )
          ),
          SizedBox(height: 15),
          Text(AppLocalizations.of(context)!.welcome),
        ],
      ),
    );
  }
}

class ButtonsBar extends StatelessWidget {
  VoidCallback onBack;
  VoidCallback onNext;
  ButtonsBar({
    super.key,
    required this.onBack,
    required this.onNext
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NeumorphicButton(
          style: NeumorphicStyle(
            depth: StyleOptions.neumorphicDepth,
            intensity: StyleOptions.neumorphicIntensity,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
          ),
          onPressed: () {
            onBack();
          },
          child: Text(AppLocalizations.of(context)!.back),
        ),
        SizedBox(width: StyleOptions.dialogButtonSpacing),
        NeumorphicButton(
          style: NeumorphicStyle(
            depth: StyleOptions.neumorphicDepth,
            intensity: StyleOptions.neumorphicIntensity,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
          ),
          onPressed: () {
            onNext();
          },
          child: Text(AppLocalizations.of(context)!.next),
        ),
      ],
    );
  }
}

class SelectLanguageSubpage extends StatefulWidget {
  SelectLanguageSubpage({super.key});

  @override
  State<SelectLanguageSubpage> createState() => _SelectLanguageSubpageState();
}

class _SelectLanguageSubpageState extends State<SelectLanguageSubpage> {
  final _appDb = AppDatabase();

  final List<List<String?>> _languages = [
    [null, "System default"],
    ["en", "English"],
    ["pl", "Polski"],
    ["de", "Deutsch"],
    ["es", "Español"],
    ["fr", "Français"],
    ["it", "Italiano"],
    ["ru", "Русский"],
    ["ja", "日本語"],
    ["zh", "中文"]
  ];

  void _changeLanguage(int index) {
    setState(() {
      appLocaleNotifier.value = _languages[index][0] == null ? null : Locale(_languages[index][0]!);
      _appDb.lang = _languages[index][0];
      _appDb.save();
    });
  }

  @override
  void initState() {
    super.initState();
    _appDb.load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
            AppLocalizations.of(context)!.select_language,
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(height: StyleOptions.elementsSpacing * 2),
        Expanded(
          child: SingleChildScrollView(
            child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final langCode = _languages[index][0];
                  final langText = _languages[index][1];
                  final currentLocale = appLocaleNotifier.value;
                  final isSelected = langCode == null ? currentLocale == null : langCode == currentLocale.toString();

                  return NeumorphicButton(
                      margin: EdgeInsets.only(bottom: StyleOptions.elementsSpacing),
                      style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                        depth: StyleOptions.neumorphicDepth,
                        intensity: StyleOptions.neumorphicIntensity,
                      ),
                      onPressed: () {
                        _changeLanguage(index);
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              langText!,
                              style: TextStyle(
                                  fontSize: StyleOptions.buttonTitleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: NeumorphicTheme.defaultTextColor(context)
                              ),
                            ),
                            Icon(
                              isSelected ? BootstrapIcons.check_lg : null,
                              color: NeumorphicTheme.defaultTextColor(context),
                            )
                          ],
                        ),
                      )
                  );
                }
            ),
          ),
        ),
      ],
    );
  }
}

class StudentDataSubpage extends StatefulWidget {
  var formKey = GlobalKey<FormState>();
  final TextEditingController nameController;
  final TextEditingController classController;
  ValueChanged<String> onSchoolChange;

  StudentDataSubpage({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.classController,
    required this.onSchoolChange,
  });

  @override
  State<StudentDataSubpage> createState() => _StudentDataSubpageState();
}

class _StudentDataSubpageState extends State<StudentDataSubpage> {
  late String _selectedSchool = "primary";
  final _schoolController = TextEditingController();
  final _appDb = AppDatabase();

  @override
  void initState() {
    _appDb.load();
    _selectedSchool = _appDb.studentSchool;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> _schools = {
      "primary": AppLocalizations.of(context)!.primary_school,
      "secondary": AppLocalizations.of(context)!.secondary_school,
      "university": AppLocalizations.of(context)!.university
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                Text(
                    AppLocalizations.of(context)!.enter_student_data,
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: StyleOptions.elementsSpacing * 2),
                Form(
                    key: widget.formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.student_name,
                              textAlign: TextAlign.start),
                          SizedBox(height: StyleOptions.labelInputSpacing),
                          Neumorphic(
                            style: NeumorphicStyle(
                              depth: StyleOptions.neumorphicDepth * -1,
                              intensity: StyleOptions.neumorphicIntensity,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(
                                      StyleOptions.elementRoundness)),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: StyleOptions.inputBoxHorizontalPadding,
                                vertical: StyleOptions.inputBoxVerticalPadding),
                            child: TextFormField(
                                controller: widget.nameController,
                                cursorColor: NeumorphicTheme.defaultTextColor(
                                    context),
                                decoration: InputDecoration.collapsed(
                                  hintText: AppLocalizations.of(context)!.type_here,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .this_field_is_required;
                                  }
                                  return null;
                                }
                            ),
                          ),
                          SizedBox(height: StyleOptions.elementsSpacing),
                          Text(AppLocalizations.of(context)!.school,
                              textAlign: TextAlign.start),
                          SizedBox(height: StyleOptions.labelInputSpacing),
                          Neumorphic(
                            style: NeumorphicStyle(
                              depth: StyleOptions.neumorphicDepth * -1,
                              intensity: StyleOptions.neumorphicIntensity,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(
                                      StyleOptions.elementRoundness)),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 2),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSchool,
                                isExpanded: true,
                                dropdownColor: NeumorphicTheme.baseColor(context),
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: NeumorphicTheme.defaultTextColor(context),
                                ),
                                items: _schools.entries.map((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(
                                      entry.value,
                                      style: TextStyle(
                                          color: NeumorphicTheme.defaultTextColor(
                                              context),
                                          fontWeight: FontWeight.normal
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (selectedValue) {
                                  if (selectedValue != null) {
                                    setState(() {
                                      _selectedSchool = selectedValue;
                                      widget.onSchoolChange(_selectedSchool);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: StyleOptions.elementsSpacing),
                          Text(AppLocalizations.of(context)!.school_class,
                              textAlign: TextAlign.start),
                          SizedBox(height: StyleOptions.labelInputSpacing),
                          Neumorphic(
                            style: NeumorphicStyle(
                              depth: StyleOptions.neumorphicDepth * -1,
                              intensity: StyleOptions.neumorphicIntensity,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(
                                      StyleOptions.elementRoundness)),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: StyleOptions.inputBoxHorizontalPadding,
                                vertical: StyleOptions.inputBoxVerticalPadding),
                            child: TextFormField(
                                controller: widget.classController,
                                keyboardType: TextInputType.number,
                                cursorColor: NeumorphicTheme.defaultTextColor(
                                    context),
                                decoration: InputDecoration.collapsed(
                                  hintText: AppLocalizations.of(context)!.type_here,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .this_field_is_required;
                                  }
                                  return null;
                                }
                            ),
                          ),
                        ]
                    )
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class AIModelSubpage extends StatefulWidget {
  var formKey = GlobalKey<FormState>();
  final aiAPIKeyController;
  final aiModelNameController;
  AIModelSubpage({
    super.key,
    required this.formKey,
    this.aiAPIKeyController,
    this.aiModelNameController,
  });

  @override
  State<AIModelSubpage> createState() => _AIModelSubpageState();
}

class _AIModelSubpageState extends State<AIModelSubpage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                Text(
                    AppLocalizations.of(context)!.configure_ai,
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: StyleOptions.elementsSpacing * 2),
                Text(AppLocalizations.of(context)!.configure_ai_description),
                SizedBox(height: StyleOptions.elementsSpacing),
                Form(
                  key: widget.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.set_api_key, textAlign: TextAlign.start),
                      SizedBox(height: StyleOptions.labelInputSpacing),
                      Neumorphic(
                        style: NeumorphicStyle(
                          depth: StyleOptions.neumorphicDepth * -1,
                          intensity: StyleOptions.neumorphicIntensity,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(
                                  StyleOptions.elementRoundness)),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: StyleOptions.inputBoxHorizontalPadding,
                            vertical: StyleOptions.inputBoxVerticalPadding),
                        child: TextFormField(
                            controller: widget.aiAPIKeyController,
                            cursorColor: NeumorphicTheme.defaultTextColor(
                                context),
                            decoration: InputDecoration.collapsed(
                              hintText: AppLocalizations.of(context)!.type_here,
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .this_field_is_required;
                              }
                              return null;
                            }
                        ),
                      ),
                      SizedBox(height: StyleOptions.elementsSpacing),
                      Text(AppLocalizations.of(context)!.set_ai_model, textAlign: TextAlign.start),
                      SizedBox(height: StyleOptions.labelInputSpacing),
                      Neumorphic(
                        style: NeumorphicStyle(
                          depth: StyleOptions.neumorphicDepth * -1,
                          intensity: StyleOptions.neumorphicIntensity,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(
                                  StyleOptions.elementRoundness)),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: StyleOptions.inputBoxHorizontalPadding,
                            vertical: StyleOptions.inputBoxVerticalPadding),
                        child: TextFormField(
                            controller: widget.aiModelNameController,
                            cursorColor: NeumorphicTheme.defaultTextColor(
                                context),
                            decoration: InputDecoration.collapsed(
                              hintText: AppLocalizations.of(context)!.type_here,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .this_field_is_required;
                              }
                              return null;
                            }
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class EndSubpage extends StatelessWidget {
  EndSubpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
              AppLocalizations.of(context)!.you_are_good_to_go,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30
            ),
          ),
          SizedBox(height: StyleOptions.elementsSpacing),
          Text(AppLocalizations.of(context)!.press_next_to_complete)
        ],
      ),
    );
  }
}