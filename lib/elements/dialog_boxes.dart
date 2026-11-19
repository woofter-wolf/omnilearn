import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/data/database.dart';
import 'package:omnilearn/style/style_options.dart';

// ==================================
// REUSABLE DIALOG BOXES
// ==================================

/// Custom neumorphic text input dialog box
class TextDialogBox extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final VoidCallback onOK;
  final VoidCallback onCancel;

  const TextDialogBox({
    super.key,
    required this.title,
    required this.controller,
    required this.onOK,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: 0,
          intensity: StyleOptions.neumorphicIntensity,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
          color: NeumorphicTheme.baseColor(context),
        ),
        padding: EdgeInsets.all(StyleOptions.dialogPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: StyleOptions.dialogHeaderFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: StyleOptions.dialogElementsSpacing),
            Neumorphic(
              style: NeumorphicStyle(
                depth: StyleOptions.neumorphicDepth * -1,
                intensity: StyleOptions.neumorphicIntensity,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
              ),
              padding: EdgeInsets.symmetric(horizontal: StyleOptions.inputBoxHorizontalPadding, vertical: StyleOptions.inputBoxVerticalPadding),
              child: TextField(
                controller: controller,
                cursorColor: NeumorphicTheme.defaultTextColor(context),
                decoration: InputDecoration.collapsed(
                  hintText: AppLocalizations.of(context)!.type_here,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DialogButton(
                  text: AppLocalizations.of(context)!.cancel,
                  onPressed: onCancel,
                ),
                SizedBox(width: StyleOptions.dialogButtonSpacing),
                DialogButton(
                  text: AppLocalizations.of(context)!.ok,
                  onPressed: onOK,
                ),
                SizedBox(width: StyleOptions.dialogButtonSpacing),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom neumorphic dialog for modifying student profile data (name, school type, class)
class StudentDialogBox extends StatefulWidget {
  final nameController;
  final classController;
  final Function(String selectedSchool) onOK;
  VoidCallback onCancel;

  StudentDialogBox({
    super.key,
    required this.nameController,
    required this.classController,
    required this.onOK,
    required this.onCancel,
  });

  @override
  State<StudentDialogBox> createState() => _StudentDialogBoxState();
}

class _StudentDialogBoxState extends State<StudentDialogBox> {
  late String _selectedSchool = "primary";
  final _appDb = AppDatabase();

  @override
  void initState() {
    _appDb.load();
    _selectedSchool = _appDb.studentSchool;
    super.initState();
  }

  TextEditingController _studentSchoolController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Map<String, String> _schools = {
      "primary": AppLocalizations.of(context)!.primary_school,
      "secondary": AppLocalizations.of(context)!.secondary_school,
      "university": AppLocalizations.of(context)!.university
    };
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: 0,
          intensity: StyleOptions.neumorphicIntensity,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
          color: NeumorphicTheme.baseColor(context),
        ),
        padding: EdgeInsets.all(StyleOptions.dialogPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.change_student_data,
              style: TextStyle(
                fontSize: StyleOptions.dialogHeaderFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: StyleOptions.dialogElementsSpacing),
            Text(AppLocalizations.of(context)!.student_name, textAlign: TextAlign.start),
            SizedBox(height: StyleOptions.labelInputSpacing),
            Neumorphic(
              style: NeumorphicStyle(
                depth: StyleOptions.neumorphicDepth * -1,
                intensity: StyleOptions.neumorphicIntensity,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
              ),
              padding: EdgeInsets.symmetric(horizontal: StyleOptions.inputBoxHorizontalPadding, vertical: StyleOptions.inputBoxVerticalPadding),
              child: TextField(
                controller: widget.nameController,
                cursorColor: NeumorphicTheme.defaultTextColor(context),
                decoration: InputDecoration.collapsed(
                  hintText: AppLocalizations.of(context)!.type_here,
                ),
              ),
            ),
            SizedBox(height: StyleOptions.dialogElementsSpacing),
            Text(AppLocalizations.of(context)!.school, textAlign: TextAlign.start),
            SizedBox(height: StyleOptions.labelInputSpacing),
            Neumorphic(
              style: NeumorphicStyle(
                depth: StyleOptions.neumorphicDepth * -1,
                intensity: StyleOptions.neumorphicIntensity,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
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
                          color: NeumorphicTheme.defaultTextColor(context),
                          fontWeight: FontWeight.normal
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (selectedValue) {
                    if (selectedValue != null) {
                      setState(() {
                        _selectedSchool = selectedValue;
                      });
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: StyleOptions.dialogElementsSpacing),
            Text(AppLocalizations.of(context)!.school_class, textAlign: TextAlign.start),
            SizedBox(height: StyleOptions.labelInputSpacing),
            Neumorphic(
              style: NeumorphicStyle(
                depth: StyleOptions.neumorphicDepth * -1,
                intensity: StyleOptions.neumorphicIntensity,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
              ),
              padding: EdgeInsets.symmetric(horizontal: StyleOptions.inputBoxHorizontalPadding, vertical: StyleOptions.inputBoxVerticalPadding),
              child: TextField(
                controller: widget.classController,
                cursorColor: NeumorphicTheme.defaultTextColor(context),
                decoration: InputDecoration.collapsed(
                  hintText: AppLocalizations.of(context)!.type_here,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DialogButton(
                  text: AppLocalizations.of(context)!.cancel,
                  onPressed: widget.onCancel,
                ),
                SizedBox(width: StyleOptions.dialogButtonSpacing),
                DialogButton(
                  text: AppLocalizations.of(context)!.ok,
                  onPressed: () => widget.onOK(_selectedSchool),
                ),
                SizedBox(width: StyleOptions.dialogButtonSpacing),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom obfuscated password input dialog box
class PasswordDialogBox extends StatelessWidget {
  final controller;
  String title = "";
  VoidCallback onOK;
  VoidCallback onCancel;

  PasswordDialogBox({
    super.key,
    required this.title,
    required this.controller,
    required this.onOK,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: 0,
          intensity: StyleOptions.neumorphicIntensity,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
          color: NeumorphicTheme.baseColor(context),
        ),
        padding: EdgeInsets.all(StyleOptions.dialogPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: StyleOptions.dialogHeaderFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: StyleOptions.dialogElementsSpacing),
            Neumorphic(
              style: NeumorphicStyle(
                depth: StyleOptions.neumorphicDepth * -1,
                intensity: StyleOptions.neumorphicIntensity,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
              ),
              padding: EdgeInsets.symmetric(horizontal: StyleOptions.inputBoxHorizontalPadding, vertical: StyleOptions.inputBoxVerticalPadding),
              child: TextField(
                controller: controller,
                cursorColor: NeumorphicTheme.defaultTextColor(context),
                decoration: InputDecoration.collapsed(
                  hintText: AppLocalizations.of(context)!.type_here,
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DialogButton(
                  text: AppLocalizations.of(context)!.cancel,
                  onPressed: onCancel,
                ),
                SizedBox(width: StyleOptions.dialogButtonSpacing),
                DialogButton(
                  text: AppLocalizations.of(context)!.ok,
                  onPressed: onOK,
                ),
                SizedBox(width: StyleOptions.dialogButtonSpacing),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom confirmation dialog box with Yes/No choices
class ConfirmationDialogBox extends StatelessWidget {
  String title = "";
  String message = "";
  VoidCallback onYes;
  VoidCallback onNo;

  ConfirmationDialogBox({
    super.key,
    required this.title,
    required this.message,
    required this.onYes,
    required this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: 0,
          intensity: StyleOptions.neumorphicIntensity,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
          color: NeumorphicTheme.baseColor(context)
        ),
        padding: EdgeInsets.all(StyleOptions.dialogPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: StyleOptions.dialogHeaderFontSize,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: StyleOptions.dialogElementsSpacing),
            Text(
              message
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DialogButton(
                  text: AppLocalizations.of(context)!.no,
                  onPressed: onNo,
                ),
                SizedBox(width: StyleOptions.dialogButtonSpacing),
                DialogButton(
                  text: AppLocalizations.of(context)!.yes,
                  onPressed: onYes,
                ),
                SizedBox(width: StyleOptions.dialogButtonSpacing),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// Reusable neumorphic action button for dialog boxes
class DialogButton extends StatelessWidget {
  String text;
  VoidCallback onPressed;
  DialogButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
        depth: StyleOptions.neumorphicDepth,
        intensity: StyleOptions.neumorphicIntensity
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
