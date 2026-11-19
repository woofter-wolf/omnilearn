import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppDatabase {
  /// Indicates if app went through first configuration
  bool appConfigured = false;
  /// Selected language code (returns null for system default language)
  String? lang;
  /// Selected accent color
  Color accentColor = Color(0xFF000000);
  /// Text color which is on accent color
  Color textOnAccentColor = Color(0xFFFFFFFF);
  /// Saved student name
  String studentName = "";
  /// Saved student school type
  String studentSchool = "";
  /// Saved student class
  String studentClass = "";

  /// Scheme of all saved flashcards
  ///
  /// Structure:
  /// - `set_name`: name of the set of flashcards
  /// - `flashcards`: list of flashcards in set:
  ///   - `question`: question on the flashcard
  ///   - `answer`: answer on the flashcard
  ///   - `status`: status of the flashcard (0 for unknown flashcard, 1 for flashcard with easy question, 2 for flashcard with difficult question)
  List flashcards = [
    {
      'set_name': '',
      'flashcards': [
        {
          'question': '',
          'answer': '',
          'status': 0
        }
      ]
    }
  ];

  /// Scheme of all saved quizzes
  ///
  /// Structure:
  /// - `quiz_name`: name of the quiz
  /// - `questions`: list of questions:
  ///   - `question`: quiz question
  ///   - `options`: list of available options
  ///   - `correct_options`: list of correct options (if list length is 1 then it's a single choice question and if it's more than 1 then it's a multi choice question)
  ///   - `explanation`: question explanation
  /// - `score_percentage`: quiz score in percent (-1 if quiz has not been solved yet)
  List quizzes = [
    {
      'quiz_name': '',
      'questions': [
        {
          'question': '',
          'options': ['', '', '', ''],
          'correct_options': [],
          'explanation': ''
        }
      ],
      'score_percentage': -1
    }
  ];

  /// Scheme of all saved chat messages in Task Scanner module
  ///
  /// Structure:
  /// - `last_message_date_time`: date and time of the last message
  /// - `messages`: list of messages in chat:
  ///   - `role`: role of the message sender (user or agent)
  ///   - `creation_date`: message creation date and time
  ///   - `type`: message type (initial_images - images sent at the beginning of chat; quiz_question - quiz (single choice or multi choice); quiz_answer - quiz answer selected and submitted by user; open_question - open question; open_answer - open answer entered by submitted by user; message - standard message)
  ///   - `content`: message content (depending on message type):
  ///     - for initial_images:
  ///       - `type`: message type (here it's always image)
  ///       - `image_url`: image url (the path of placeholder images or the local path of the image)
  ///     - for quiz_question:
  ///       - `question`: quiz question
  ///       - `options`: list of available options
  ///       - `correct_options`: list of correct options (if list length is 1 then it's a single choice question and if it's more than 1 then it's a multi choice question)
  ///     - for quiz_answer:
  ///       - `selected_options`: list of selected options by user (if list length is 1 then it's a single choice question and if it's more than 1 then it's a multi choice question)
  ///     - for open_question:
  ///       - `question`: open question
  ///     - for open_answer:
  ///       - `entered_answer`: open answer entered by user
  ///     - for message (list):
  ///       - `type`: message type (text or image; for agent it's always text)
  ///       - `text`: message text (if type is text)
  ///       - `image_url`: image url (if type is image; the path of placeholder images or the local path of the image)
  List taskScannerChatHistory = [
    {
      'last_message_date_time': '',
      'messages': [
        {
          'role': 'user',
          'creation_date': '',
          'type': 'initial_images',
          'content': [
            {
              'type': 'image',
              'image_url': []
            }
          ]
        },
        {
          'role': 'agent',
          'creation_date': '',
          'type': 'quiz_question',
          'content': {
            'question': '',
            'options': ['', '', '', ''],
            'correct_options': [],
          }
        },
        {
          'role': 'user',
          'creation_date': '',
          'type': 'quiz_answer',
          'content': {
            'selected_options': [],
          }
        },
        {
          'role': 'agent',
          'creation_date': '',
          'type': 'open_question',
          'content': {
            'question': '',
          }
        },
        {
          'role': 'user',
          'creation_date': '',
          'type': 'open_answer',
          'content': {
            'entered_answer': '',
          }
        },
        {
          'role': 'agent',
          'creation_date': '',
          'type': 'message',
          'content': [
            {
              'type': 'text',
              'text': ''
            }
          ]
        },
        {
          'role': 'user',
          'creation_date': '',
          'type': 'message',
          'content': [
            {
              'type': 'image',
              'image_url': []
            },
            {
              'type': 'image',
              'image_url': []
            },
            {
              'type': 'text',
              'text': ''
            }
          ]
        }
      ]
    }
  ];

  /// API key for AI provider
  String aiAPIKey = "";
  /// Model name for AI provider
  String aiModelName = "";

  var _appDb = Hive.box("app_db");

  /// Load all data from Hive database
  void load() {
    appConfigured = _appDb.get("app_configured");
    lang = _appDb.get("lang");
    accentColor = Color(_appDb.get("accent_color"));
    textOnAccentColor = Color(_appDb.get("text_on_accent_color"));
    studentName = _appDb.get("student_name");
    studentSchool = _appDb.get("student_school");
    studentClass = _appDb.get("student_class");
    flashcards = _appDb.get("flashcards");
    quizzes = _appDb.get("quizzes");
    taskScannerChatHistory = _appDb.get("task_scanner_chat_history");
    aiAPIKey = _appDb.get("ai_api_key");
    aiModelName = _appDb.get("ai_model_name");
  }

  /// Save all data to Hive database
  void save(){
    _appDb.put("db_created", true);
    _appDb.put("app_configured", appConfigured);
    _appDb.put("lang", lang);
    _appDb.put("accent_color", accentColor.value);
    _appDb.put("text_on_accent_color", textOnAccentColor.value);
    _appDb.put("student_name", studentName);
    _appDb.put("student_school", studentSchool);
    _appDb.put("student_class", studentClass);
    _appDb.put("flashcards", flashcards);
    _appDb.put("quizzes", quizzes);
    _appDb.put("task_scanner_chat_history", taskScannerChatHistory);
    _appDb.put("ai_api_key", aiAPIKey);
    _appDb.put("ai_model_name", aiModelName);
  }

  /// Create initial database with default values
  void createInitialDatabase() {
    appConfigured = false;
    lang = null;
    accentColor = Color(0xFF0066FF);
    textOnAccentColor = Color(0xFFFFFFFF);
    studentName = "Student";
    studentSchool = "primary";
    studentClass = "1";

    // Create example flashcards set in Debug mode
    if(kReleaseMode) {
      flashcards = [];
    }
    else {
      flashcards = [
        {
          'set_name': 'Example Set',
          'flashcards': [
            {
              'question': 'Example mastered question',
              'answer': 'Example mastered answer',
              'status': 1
            },
            {
              'question': 'Example question',
              'answer': 'Example answer',
              'status': 0
            },
            {
              'question': 'Example question 1',
              'answer': 'Example answer 1',
              'status': 0
            },
            {
              'question': 'Example question 2',
              'answer': 'Example answer 2',
              'status': 0
            },
            {
              'question': 'Example difficult question',
              'answer': 'Example difficult answer',
              'status': 2
            },
            {
              'question': 'Example mastered question 1',
              'answer': 'Example mastered answer 1',
              'status': 1
            },
            {
              'question': 'Example mastered question 2',
              'answer': 'Example mastered answer 2',
              'status': 1
            },
            {
              'question': 'Example difficult question 1',
              'answer': 'Example difficult answer 1',
              'status': 2
            },
            {
              'question': 'Example difficult question 2',
              'answer': 'Example difficult answer 2',
              'status': 2
            }
          ]
        }
      ];
    }

    // Create example quizz in Debug mode
    if(kReleaseMode) {
      quizzes = [];
    }
    else {
      quizzes = [
        {
          'quiz_name': 'Example quiz',
          'questions': [
            {
              'question': 'Example single choice question',
              'options': ['A answer', 'B answer', 'C answer', 'D answer'],
              'correct_options': [2],
              'explanation': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus vitae leo eu felis iaculis suscipit. Vestibulum tincidunt tellus eget ante iaculis, non posuere tellus viverra. Quisque accumsan viverra scelerisque. Suspendisse eu risus in mi mollis venenatis ac et felis. Pellentesque sed dui ut orci finibus vulputate vitae facilisis mauris. Nulla.'
            },
            {
              'question': 'Example multi choice question',
              'options': ['A answer', 'B answer', 'C answer', 'D answer'],
              'correct_options': [1, 3],
              'explanation': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus vitae leo eu felis iaculis suscipit. Vestibulum tincidunt tellus eget ante iaculis, non posuere tellus viverra. Quisque accumsan viverra scelerisque. Suspendisse eu risus in mi mollis venenatis ac et felis. Pellentesque sed dui ut orci finibus vulputate vitae facilisis mauris. Nulla.'
            }
          ],
          'score_percentage': -1
        }
      ];
    }

    // Create example chat history in Debug mode
    if(kReleaseMode) {
      taskScannerChatHistory = [];
    }
    else {
      taskScannerChatHistory = [
        {
          'last_message_date_time': '2026-10-23 14:23:15',
          'messages': [
            {
              'role': 'user',
              'creation_date': '2026-10-23 14:23:17',
              'type': 'initial_images',
              'content': [
                {
                  'type': 'image',
                  'image_url': 'assets/placeholder_images/image0.jpg'
                },
                {
                  'type': 'image',
                  'image_url': 'assets/placeholder_images/image1.jpg'
                }
              ]
            },
            {
              'role': 'agent',
              'creation_date': '2026-10-23 14:24:25',
              'type': 'quiz_question',
              'content': {
                'question': 'Example single choice question',
                'options': ['Option A', 'Option B', 'Option C', 'Option D'],
                'correct_options': [2],
              }
            },
            {
              'role': 'user',
              'creation_date': '2026-10-23 14:26:17',
              'type': 'quiz_answer',
              'content': {
                'selected_options': [3],
              }
            },
            {
              'role': 'agent',
              'creation_date': '2026-10-23 14:28:10',
              'type': 'quiz_question',
              'content': {
                'question': 'Example multi choice question',
                'options': ['Option A', 'Option B', 'Option C', 'Option D'],
                'correct_options': [1, 3],
              }
            },
            {
              'role': 'user',
              'creation_date': '2026-10-23 14:30:07',
              'type': 'quiz_answer',
              'content': {
                'selected_options': [0, 1],
              }
            },
            {
              'role': 'agent',
              'creation_date': '2026-10-23 14:34:47',
              'type': 'open_question',
              'content': {
                'question': 'Example open question',
              }
            },
            {
              'role': 'user',
              'creation_date': '2026-10-23 14:35:26',
              'type': 'open_answer',
              'content': {
                'entered_answer': 'Example entered answer',
              }
            },
            {
              'role': 'agent',
              'creation_date': '2026-10-23 14:36:55',
              'type': 'message',
              'content': [
                {
                  'type': 'text',
                  'text': 'Example text written by agent'
                }
              ]
            },
            {
              'role': 'user',
              'creation_date': '2026-10-23 14:37:24',
              'type': 'message',
              'content': [
                {
                  'type': 'image',
                  'image_url': 'assets/placeholder_images/image2.jpg'
                },
                {
                  'type': 'image',
                  'image_url': 'assets/placeholder_images/image3.jpg'
                },
                {
                  'type': 'text',
                  'text': 'Example text written by user'
                }
              ]
            }
          ]
        }
      ];
    }
    aiAPIKey = "";
    aiModelName = "";
    save();
  }

  /// Return if database is created
  bool isCreated() {
    return _appDb.get("db_created") != null;
  }
}