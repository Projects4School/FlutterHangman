import 'package:app_pendu/utils.dart';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hangman',
      theme: ThemeData(
        colorScheme: const ColorScheme.highContrastLight(primary: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Hangman'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _wordToFind = "";
  final String _alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  String _failedLetters = "";
  String _validLetters = "";
  String _word = "";
  int _state = 1;
  int _score = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    initWord();
    _loadScore();
  }

  Future<void> _loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _score = (prefs.getInt('score') ?? 0);
    });
  }

  Future<void> _incrementScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _score = (prefs.getInt('score') ?? 0) + (8 - _state);
      prefs.setInt('score', _score);
    });
  }

  void checkLetter(String letter) {
    if(_wordToFind.contains(letter)) {
      int idx = 0;
      _wordToFind.split("").forEach((l) {
        if(letter == l) {
          setState(() {
            _validLetters += l;
            _word = replaceAt(_word, l, idx);
          });
        }
        idx++;
      });
    } else {
      setState(() {
        _state++;
        _failedLetters += letter;
      });
    }
  }

  int checkUsedLetter(String letter) {
    int res = 0;
    if(_validLetters.contains(letter)) {
      res = 1;
    } else if(_failedLetters.contains(letter)) {
      res = 2;
    }
    return res;
  }

  void restart() {
    Navigator.popAndPushNamed(context, "/");
  }

  void initWord() {
    setState(() {
      _wordToFind = faker.address.country().toUpperCase();
      _word = "";
      _word += _wordToFind[0];
      for (var i = 0; i < _wordToFind.length-2; i++) {
        _word += "_";
      }
      _word += _wordToFind[_wordToFind.length-1];
    });
  }

  bool isWin() {
    bool winned = _word == _wordToFind;
    winned &= _state < 7;
    return winned;
  }

  @override
  Widget build(BuildContext context) {
    if(_wordToFind.isEmpty) initWord();
    
    if(isWin() && !_finished) {
      _finished = true;
      _incrementScore();
    }

    List<Widget> mywidgets = [];
    _alphabet.split("").forEach((letter) {
      mywidgets.add(
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: checkUsedLetter(letter) > 0 
              ? checkUsedLetter(letter) == 1 
              ? Colors.greenAccent
              : Colors.redAccent
              : Colors.blueAccent
            ),
            onPressed: /*checkUsedLetter(letter) > 0 ? null :*/ () {
              if(checkUsedLetter(letter) == 0) {
                checkLetter(letter);
              }
              /*setState(() {
                _state++;
              });*/
            },
            child: Text(letter),
          ),
        )
      );
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "Score: $_score",
                style: const TextStyle(
                  fontSize: 20
                ),
              ),
            ),
            Image(
              image: AssetImage('assets/hangman$_state.png'),
            ),
            Text(
              _word,
              style: const TextStyle(
                letterSpacing: 10,
                fontSize: 32,
                fontWeight: FontWeight.bold
              ),
            ),
            Container(
              child: isWin() 
                ? Text("WINNED\n+${8 - _state}")
                : _state < 7 
                ? Wrap(
                  children: mywidgets
                ) 
                : Text(
                  "FAILED...\nWord is \"$_wordToFind\"",
                ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent
              ),
              onPressed: () => restart(),
              child: const Text("Restart")
            ),
            const Padding(padding: EdgeInsets.all(20))
          ],
        ),
      ),
    );
  }
}
