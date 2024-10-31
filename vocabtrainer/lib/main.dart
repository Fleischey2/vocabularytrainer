import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabtrainer/objects/vocab.dart';
import 'package:vocabtrainer/viewmodels/vocabViewModel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocabulary Trainer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.transparent),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int streak = 0;
  Vocabviewmodel vocabviewmodel = Vocabviewmodel();
  int selectedIndex = 0;
  List<Lecture> allLectures = [];
  Lecture loadedWordList = Lecture(lectureName: []);
  String toTranslateWord = '';
  String translatedWord = '';
  String translateTheWordText = '';
  TextEditingController wordController = TextEditingController();
  TextEditingController translationController = TextEditingController();
  TextEditingController testController = TextEditingController();

  bool isCorrect = true;
  bool showGlow = false;

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
  }

  void _selectLecture(int clickedLecture) {
    testController.clear();
    setState(() {
    selectedIndex = clickedLecture;
    loadedWordList = allLectures[clickedLecture];
    
    if (loadedWordList.lecture.isNotEmpty) {
      _getRandomWord();
    } else {
      _clearWordFields();
    }
    
    });
  }

  Future<void> _addNewLecture() async {
    await vocabviewmodel.addLecture();
    await _loadVocabulary();
  }

  Future<void> _deleteLecture() async {
    if (allLectures.length > 1) {
      await vocabviewmodel.deleteLecture(selectedIndex);
      selectedIndex = 0;
      await _loadVocabulary();
    }
  }

  Future<void> _deleteWord(int wordIndex) async {
    await vocabviewmodel.deleteVocabFromLecture(selectedIndex, wordIndex);
    await _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    allLectures = await vocabviewmodel.readVocab();
    
    if (allLectures.isEmpty) {
      await vocabviewmodel.addLecture();
      allLectures = await vocabviewmodel.readVocab();
    }

    loadedWordList = allLectures[selectedIndex];
    
    if (loadedWordList.lecture.isNotEmpty) {
      _getRandomWord();
    } else {
      _clearWordFields();
    }

    translateTheWordText = toTranslateWord.isEmpty ? 'Add some words!' : 'Translate the following word: ';
    setState(() {});
  }

  void _getRandomWord() {
  if (loadedWordList.lecture.isNotEmpty) {
    final randomIndex = Random().nextInt(loadedWordList.lecture.length);
    final randomVocab = loadedWordList.lecture[randomIndex];

    final showOriginalWord = Random().nextBool();

    setState(() {
      if (showOriginalWord) {
        toTranslateWord = randomVocab.getWord;
        translatedWord = randomVocab.getTranslatedWord;
        translateTheWordText = 'Translate the following word: ';
      } else {
        toTranslateWord = randomVocab.getTranslatedWord;
        translatedWord = randomVocab.getWord;
        translateTheWordText = 'Translate the following word: ';
      }
    });
  } else {
    _clearWordFields();
  }
}


  void _clearWordFields() {
  setState(() {
    toTranslateWord = '';
    translatedWord = '';
    translateTheWordText = 'Add some words!';
  });
}

  Future<void> _addNewWord() async {
  if (wordController.text.isNotEmpty && translationController.text.isNotEmpty) {
    Vocab newVocab = Vocab(
        word: wordController.text,
        translatedWord: translationController.text);
    loadedWordList.lecture.add(newVocab);
    allLectures[selectedIndex] = loadedWordList;
    wordController.clear();
    translationController.clear();
    await vocabviewmodel.writeVocab(allLectures);
    
    _getRandomWord();
    setState(() {});
  }
}

void _counter() {
    setState(() {
      if (testController.text == translatedWord) {
        streak += 1;
        isCorrect = true;
      } else {
        streak = 0;
        isCorrect = false;
      }
      testController.clear();
      showGlow = true;
    });

    Timer(const Duration(seconds: 1), () {
      setState(() {
        showGlow = false;
      });
    });

    _getRandomWord();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Center(
        child: Text(
          "VocabTrainer",
          style: GoogleFonts.aBeeZee(
            fontSize: 32,
          ),
        ),
      )),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: showGlow
                      ? (isCorrect ? Colors.green : Colors.red).withOpacity(0.8)
                      : Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
              ),
                child: Column(
                  children: [
                    Text(
                          'Streak: $streak',
                          style: GoogleFonts.aBeeZee(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                    Center(
                      child: Wrap(
                        children: [
                          Text(translateTheWordText,
                              style: GoogleFonts.aBeeZee(
                                fontSize: 16,
                              )),
                          Text(
                            toTranslateWord,
                            style: GoogleFonts.aBeeZee(
                                fontSize: 18, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    TextField(
                      textAlign: TextAlign.center,
                      controller: testController,
                    ),
                    IconButton(
                        onPressed: _counter,
                        icon: Icon(
                          Icons.check,
                          size: 32,
                        ))
                  ],
                )),
            Padding(padding: EdgeInsets.all(16)),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      itemCount: allLectures.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          child: Container(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedIndex == index ? Theme.of(context).colorScheme.inversePrimary : Theme.of(context).colorScheme.primary,
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                            'Lecture ${index + 1}',
                            style: GoogleFonts.aBeeZee(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          )
                        ),
                        onTap: () => _selectLecture(index),
                        );
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addNewLecture,
                  icon: Icon(Icons.add),
                ),
                IconButton(
                  onPressed: _deleteLecture,
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.all(8)),
            Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0)),
                        
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text('First',
                              style: GoogleFonts.aBeeZee(fontSize: 16)),
                        ),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                        SizedBox(
                          width: 80,
                          child: Text('Second',
                              style: GoogleFonts.aBeeZee(fontSize: 16)),
                        ),
                      ],
                    ),
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: loadedWordList.lecture.length,
                      itemBuilder: (context, index) {
                        return Container(
                            margin: EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 80,
                                    child: Text(
                                      loadedWordList.lecture[index].getWord,
                                      style: GoogleFonts.aBeeZee(fontSize: 16),
                                    )),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4)),
                                SizedBox(
                                    width: 120,
                                    child: Text(
                                      loadedWordList
                                          .lecture[index].getTranslatedWord,
                                      style: GoogleFonts.aBeeZee(fontSize: 16),
                                    )),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8)),
                                IconButton(
                                    onPressed: () => _deleteWord(index),
                                    icon: Icon(Icons.delete))
                              ],
                            ));
                      },
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: wordController,
                                  decoration: InputDecoration(
                                      hintText: 'Word',
                                      hintStyle:
                                          GoogleFonts.aBeeZee(fontSize: 16)),
                                  style: GoogleFonts.aBeeZee(fontSize: 16),
                                )),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4)),
                            SizedBox(
                                width: 120,
                                child: TextField(
                                  controller: translationController,
                                  decoration: InputDecoration(
                                      hintText: 'Translation',
                                      hintStyle:
                                          GoogleFonts.aBeeZee(fontSize: 16)),
                                  style: GoogleFonts.aBeeZee(fontSize: 16),
                                )),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8)),
                            IconButton(
                                onPressed: _addNewWord, icon: Icon(Icons.save))
                          ],
                        ))
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
