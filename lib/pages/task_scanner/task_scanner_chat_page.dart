import 'dart:convert';
import 'dart:io';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/data/database.dart';
import 'package:omnilearn/style/style_options.dart';
import 'package:omnilearn/tools/ai.dart';
import 'package:omnilearn/tools/image_saver.dart';
import 'package:image_picker/image_picker.dart';

// ==================================
// MAIN CHAT PAGE
// ==================================

/// Main chat page of Task Scanner module
class TaskScannerChatPage extends StatefulWidget {
  final int chatIndex;
  final bool afterCreation;

  TaskScannerChatPage({
    super.key,
    required this.chatIndex,
    this.afterCreation = false
  });

  @override
  State<TaskScannerChatPage> createState() => _TaskScannerChatPageState();
}

class _TaskScannerChatPageState extends State<TaskScannerChatPage> {
  final _appDb = AppDatabase();
  bool _isGenerating = false;
  bool _generationFailed = false;
  bool _lockMessageInputBar = false;
  final _imageSaver = ImageSaver();
  final _scrollController = ScrollController();
  final _ai = AI();

  // ==================================
  // OVERRIDE METHODS
  // ==================================

  /// Executes on page opening
  @override
  void initState() {
    _appDb.load();
    _ai.setProvider("openrouter");
    _ai.setApiKey(_appDb.aiAPIKey);
    _ai.setModelName(_appDb.aiModelName);
    super.initState();
    if(widget.afterCreation) {
      WidgetsBinding.instance.addPostFrameCallback((_){
        _generateAnswer();
      });
    }
    else {
      _lockUnlockMessageInputBar();
      if(_isLastMessageFromUser()){
        _generateAnswer();
      }
    }
  }

  /// Executes at page closing
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ==================================
  // ANSWER GENERATION METHODS
  // ==================================

  /// Generates the answer for the user
  /// The answer is saved to the database
  Future<void> _generateAnswer() async {
    _isGenerating = true;
    _lockUnlockMessageInputBar();
    _scrollToBottom();

    String? responseText = null;
    responseText = await _ai.generateTaskScannerMessage(context, _appDb.taskScannerChatHistory[widget.chatIndex]);

    if(responseText == null) {
      setState(() {
        _isGenerating = false;
        _generationFailed = true;
        _lockUnlockMessageInputBar();
      });
      _scrollToBottom();
      return;
    }

    final responseTextCleaned = responseText
        .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
        .trim();
    List responseList = jsonDecode(responseTextCleaned) as List;

    setState(() {
      for(var e in responseList) {
        Map<String, Object> newEntry = Map<String, Object>.from(e as Map);
        newEntry['creation_date'] = DateTime.now().toIso8601String();
        _appDb.taskScannerChatHistory[widget.chatIndex]['messages'].add(newEntry);
      }
      _isGenerating = false;
      _generationFailed = false;
      _lockUnlockMessageInputBar();
    });
    _scrollToBottom();
  }

  // ==================================
  // ACTION METHODS
  // ==================================

  /// Scrolls to the bottom of the chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
        );
      }
    });
  }

  /// Locks/unlocks bottom message input bar
  void _lockUnlockMessageInputBar() {
    final messages = _appDb.taskScannerChatHistory[widget.chatIndex]['messages'];
    setState(() {
      _lockMessageInputBar = _isGenerating || messages[messages.length - 1]['type'] == 'quiz_question' || messages[messages.length - 1]['type'] == 'open_question';
    });
  }

  // ==================================
  // RETURNING METHODS
  // ==================================

  bool _isLastMessageFromUser() {
    final chat = _appDb.taskScannerChatHistory[widget.chatIndex];
    return chat['messages'][chat['messages'].length - 1]['role'] == 'user';
  }

  List<String> _returnChatImagesUrl(Map chatElement) {
    List<String> imagesUrl = [];
    for(var e in chatElement['content']) {
      if(e['type'] == 'image') {
        imagesUrl.add(e['image_url']);
      }
    }
    return imagesUrl;
  }

  // ==================================
  // GETTERS
  // ==================================

  List _getSubmittedOptions(List messages, int index) {
    if(index + 1 < messages.length) {
      if(messages[index + 1]['type'] == 'quiz_answer') {
        return messages[index + 1]['content']['selected_options'];
      }
    }
    return [];
  }

  String _getAnswerFromOpenQuestion(List messages, int index) {
    if(index + 1 < messages.length) {
      if(messages[index + 1]['type'] == 'open_answer') {
        return messages[index + 1]['content']['entered_answer'];
      }
    }
    return "";
  }

  // ==================================
  // EVENTS
  // ==================================

  Future<void> _onQuizAnswerSubmit(List selectedOptions) async {
    Map<String, Object> newEntry = {
      'role': 'user',
      'creation_date': DateTime.now().toIso8601String(),
      'type': 'quiz_answer',
      'content': {
        'selected_options': selectedOptions
      }
    };
    _appDb.taskScannerChatHistory[widget.chatIndex]['messages'].add(newEntry);
    _appDb.save();
    await _generateAnswer();
  }

  Future<void> _onMessageSubmit(String messageText, List<XFile> images) async {
    List messageContent = [];
    if(images.length > 0) {
      List savedImages = await _imageSaver.saveMultipleImages(images);
      for(final e in savedImages) {
        messageContent.add(
            {
              'type': 'image',
              'image_url': e
            }
        );
      }
    }
    messageContent.add(
      {
        'type': 'text',
        'text': messageText
      }
    );
    Map<String, Object> newEntry = {
      'role': 'user',
      'creation_date': DateTime.now().toIso8601String(),
      'type': 'message',
      'content': messageContent
    };
    _appDb.taskScannerChatHistory[widget.chatIndex]['messages'].add(newEntry);
    _appDb.save();
    await _generateAnswer();
  }

  Future<void> _onOpenQuestionAnswerSubmit(String enteredAnswer) async {
    Map<String, Object> newEntry = {
      'role': 'user',
      'creation_date': DateTime.now().toIso8601String(),
      'type': 'open_answer',
      'content': {
        'entered_answer': enteredAnswer
      }
    };
    _appDb.taskScannerChatHistory[widget.chatIndex]['messages'].add(newEntry);
    _appDb.save();
    await _generateAnswer();
  }

  // ==================================
  // BUILD METHOD VIEW
  // ==================================
  @override
  Widget build(BuildContext context) {
    final chat = _appDb.taskScannerChatHistory[widget.chatIndex];
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: Text(AppLocalizations.of(context)!.task_scanner),
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
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: StyleOptions.pageHorizontalPadding, vertical: StyleOptions.pageVerticalPadding),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: chat['messages'].length,
                          itemBuilder: (context, index) {
                            bool isSubmitted = index != chat['messages'].length - 1 || _isGenerating;
                            return Container(
                              margin: EdgeInsets.only(bottom: StyleOptions.chatMessagesSpacing),
                                child:
                                  // Widget for initial images
                                  chat['messages'][index]['type'] == 'initial_images'
                                  ? UserInputElementWidget(
                                    text: '',
                                    imagesFilePath: _returnChatImagesUrl(
                                        chat['messages'][index]),
                                    creationDate: DateTime.tryParse(chat['messages'][index]['creation_date'])!,
                                  )
                                  // Widget for user messages
                                  : chat['messages'][index]['type'] == 'message' && chat['messages'][index]['role'] == 'user'
                                  ? UserInputElementWidget(
                                    text: chat['messages'][index]['content']
                                        .where((e) => e['type'] == 'text')
                                        .toList()[0]['text'].toString(),
                                    imagesFilePath: _returnChatImagesUrl(
                                        chat['messages'][index]),
                                    creationDate: DateTime.tryParse(chat['messages'][index]['creation_date'])!,
                                  )
                                  // Widget for agent text output
                                  : chat['messages'][index]['type'] == 'message' && chat['messages'][index]['role'] == 'agent'
                                  ? AgentTextOutputElementWidget(
                                    text: chat['messages'][index]['content']
                                      .where((e) => e['type'] == 'text')
                                      .toList()[0]['text'].toString(),
                                    creationDate: DateTime.tryParse(chat['messages'][index]['creation_date'])!,
                                  )
                                  // Widget for single choice questions
                                  : chat['messages'][index]['type'] == 'quiz_question' && chat['messages'][index]['content']['correct_options'].length == 1
                                  ? SingleChoiceQuestionChatWidget(
                                    question: chat['messages'][index]['content']['question'],
                                    options: chat['messages'][index]['content']['options'],
                                    selectedOptionIndex: _getSubmittedOptions(chat['messages'], index).length == 0 ? -1 : _getSubmittedOptions(chat['messages'], index)[0],
                                    correctOptionIndex: isSubmitted ? chat['messages'][index]['content']['correct_options'][0] : -1,
                                    isSubmitted: isSubmitted,
                                    onSubmit: (selectedOption) async {
                                      await _onQuizAnswerSubmit([selectedOption]);
                                    },
                                    creationDate: DateTime.tryParse(chat['messages'][index]['creation_date'])!,
                                  )
                                  // Widget for multi choice questions
                                  : chat['messages'][index]['type'] == 'quiz_question' && chat['messages'][index]['content']['correct_options'].length > 1
                                  ? MultiChoiceQuestionChatWidget(
                                    question: chat['messages'][index]['content']['question'],
                                    options: chat['messages'][index]['content']['options'],
                                    selectedOptions: _getSubmittedOptions(chat['messages'], index),
                                    correctOptionIndexes: isSubmitted ? chat['messages'][index]['content']['correct_options'] : [],
                                    isSubmitted: isSubmitted,
                                    onSubmit: (selectedOptions) async {
                                      await _onQuizAnswerSubmit(selectedOptions);
                                    },
                                    creationDate: DateTime.tryParse(chat['messages'][index]['creation_date'])!,
                                  )
                                  // Widget for open question
                                  : chat['messages'][index]['type'] == 'open_question'
                                  ? OpenQuestionChatWidget(
                                    question: chat['messages'][index]['content']['question'],
                                    initialAnswer: _getAnswerFromOpenQuestion(chat['messages'], index),
                                    isSubmitted: isSubmitted,
                                    onSubmit: (enteredAnswer) async {
                                      await _onOpenQuestionAnswerSubmit(enteredAnswer);
                                    },
                                    creationDate: DateTime.tryParse(chat['messages'][index]['creation_date'])!,
                                  )
                                  : SizedBox(height: 0)
                            );
                          }
                        ),
                      // "Generating answer..." widget
                      _isGenerating ? Column(
                        children: [
                          Text(
                              AppLocalizations.of(context)!.generating_answer,
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: StyleOptions.chatMessagesSpacing),
                        ],
                        // Retry button
                      ) : _generationFailed ? NeumorphicButton(
                        margin: EdgeInsets.only(bottom: StyleOptions.chatMessagesSpacing),
                        style: NeumorphicStyle(
                          depth: StyleOptions.neumorphicDepth,
                          intensity: StyleOptions.neumorphicIntensity,
                        ),
                        onPressed: () {
                          setState(() {
                            _generationFailed = false;
                          });
                          _generateAnswer();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppLocalizations.of(context)!.try_again),
                            SizedBox(width: 7),
                            Icon(
                                BootstrapIcons.arrow_clockwise
                            )
                          ],
                        ),
                      ) : Container()
                    ],
                  ),
                )
              ),
              MessageInputBar(
                  isDisabled: _lockMessageInputBar,
                onSubmit: (message, images) async {
                  await _onMessageSubmit(message, images);
                  _scrollToBottom();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================
// BOTTOM MESSAGE INPUT BAR
// ==================================

/// Bottom input bar for sending messages (text + images)
class MessageInputBar extends StatefulWidget {
  final isDisabled;
  Function(String, List<XFile>) onSubmit;

  MessageInputBar({
    super.key,
    this.isDisabled = false,
    required this.onSubmit
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  TextEditingController _controller = TextEditingController();
  // FocusNode _focusNode = FocusNode();
  List<XFile> _imageFiles = [];
  ImagePicker _picker = ImagePicker();

  // ==================================
  // IMAGE PICKING & REMOVAL
  // ==================================

  /// Picks multiple images from the device gallery
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

  /// Captures a single image using the device camera
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

  /// Removes selected image from the preview list by index
  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  // ==================================
  // BUILD METHOD
  // ==================================

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          if(_imageFiles.length > 0)
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
              height: 110,
              child: ListView.builder(
                  itemCount: _imageFiles.length,
                  shrinkWrap: true,
                  reverse: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: StyleOptions.imageSelectionBoxVerticalPadding * 2, horizontal: 0),
                      child: Stack(
                        alignment: Alignment.topRight,
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
                              top: 4,
                              right: 4 + StyleOptions.imagesMargin,
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
                      ),
                    );
                  }
              ),
                        ),
            )
        else
          Container(),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if(widget.isDisabled) {
                    return;
                  }

                  FocusScope.of(context).requestFocus(FocusNode());

                  showModalBottomSheet<void>(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(StyleOptions.elementRoundness)),
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: Column(
                          children: [
                            MaterialButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _pickImages();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(BootstrapIcons.image_fill),
                                  Text(AppLocalizations.of(context)!.select_image),
                                ],
                              ),
                            ),
                            MaterialButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _pickImageFromCamera();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(BootstrapIcons.camera_fill),
                                  Text(AppLocalizations.of(context)!.take_image),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }
                  );
                  // FocusScope.of(context).unfocus();
                },
                icon: Icon(
                    BootstrapIcons.image_fill,
                  color: NeumorphicTheme.defaultTextColor(context),
                ),
              ),
              Expanded(
                child: Neumorphic(
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                    depth: StyleOptions.neumorphicDepth * -1,
                    intensity: StyleOptions.neumorphicIntensity,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: StyleOptions.inputBoxHorizontalPadding, vertical: StyleOptions.inputBoxVerticalPadding),
                  child: TextField(
                    controller: _controller,
                    cursorColor: NeumorphicTheme.defaultTextColor(context),
                    decoration: InputDecoration.collapsed(
                      hintText: AppLocalizations.of(context)!.type_here,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if(widget.isDisabled) {
                    return;
                  }
                  widget.onSubmit(_controller.text, _imageFiles);
                  _controller.clear();
                  setState(() {
                    _imageFiles = [];
                  });
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                icon: Icon(
                    BootstrapIcons.send_fill,
                  color: NeumorphicTheme.defaultTextColor(context),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

// ==================================
// ELEMENTS FOR CHAT MESSAGES
// ==================================

/// Widget for agent text output
class AgentTextOutputElementWidget extends StatelessWidget {
  String text;
  DateTime creationDate;
  AgentTextOutputElementWidget({
    super.key,
    required this.text,
    required this.creationDate
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Neumorphic(
        style: NeumorphicStyle(
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
          depth: StyleOptions.neumorphicDepth,
          intensity: StyleOptions.neumorphicIntensity,
        ),
        padding: EdgeInsets.symmetric(vertical: StyleOptions.chatMessageVerticalPadding, horizontal: StyleOptions.chatMessageHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text),
            Text(
                DateFormat("HH:mm").format(creationDate),
              style: TextStyle(
                color: NeumorphicTheme.disabledColor(context)
              ),
            ),
          ]
        ),
      ),
    );
  }
}

/// Widget for user text + images input
class UserInputElementWidget extends StatelessWidget {
  String text;
  List<String> imagesFilePath;
  DateTime creationDate;

  UserInputElementWidget({
    super.key,
    required this.text,
    required this.imagesFilePath,
    required this.creationDate,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Neumorphic(
        style: NeumorphicStyle(
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
          depth: StyleOptions.neumorphicDepth,
          intensity: StyleOptions.neumorphicIntensity,
        ),
        padding: EdgeInsets.symmetric(vertical: StyleOptions.chatMessageVerticalPadding, horizontal: StyleOptions.chatMessageHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            text == "" ? Container()
                : Column(
                  children: [
                    Text(
                      text,
                      textAlign: TextAlign.end,
                    ),
                    SizedBox(height: StyleOptions.chatMessageElementsSpacing),
                  ],
                ),
            imagesFilePath.length > 0 ?
            SizedBox(
              height: 100,
              child: ListView.builder(
                reverse: true,
                itemCount: imagesFilePath.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) =>
                Neumorphic(
                  margin: EdgeInsets.only(right: StyleOptions.imagesMargin),
                  style: NeumorphicStyle(
                    depth: 0,
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                  ),
                  child: imagesFilePath[index].startsWith('assets') ?
                  Image.asset(
                      imagesFilePath[index],
                  ) :
                  Image.file(
                      File(imagesFilePath[index]),
                  )
                )
              ),
            )
            : Container(),
            SizedBox(height: StyleOptions.chatMessageElementsSpacing),
            Text(
                DateFormat("HH:mm").format(creationDate),
              style: TextStyle(
                color: NeumorphicTheme.disabledColor(context)
              )
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive single choice quiz widget
class SingleChoiceQuestionChatWidget extends StatefulWidget {
  String question;
  List options;
  int selectedOptionIndex;
  int correctOptionIndex;
  bool isSubmitted;
  ValueChanged<int> onSubmit;
  DateTime creationDate;

  SingleChoiceQuestionChatWidget({
    super.key,
    required this.question,
    required this.options,
    required this.selectedOptionIndex,
    required this.correctOptionIndex,
    required this.isSubmitted,
    required this.onSubmit,
    required this.creationDate
  });

  @override
  State<SingleChoiceQuestionChatWidget> createState() => _SingleChoiceQuestionChatWidgetState();
}

class _SingleChoiceQuestionChatWidgetState extends State<SingleChoiceQuestionChatWidget> {
  int _selectedOption = -1;

  @override
  void initState() {
    _selectedOption = widget.selectedOptionIndex;
    super.initState();
  }

  // ==================================
  // TILE STYLING LOGIC
  // ==================================

  /// Returns the background color of an option tile based on answer correctness after submission
  Color? _getTileColor(int index) {
    if(widget.isSubmitted) {
      if(index == widget.correctOptionIndex) {
        return Colors.green.shade500;
      }
      else if(index == _selectedOption) {
        return Colors.red.shade500;
      }
    }
    return NeumorphicTheme.baseColor(context);
  }

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
        depth: StyleOptions.neumorphicDepth,
        intensity: StyleOptions.neumorphicIntensity,
      ),
      padding: EdgeInsets.symmetric(vertical: StyleOptions.chatMessageVerticalPadding, horizontal: StyleOptions.chatMessageHorizontalPadding),
      child: Column(
        children: [
          Text(widget.question),
          SizedBox(height: StyleOptions.chatMessageElementsSpacing),
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.options.length,
              itemBuilder: (context, index) => Container(
                padding: EdgeInsets.only(bottom: StyleOptions.optionsSpacing, top: StyleOptions.optionsSpacing),
                child: NeumorphicRadio(
                  style: NeumorphicRadioStyle(
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                      selectedDepth: StyleOptions.neumorphicDepth * -1,
                      unselectedDepth: StyleOptions.neumorphicDepth,
                      selectedColor: _getTileColor(index),
                      unselectedColor: _getTileColor(index)
                  ),
                  groupValue: _selectedOption,
                  value: index,
                  onChanged: (value) {
                    if(widget.isSubmitted) {
                      return;
                    }
                    setState(() {
                      _selectedOption = index;
                    });
                  },
                  isEnabled: !widget.isSubmitted,
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: StyleOptions.optionVerticalPadding, horizontal: StyleOptions.optionHorizontalPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            _selectedOption == index ? BootstrapIcons.circle_fill : BootstrapIcons.circle,
                            color: _selectedOption == index ? NeumorphicTheme.accentColor(context) : NeumorphicTheme.disabledColor(context),
                            size: 18,
                          ),
                          SizedBox(width: StyleOptions.optionHorizontalPadding),
                          Expanded(
                            child: Text(
                              widget.options[index],
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      )
                  ),

                ),
              )
          ),
          !widget.isSubmitted ? SizedBox(height: StyleOptions.chatMessageElementsSpacing) : Container (),
          !widget.isSubmitted ? NeumorphicButton(
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
              depth: StyleOptions.neumorphicDepth,
              intensity: StyleOptions.neumorphicIntensity,
            ),
            onPressed: () {
              if(_selectedOption == -1) {
                return;
              }
              widget.onSubmit(_selectedOption);
            },
            child: Text(AppLocalizations.of(context)!.send),
          )
          : Container(),
          SizedBox(height: StyleOptions.chatMessageElementsSpacing),
          Container(
            width: double.infinity,
            child: Text(
              DateFormat("HH:mm").format(widget.creationDate),
              textAlign: TextAlign.start,
              style: TextStyle(
                color: NeumorphicTheme.disabledColor(context)
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive multi choice quiz widget
class MultiChoiceQuestionChatWidget extends StatefulWidget {
  String question;
  List options;
  List selectedOptions;
  List correctOptionIndexes;
  bool isSubmitted;
  ValueChanged<List> onSubmit;
  DateTime creationDate;

  MultiChoiceQuestionChatWidget({
    super.key,
    required this.question,
    required this.options,
    required this.selectedOptions,
    required this.correctOptionIndexes,
    required this.isSubmitted,
    required this.onSubmit,
    required this.creationDate
  });

  @override
  State<MultiChoiceQuestionChatWidget> createState() => _MultiChoiceQuestionChatWidgetState();
}

class _MultiChoiceQuestionChatWidgetState extends State<MultiChoiceQuestionChatWidget> {
  late List<bool> _selectedOptions;

  @override
  void didUpdateWidget(covariant MultiChoiceQuestionChatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options != widget.options ||
        oldWidget.isSubmitted != widget.isSubmitted ||
        oldWidget.selectedOptions != widget.selectedOptions) {
      setState(() {
        _initOptions();
      });
    }
  }

  // ==================================
  // SELECTION & STYLING LOGIC
  // ==================================

  /// Initializes selected options state list
  void _initOptions() {
    _selectedOptions = List<bool>.filled(widget.options.length, false);
    if(widget.isSubmitted) {
      for(int i = 0; i < widget.selectedOptions.length; i++) {
        _selectedOptions[widget.selectedOptions[i]] = true;
      }
    }
  }

  /// Returns list of indexes of currently selected options
  List _getSelectedOptions() {
    List selectedOptions = [];
    for(int i = 0; i < _selectedOptions.length; i++) {
      if(_selectedOptions[i]) {
        selectedOptions.add(i);
      }
    }
    return selectedOptions;
  }

  /// Returns tile color depending on submission state and option correctness
  Color? _getTileColor(int index) {
    if(widget.isSubmitted) {
      if(widget.correctOptionIndexes.contains(index)) {
        return Colors.green.shade500;
      }
      else if (_selectedOptions[index] == true) {
        return Colors.red.shade500;
      }
    }
    else {
      if (_selectedOptions[index] == true) {
        return NeumorphicTheme.accentColor(context);
      }
      else {
        return NeumorphicTheme.baseColor(context);
      }
    }
  }

  @override
  void initState() {
    _initOptions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
        depth: StyleOptions.neumorphicDepth,
        intensity: StyleOptions.neumorphicIntensity,
      ),
      padding: EdgeInsets.symmetric(vertical: StyleOptions.chatMessageVerticalPadding, horizontal: StyleOptions.chatMessageHorizontalPadding),
      child: Column(
        children: [
          Text(widget.question),
          SizedBox(height: StyleOptions.chatMessageElementsSpacing),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.options.length,
            itemBuilder: (context, index) => Container(
              padding: EdgeInsets.only(bottom: StyleOptions.optionsSpacing / 2, top: StyleOptions.optionsSpacing / 2),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: !widget.isSubmitted,
                onTap: () {
                  if (widget.isSubmitted) {
                    return;
                  }
                  setState(() {
                    _selectedOptions[index] = !_selectedOptions[index];
                  });
                },
                title: Neumorphic(
                    style: NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                      depth: widget.isSubmitted ? 0 : _selectedOptions[index] ? StyleOptions.neumorphicDepth * -1 : StyleOptions.neumorphicDepth,
                      intensity: StyleOptions.neumorphicIntensity,
                      color: _getTileColor(index),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: StyleOptions.optionVerticalPadding, horizontal: StyleOptions.optionHorizontalPadding),
                      child: Center(
                        child: Text(
                            widget.options[index],
                            style: TextStyle(
                                color: NeumorphicTheme.defaultTextColor(context)
                            ),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    )
                ),
              ),
            ),
          ),
          !widget.isSubmitted ? SizedBox(height: StyleOptions.chatMessageElementsSpacing) : Container (),
          !widget.isSubmitted ? NeumorphicButton(
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
              depth: StyleOptions.neumorphicDepth,
              intensity: StyleOptions.neumorphicIntensity,
            ),
            onPressed: () {
              widget.onSubmit(_getSelectedOptions());
            },
            child: Text(AppLocalizations.of(context)!.send),
          )
          : Container(),
          SizedBox(height: StyleOptions.chatMessageElementsSpacing),
          Container(
            width: double.infinity,
            child: Text(
              DateFormat("HH:mm").format(widget.creationDate),
              textAlign: TextAlign.start,
              style: TextStyle(
                color: NeumorphicTheme.disabledColor(context)
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Open question widget with answer input box
class OpenQuestionChatWidget extends StatefulWidget {
  final String question;
  final String initialAnswer;
  final bool isSubmitted;
  ValueChanged<String> onSubmit;
  DateTime creationDate;

  OpenQuestionChatWidget({
    super.key,
    required this.question,
    required this.initialAnswer,
    required this.isSubmitted,
    required this.onSubmit,
    required this.creationDate
  });

  @override
  State<OpenQuestionChatWidget> createState() => _OpenQuestionChatWidgetState();
}

class _OpenQuestionChatWidgetState extends State<OpenQuestionChatWidget> {
  late TextEditingController _controller;

  // ==================================
  // LIFECYCLE METHODS
  // ==================================

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAnswer);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ==================================
  // BUILD METHOD
  // ==================================

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
        depth: StyleOptions.neumorphicDepth,
        intensity: StyleOptions.neumorphicIntensity,
      ),
      padding: EdgeInsets.symmetric(vertical: StyleOptions.chatMessageVerticalPadding, horizontal: StyleOptions.chatMessageHorizontalPadding),
      child: Column(
        children: [
          Text(widget.question),
          SizedBox(height: StyleOptions.chatMessageElementsSpacing),
          Neumorphic(
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
              depth: StyleOptions.neumorphicDepth * -1,
              intensity: StyleOptions.neumorphicIntensity,
            ),
            padding: EdgeInsets.symmetric(horizontal: StyleOptions.inputBoxHorizontalPadding, vertical: StyleOptions.inputBoxVerticalPadding),
            child: TextField(
              controller: _controller,
              cursorColor: NeumorphicTheme.defaultTextColor(context),
              decoration: InputDecoration.collapsed(
                hintText: AppLocalizations.of(context)!.type_here,
              ),
              enabled: !widget.isSubmitted,
            ),
          ),
          !widget.isSubmitted ? SizedBox(height: StyleOptions.chatMessageElementsSpacing) : Container (),
          !widget.isSubmitted ? NeumorphicButton(
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
              depth: StyleOptions.neumorphicDepth,
              intensity: StyleOptions.neumorphicIntensity,
            ),
            onPressed: () {
              widget.onSubmit(_controller.text);
            },
            child: Text(AppLocalizations.of(context)!.send),
          )
          : Container(),
          SizedBox(height: StyleOptions.chatMessageElementsSpacing),
          Container(
            width: double.infinity,
            child: Text(
              DateFormat("HH:mm").format(widget.creationDate),
              textAlign: TextAlign.start,
              style: TextStyle(
                color: NeumorphicTheme.disabledColor(context)
              ),
            ),
          ),
        ],
      ),
    );
  }
}