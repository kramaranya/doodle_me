import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math' as math;

class ResultScreen extends StatefulWidget {
  final List<List<double>> encodedDrawing;

  ResultScreen({Key? key, required this.encodedDrawing}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String predictedClass = '';
  Interpreter? interpreter;
  List<String>? top5ClassesAndScores;
  List<String>? classLabels;

  @override
  void initState() {
    super.initState();
    printEncodedDrawing();
    loadModel();
  }

  void printEncodedDrawing() {
    print("Encoded Drawing Data: ${widget.encodedDrawing}");
  }

  Future<void> loadModel() async {
    try {
      interpreter =
          await Interpreter.fromAsset('assets/models/CNN_model.tflite');
      final labelData = await rootBundle.loadString('assets/class_names.txt');
      classLabels = labelData.split('\n');
      predict();
    } catch (e) {
      print('Failed to load model: $e');
      setState(() {
        predictedClass = 'Failed to load model';
      });
    }
  }

  void predict() async {
    var normalizedData = widget.encodedDrawing.expand((row) => row).toList();

    var input = Float32List.fromList(normalizedData).reshape([1, 28, 28, 1]);

    var output = List.filled(1 * classLabels!.length, 0.0)
        .reshape([1, classLabels!.length]);

    interpreter?.run(input, output);
    List<double> scores = output[0].cast<double>();

    int highestScoreIndex =
        scores.indexWhere((score) => score == scores.reduce(math.max));

    setState(() {
      predictedClass = classLabels![highestScoreIndex];
    });

    final topIndices = List.generate(scores.length, (i) => i)
      ..sort((a, b) => scores[b].compareTo(scores[a]));

    final top5Indices = topIndices.take(5);
    top5ClassesAndScores = top5Indices
        .map((i) => '${classLabels![i]} (${scores[i].toStringAsFixed(2)})')
        .toList();

    print(top5ClassesAndScores);
  }

  @override
  Widget build(BuildContext context) {
    String displayClass = predictedClass.replaceAll('_', ' ');

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
                  .ref('$predictedClass.webp')
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
              '$displayClass',
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
                    await flutterTts.speak(displayClass);
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
                'Predicted Class: $top5ClassesAndScores',
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
