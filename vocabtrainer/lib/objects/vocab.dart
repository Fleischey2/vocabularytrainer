class Vocab {
  String word;
  String translatedWord;

  Vocab({
    required this.word,
    required this.translatedWord
  });

  String get getWord {
    return word;
  }

  String get getTranslatedWord {
    return translatedWord;
  }

  Map<String, String> toJson() {
    return {
      'word': word,
      'translatedWord': translatedWord,
    };
  }

  factory Vocab.fromJson(Map<String, String> json) {
    return Vocab(
      word: json.values.first,
      translatedWord: json.values.last,
    );
  }
}

class Lecture {
  List<Vocab> lectureName;

  Lecture({
    required this.lectureName
  });

  List<Vocab> get lecture {
    return lectureName;
  }

  void set updateLecture(List<Vocab> newLecture) {
    lectureName = newLecture;
  }

}