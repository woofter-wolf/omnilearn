import 'package:omnilearn/data/database.dart';

class FlashcardsValidityCorrection {
  final _appDb = AppDatabase();

  FlashcardsValidityCorrection() {
    _appDb.load();
  }

  /// Check flashcards sets and remove incorrect ones
  void check() {
    // Loop through all flashcard sets
    for(int i = 0; i < _appDb.flashcards.length; i++) {
      // Leave the loop if index is out of range
      if(i >= _appDb.flashcards.length) {
        break;
      }
      // Remove flashcard set if its structure is incorrect
      if(!_checkFlashcardSet(_appDb.flashcards[i])) {
        _appDb.flashcards.removeAt(i);
        i--;
      }
      else {
        // Loop through all flashcards in flashcard set
        for(int j = 0; j < _appDb.flashcards[i]['flashcards'].length; j++) {
          // Leave the loop if index is out of range
          if(j >= _appDb.flashcards[i]['flashcards'].length) {
            break;
          }
          // Remove flashcard if its structure is incorrect
          if(!_checkFlashcard(_appDb.flashcards[i]['flashcards'][j])) {
            _appDb.flashcards[i]['flashcards'].removeAt(j);
            j--;
            // Remove flashcard set if there are no flashcards left
            if(_appDb.flashcards[i]['flashcards'].length == 0) {
              _appDb.flashcards.removeAt(i);
              i--;
              break;
            }
          }
        }
      }
    }

    // Correct status for all remaining flashcards
    for(int i = 0; i < _appDb.flashcards.length; i++) {
      for(int j = 0; j < _appDb.flashcards[i]['flashcards'].length; j++) {
        _correctFlashcardStatus(i, j);
      }
    }

    _appDb.save();
  }

  /// Returns if flashcard set structure is correct
  bool _checkFlashcardSet(Map flashcardsSet) {
    // Check if flashcard set has name and flashcards list
    if(flashcardsSet.containsKey('set_name') && flashcardsSet.containsKey('flashcards')) {
      // Check if name and flashcards list are not empty
      if(flashcardsSet['set_name'] != null && flashcardsSet['flashcards'] != null && flashcardsSet['set_name'] != "" && flashcardsSet['flashcards'].length > 0) {
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

  /// Returns if flashcard structure is correct
  bool _checkFlashcard(Map flashcard) {
    // Check if flashcard has question and answer
    if(flashcard.containsKey('question') && flashcard.containsKey('answer')) {
      // Check if question and answer are not empty
      if(flashcard['question'] != null && flashcard['answer'] != null && flashcard['question'] != "" && flashcard['answer'] != "") {
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

  /// Correct flashcards status (if status is not in range 0-2 then it's set to 0)
  void _correctFlashcardStatus(int setIndex, int flashcardIndex) {
    if(_appDb.flashcards[setIndex]['flashcards'][flashcardIndex]['status'] < 0 || _appDb.flashcards[setIndex]['flashcards'][flashcardIndex]['status'] > 2) {
      _appDb.flashcards[setIndex]['flashcards'][flashcardIndex]['status'] = 0;
    }
  }
}

