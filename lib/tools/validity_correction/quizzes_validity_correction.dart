import 'package:omnilearn/data/database.dart';

class QuizzesValidityCorrection {
  final _appDb = AppDatabase();

  QuizzesValidityCorrection() {
    _appDb.load();
  }

  /// Check quizzes and remove incorrect ones
  void check() {
    // Loop through all quizzes
    for(int i = 0; i < _appDb.quizzes.length; i++) {
      // Leave the loop if index is out of range
      if(i >= _appDb.quizzes.length) {
        break;
      }

      // Remove quiz if its structure is incorrect
      if(!_checkQuiz(_appDb.quizzes[i])) {
        _appDb.quizzes.removeAt(i);
        i--;
      }
      else {
        // Loop through all questions in quiz
        for(int j = 0; j < _appDb.quizzes[i]['questions'].length; j++) {
          // Leave the loop if index is out of range
          if(j >= _appDb.quizzes[i]['questions'].length) {
            break;
          }
          // Remove question if its structure is incorrect
          if(!_checkQuestion(_appDb.quizzes[i]['questions'][j])) {
            _appDb.quizzes[i]['questions'].removeAt(j);
            j--;
            // Remove quiz if there are no questions left
            if(_appDb.quizzes[i]['questions'].length == 0) {
              _appDb.quizzes.removeAt(i);
              i--;
              break;
            }
          }
        }
      }
    }

    // Correct score_percentage for all remaining quizzes
    for(int i = 0; i < _appDb.quizzes.length; i++) {
      _correctScorePercentageValue(i);
    }

    _appDb.save();
  }

  /// Returns if quiz structure is correct
  bool _checkQuiz(Map quiz) {
    // Check if quiz has name and questions list
    if(quiz.containsKey('quiz_name') && quiz.containsKey('questions')) {
      // Check if name and questions list are not empty
      if(quiz['quiz_name'] != null && quiz['questions'] != null && quiz['quiz_name'] != "" && quiz['questions'].length > 0) {
        return true;
      }
      else {
        return false;
      }
    }
    else {
      return false;
    }
  }

  /// Returns if question structure is correct
  bool _checkQuestion(Map question) {
    // Check if question has question, options, correct_options and explanation
    if(question.containsKey('question') && question.containsKey('options') && question.containsKey('correct_options') && question.containsKey('explanation')) {
      // Check if question, options, correct_options and explanation are not empty
      if(question['question'] != null && question['options'] != null && question['correct_options'] != null && question['explanation'] != null && question['question'] != "" && question['options'].length > 0 && question['correct_options'].length > 0 && question['explanation'] != "") {
        return true;
      }
      else {
        return false;
      }
    }
    else {
      return false;
    }
  }

  /// Correct quiz score in percentage (if score_percentage is not in range 0-100 or it's not -1 then it's set to -1)
  void _correctScorePercentageValue(int quizIndex) {
    if((_appDb.quizzes[quizIndex]['score_percentage'] < 0 && _appDb.quizzes[quizIndex]['score_percentage'] != -1) || _appDb.quizzes[quizIndex]['score_percentage'] > 100) {
      _appDb.quizzes[quizIndex]['score_percentage'] = -1;
    }
  }
}