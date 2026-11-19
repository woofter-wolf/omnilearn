# OmniLearn

## Introduction

OmniLearn is a mobile app created with primary, secondary and higher education students in mind. It uses AI and computer vision technologies (Vision LLM) for analyzing teaching materials (photos of textbooks or notes from notebooks) and transforms them into interactive and accessible learning materials.

**Technologies used:** Flutter (app framework), Hive DB (local database), OpenRouter API (AI), Neumorphic Design (app style)

**Key features:**

1. Flashcards generator
    - Creating flashcards from images of teaching materials
    - Interactive interface (swipe / flip) with the ability to tag level of mastery of the material (mastered / difficult)
2. Quizzes generator:
    - Generating quizzes from images of teaching materials or from flashcards
    - Single choice and multi choice questions support
    - Support for the explanations to every question
    - Scoring system and score presentation in percentage
3. Task scanner:
    - Analysis of uploaded tasks included in images
    - Interactive AI chat, which instead of giving complete solutions, guides the student "by the hand" through the task step by step
4. Accessibility and personalization:
    - Support for 9 languages
    - Ability to personalize student's data (name, school, class)
    - Ability to personalize UI accent color

---

## Support

| Platform | Supported |
|----------|-----------|
| Android  | ✅        |
| iOS      | ❔ Not tested |

---

## Building

To build this app you need to install dependencies. To do this, in project root directory, type this command:

```
flutter pub get
```

To build project, type:

```
flutter build apk --split-per-abi --release # Release version

flutter build apk --debug # Debug version
```

Built app will be in ```build/app/outputs/flutter-apk/app-[architecture]-[release or debug].apk```

## Installation

> Before you install, prepare API key from OpenRouter [Guide here](https://developer.puter.com/tutorials/how-to-get-openrouter-api-key/) and get a name of a model you want to use (**Model has to support text and images as an input!**) [Supported models](https://openrouter.ai/models?input_modalities=text,image&output_modalities=text)
>
> Before using API you need to deposit at least $5 to your account credits
> 
> The app was tested on `nvidia/nemotron-3.5-super-vl:free`

### Android

#### Option 1: Direct Installation on Device (APK Sideloading)

1. Transfer the generated APK file (`app-[architecture]-[release or debug].apk`) to your Android device via USB cable, cloud storage, or direct download.
2. Open the **File Manager** app on your Android device and navigate to the folder containing the `.apk` file.
3. Tap the `.apk` file to initiate installation.
4. If prompted, grant permission to install apps from unknown sources:
   - Go to **Settings > Security & Privacy > Install unknown apps** (or enable **"Allow from this source"** for your File Manager).
5. Tap **Install** and launch **OmniLearn** once completed.

#### Option 2: Installation via ADB (Android Debug Bridge)

If your Android device or emulator is connected to your computer via USB:
1. Enable **Developer Options** and **USB Debugging** on your device (**Settings > System > Developer Options > USB Debugging**).
2. Open a terminal on your computer and execute:
   ```
   adb install build/app/outputs/flutter-apk/app-[architecture]-[release or debug].apk
   ```

> For newer versions of Android you may have to enable installation of apps from unverified developers. [Guide here](https://support.google.com/android/answer/17588095?hl=en-IN)

## Author / License

Developed by **WoofterWolf**
- Website: [woofterwolf.space](https://woofterwolf.space)
- GitHub: [woofter-wolf](https://github.com/woofter-wolf)

This software is distributed under [MIT License](LICENSE.md).