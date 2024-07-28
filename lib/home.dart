import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:witness_deposition/transcription_history_screen.dart';

class SpeechTranslationScreen extends StatefulWidget {
  @override
  _SpeechTranslationScreenState createState() => _SpeechTranslationScreenState();
}

class _SpeechTranslationScreenState extends State<SpeechTranslationScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = 'Press the button to start speaking';
  String _translatedText = '';
  String _selectedLanguage = 'Hindi';

  final translator = GoogleTranslator();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, String> languageMap = {
    'English': 'en',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Chinese': 'zh',
    'Hindi': 'hi',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Marathi': 'mr',
    'Kannada': 'kn',
    'Malayalam': 'ml',
    'Gujarati': 'gu',
    'Punjabi': 'pa',
    'Bengali': 'bn',
    'Odia': 'or',
    'Assamese': 'as',
    'Urdu': 'ur'
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (error) => print('onError: $error'),
    );
    if (available) {
      setState(() {
        _isListening = true;
        _recognizedText = ''; // Clear previous text
      });
      _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
          _translateText(_recognizedText);
        },
        listenMode: stt.ListenMode.dictation,
      );
    } else {
      setState(() => _isListening = false);
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _saveTranscription() async {
    try {
      await _firestore.collection('transcriptions').add({
        'recognizedText': _recognizedText,
        'translatedText': _translatedText,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Transcription saved to Firestore');
    } catch (e) {
      print('Failed to save transcription: $e');
    }
  }

  void _translateText(String text) async {
    if (text.isEmpty) {
      setState(() {
        _translatedText = 'No text to translate';
      });
      return;
    }

    try {
      var translation = await translator.translate(text, to: languageMap[_selectedLanguage]!);
      setState(() {
        _translatedText = translation.text;
      });
      print('Translation: $translation');
      await _saveTranscription(); // Save transcription after translation
    } catch (e) {
      print('Translation error: $e');
      setState(() {
        _translatedText = 'Translation failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Witness Disposition Automation'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TranscriptionHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Choose Language",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                }
              },
              items: languageMap.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            _buildContainer('Recognized Speech', _recognizedText),
            SizedBox(height: 20),
            _buildContainer('Translated Result', _translatedText),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isListening ? _stopListening : _startListening,
        backgroundColor: Colors.deepPurple,
        tooltip: 'Listen',
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContainer(String title, String text) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Text(
                text,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
