import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

// ==================================
// GLOBAL STYLE OPTIONS & CONSTANTS
// ==================================

/// Central storage of global UI style constants, spacing, neumorphic depth, and animations
class StyleOptions {
  static const double neumorphicDepth = 3;
  static const double neumorphicIntensity = 0.45;

  static const double elementRoundness = 15;

  static const double labelInputSpacing = 8;

  static const double inputBoxHorizontalPadding = 14;
  static const double inputBoxVerticalPadding = 14;

  static const double pageHorizontalPadding = 20;
  static const double pageVerticalPadding = 10;

  static const double settingsOptionVerticalPadding = 10;
  static const double settingsOptionHorizontalPadding = 15;

  static const double elementsSpacing = 10;

  static const double gridGap = 5;

  static const double flashcardVerticalPadding = 10;
  static const double flashcardHorizontalPadding = 10;

  static const double listTileVerticalPadding = 8;
  static const double listTileHorizontalPadding = 4;

  static const double buttonTitleFontSize = 17;
  static const double buttonDescriptionFontSize = 13;

  static const double sideButtonMargin = 10;

  static const double dialogPadding = 20;
  static const double dialogHeaderFontSize = 20;
  static const double dialogElementsSpacing = 12;
  static const double dialogButtonSpacing = 14;

  static const double optionVerticalPadding = 15;
  static const double optionHorizontalPadding = 20;
  static const double optionsSpacing = 7;

  static const double imagesMargin = 10;

  static const double chatMessageHorizontalPadding = 10;
  static const double chatMessageVerticalPadding = 6;
  static const double chatMessageElementsSpacing = 7;
  static const double chatMessagesSpacing = 13;

  static const double imageSelectionBoxBorderMargin = 5;
  static const double imageSelectionBoxVerticalPadding = 2;
  static const double imageSelectionBoxHorizontalPadding = 12;

  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Curve switchInCurve = Curves.easeIn;
  static const Curve switchOutCurve = Curves.easeOut;
  static const Curve movingCurve = Curves.easeInOut;
}