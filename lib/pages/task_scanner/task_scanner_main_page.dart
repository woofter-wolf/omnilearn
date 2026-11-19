import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:omnilearn/elements/dialog_boxes.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/data/database.dart';
import 'package:omnilearn/pages/task_scanner/task_scanner_new_chat_page.dart';
import 'package:omnilearn/pages/task_scanner/task_scanner_chat_page.dart';
import 'package:omnilearn/style/style_options.dart';

// ==================================
// TASK SCANNER CHAT HISTORY LIST PAGE
// ==================================

/// Main page displaying list of previous Task Scanner chat sessions and creating new sessions
class TaskScannerMainPage extends StatefulWidget {
  TaskScannerMainPage({super.key});

  @override
  State<TaskScannerMainPage> createState() => _TaskScannerMainPageState();
}

class _TaskScannerMainPageState extends State<TaskScannerMainPage> {
  final _appDb = AppDatabase();

  void _navigateToChatPage(int index) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskScannerChatPage(chatIndex: index)));

    if(mounted) {
      setState(() {
        _appDb.load();
      });
    }
  }

  void _navigateToAddChatPage() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskScannerNewChatPage()));

    if(mounted) {
      setState(() {
        _appDb.load();
      });
    }
  }

  void _showChatRemovalConfirmation(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return ConfirmationDialogBox(
              title: AppLocalizations.of(context)!.remove_chat,
              message: AppLocalizations.of(context)!.chat_removal_confirmation,
              onYes: () {
                _removeChat(index);
                Navigator.of(context).pop();
              },
              onNo: () {
                Navigator.of(context).pop();
              }
          );
        }
    );
  }

  void _removeChat(int index) {
    setState(() {
      _appDb.taskScannerChatHistory.removeAt(index);
      _appDb.save();
    });
  }

  @override
  void initState() {
    _appDb.load();
    super.initState();
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
          _navigateToAddChatPage();
        },
        child: Icon(
          BootstrapIcons.plus_lg,
          color: NeumorphicTheme.defaultTextColor(context),
        )
      ),
      body: _appDb.taskScannerChatHistory.length == 0 ?
      Center(
        child: Text(AppLocalizations.of(context)!.no_chats),
      )
      : ListView.builder(
        itemCount: _appDb.taskScannerChatHistory.length,
          itemBuilder: (context, index) {
            var dateTime = DateTime.tryParse(_appDb.taskScannerChatHistory[index]['last_message_date_time'])!;
            return ListTile(
                title: NeumorphicButton(
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(StyleOptions.elementRoundness)),
                    depth: StyleOptions.neumorphicDepth,
                    intensity: StyleOptions.neumorphicIntensity
                  ),
                  onPressed: () {
                    _navigateToChatPage(index);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: StyleOptions.listTileVerticalPadding, horizontal: StyleOptions.listTileHorizontalPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            DateFormat('dd/MM/yyyy     HH:mm').format(dateTime),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showChatRemovalConfirmation(index);
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
                    ),
                  ),
                )
            );
          }
      ),
    );
  }
}