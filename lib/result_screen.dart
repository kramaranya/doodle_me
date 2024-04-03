import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResultScreen extends StatefulWidget {
  final List<String>? top5ClassesAndScores;

  ResultScreen({Key? key, required this.top5ClassesAndScores})
      : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    flutterTts.setSpeechRate(0.3);
  }

  Future<Map<String, String>> loadLocalizedClassNames(
      BuildContext context) async {
    Locale locale = Localizations.localeOf(context);
    String fileName = 'assets/class_names_${locale.languageCode}.json';
    String jsonString =
        await DefaultAssetBundle.of(context).loadString(fileName);
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    return jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.top5ClassesAndScores == null ||
        widget.top5ClassesAndScores!.isEmpty) {
      return Scaffold(
        body: Center(child: Text("No predictions available")),
      );
    }

    return Scaffold(
      body: FutureBuilder<Map<String, String>>(
        future: loadLocalizedClassNames(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Error loading localized names'));
          }
          Map<String, String> localizedNames = snapshot.data!;

          return PageView.builder(
            itemCount: widget.top5ClassesAndScores!.length,
            itemBuilder: (context, index) {
              String currentPrediction = widget.top5ClassesAndScores![index];
              String key = currentPrediction.split(' ').first;
              String className = localizedNames[key] ?? key;
              String score =
                  currentPrediction.split('(').last.replaceAll(')', '');

              return buildPredictionPage(key, className, score, context);
            },
          );
        },
      ),
    );
  }

  Widget buildPredictionPage(
      String key, String className, String score, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.yourDrawingLooksLike + ':',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          FutureBuilder<String>(
            future: FirebaseStorage.instance
                .ref('${key.replaceAll(' ', '_')}.webp')
                .getDownloadURL(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return Image.network(snapshot.data!);
              } else if (snapshot.error != null) {
                return Text('Error loading image: ${snapshot.error}');
              }
              return CircularProgressIndicator();
            },
          ),
          Text(
            className,
            style: TextStyle(fontFamily: 'Pacifico', fontSize: 45),
            textAlign: TextAlign.center,
          ),
          Text(
            "${AppLocalizations.of(context)!.score}: $score",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Center(
            child: Container(
              width: 200,
              child: ElevatedButton(
                onPressed: () async {
                  await flutterTts.speak(className);
                },
                child: Text(
                  AppLocalizations.of(context)!.pronounce,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  side: BorderSide(color: Color.fromARGB(255, 94, 95, 98)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
