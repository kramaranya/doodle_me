import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math' as math;

class ResultScreen extends StatefulWidget {
  final List<String>? top5ClassesAndScores;

  ResultScreen({Key? key, required this.top5ClassesAndScores})
      : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String predictedClass = '';

  @override
  void initState() {
    super.initState();
    flutterTts.setSpeechRate(0.3);

    if (widget.top5ClassesAndScores != null &&
        widget.top5ClassesAndScores!.isNotEmpty) {
      predictedClass = widget.top5ClassesAndScores!.first
          .split(' ')
          .first
          .replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 0),
            Text(
              'Your Drawing looks like:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            FutureBuilder(
              future: FirebaseStorage.instance
                  .ref(
                      '${predictedClass.replaceAll(' ', '_')}.webp') // Assuming your files are named using underscores, not spaces
                  .getDownloadURL(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Image.network(snapshot.data!);
                } else if (snapshot.error != null) {
                  return Text('Error loading image: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            SizedBox(height: 20),
            Text(
              '$predictedClass',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 60,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                width: 200,
                child: ElevatedButton(
                  onPressed: () async {
                    flutterTts.setSpeechRate(0.3);
                    await flutterTts.speak(predictedClass);
                  },
                  child: Text(
                    'Pronounce it',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Predicted Classes: ${widget.top5ClassesAndScores?.join(', ') ?? "N/A"}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
