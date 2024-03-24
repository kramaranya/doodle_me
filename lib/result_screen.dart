import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math' as math;

class ResultScreen extends StatefulWidget {
  final List<List<double>> encodedDrawing;

  ResultScreen({Key? key, required this.encodedDrawing}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class ImagePainter extends CustomPainter {
  final List<List<double>> imageData;

  ImagePainter(this.imageData);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    double pixelSize =
        size.width / imageData[0].length; // Ensure the image scales correctly.

    for (int i = 0; i < imageData.length; i++) {
      for (int j = 0; j < imageData[i].length; j++) {
        double intensity =
            1 - imageData[i][j]; // Corrected: No division by 255.
        paint.color = Color.fromRGBO((intensity * 255).toInt(),
            (intensity * 255).toInt(), (intensity * 255).toInt(), 1);
        canvas.drawRect(
            Rect.fromLTWH(j * pixelSize, i * pixelSize, pixelSize, pixelSize),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Might want to implement logic to check if the image data has changed if dynamic updates are needed.
    return false;
  }
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
      interpreter = await Interpreter.fromAsset('assets/models/model5.tflite');
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
    predictedClass = '4';
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

  Float32List preprocessData(List<List<List<int>>> data) {
    return Float32List.fromList(data
        .expand((x) => x.expand((y) => y).toList())
        .map((x) => x / 255.0)
        .toList());
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
            Container(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: ImagePainter(widget.encodedDrawing),
              ),
            ),
            SizedBox(height: 20),
            //Image.asset('assets/flower.jpeg'),
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
