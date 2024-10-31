import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocabtrainer/objects/vocab.dart';

class Vocabviewmodel extends ChangeNotifier {
  List<Lecture> currentLectures = [Lecture(lectureName: List.empty(growable: true))];

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/vocabList.txt');
  }

  Future<File> writeVocab(List<Lecture> vocabs) async {
    final file = await _localFile;
    List<List<Map<String, String>>> jsonList = vocabs.map((lecture) {
      return lecture.lecture.map((vocab) => vocab.toJson()).toList();
    }).toList();
    
    return file.writeAsString(jsonEncode(jsonList));
  }

  Future<List<Lecture>> readVocab() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      List<dynamic> jsonList = jsonDecode(contents);
      currentLectures = jsonList.map((lectureData) {
        List<Vocab> vocabList = (lectureData as List).map((vocabData) {
          return Vocab(
            word: vocabData['word'],
            translatedWord: vocabData['translatedWord'],
          );
        }).toList();
        return Lecture(lectureName: vocabList);
      }).toList();
      
      notifyListeners();
      return currentLectures;
    } catch (e) {
      print("Reading not possible because ${e.toString()}");
      return List.empty();
    }
  }

  Future<void> addLecture() async {
    currentLectures.add(Lecture(lectureName: List.empty(growable: true)));
    await writeVocab(currentLectures);
    notifyListeners();
  }

  Future<void> deleteLecture(int index) async {
    if (index >= 0 && index < currentLectures.length) {
      currentLectures.removeAt(index);
      await writeVocab(currentLectures);
      notifyListeners();
    }
  }

  Future<void> addVocabToLecture(int lectureIndex, Vocab vocab) async {
    if (lectureIndex >= 0 && lectureIndex < currentLectures.length) {
      currentLectures[lectureIndex].lecture.add(vocab);
      await writeVocab(currentLectures);
      notifyListeners();
    }
  }

  Future<void> deleteVocabFromLecture(int lectureIndex, int vocabIndex) async {
    if (lectureIndex >= 0 && lectureIndex < currentLectures.length) {
      if (vocabIndex >= 0 && vocabIndex < currentLectures[lectureIndex].lecture.length) {
        currentLectures[lectureIndex].lecture.removeAt(vocabIndex);
        await writeVocab(currentLectures);
        notifyListeners();
      }
    }
  }
}
