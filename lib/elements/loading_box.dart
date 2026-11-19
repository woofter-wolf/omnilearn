import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:omnilearn/style/style_options.dart';

// ==================================
// LOADING INDICATOR DIALOG
// ==================================

/// Non-dismissible neumorphic loading dialog box with progress indicator
class LoadingBox extends StatelessWidget {
  String message = "";

  LoadingBox({
    super.key,
    required this.message
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        child: Neumorphic(
          style: NeumorphicStyle(
              depth: 0,
              intensity: StyleOptions.neumorphicIntensity,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
              color: NeumorphicTheme.baseColor(context)
          ),
          padding: EdgeInsets.all(StyleOptions.dialogPadding),
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                SizedBox(height: StyleOptions.dialogElementsSpacing),
                NeumorphicProgressIndeterminate(
                  style: ProgressStyle(
                    depth: StyleOptions.neumorphicDepth * -1,
                  ),
                  duration: Duration(seconds: 3),
                )
                // CircularProgressIndicator()
              ],
            ),
          ),
        ),
      ),
    );
  }
}