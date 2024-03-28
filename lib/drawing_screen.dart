import 'package:flutter/material.dart';
import 'result_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DrawingScreen extends StatefulWidget {
  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

Future<List<List<double>>> sendDrawingToServer(List<Offset?> points) async {
  var uri = Uri.parse('http://127.0.0.1:5000/preprocess');

  List<List<List<double>>> formattedStrokes = [];
  List<double> currentXs = [];
  List<double> currentYs = [];

  for (Offset? point in points) {
    if (point == null) {
      if (currentXs.isNotEmpty && currentYs.isNotEmpty) {
        formattedStrokes.add([List.from(currentXs), List.from(currentYs)]);
        currentXs.clear();
        currentYs.clear();
      }
    } else {
      currentXs.add(point.dx);
      currentYs.add(point.dy);
    }
  }

  if (currentXs.isNotEmpty && currentYs.isNotEmpty) {
    formattedStrokes.add([currentXs, currentYs]);
  }
  print("formatted: $formattedStrokes");
  var response = await http.post(
    uri,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({'strokes': formattedStrokes}),
  );
  print(response.body);

  if (response.statusCode == 200) {
    print("Data sent successfully");

    final decodedResponse = jsonDecode(response.body);

    final List<List<double>> result =
        (decodedResponse as List).map<List<double>>((row) {
      return (row as List).map<double>((value) {
        return (value is int) ? value.toDouble() : value as double;
      }).toList();
    }).toList();

    return result;
  } else {
    print("Failed to send data with status code: ${response.statusCode}");
    print("Response body: ${response.body}");
    throw Exception('Failed to load processed drawing');
  }
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<Offset?> points = [];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final drawingAreaSize = screenSize.width;
    final offsetX = 0.0;
    final offsetY = (screenSize.height - drawingAreaSize) / 5;
    final leftBoundary = offsetX;
    final rightBoundary = offsetX + drawingAreaSize;
    final topBoundary = 1.5 * offsetY;
    final bottomBoundary = 1.5 * offsetY + drawingAreaSize;

    return Scaffold(
      appBar: AppBar(
        title: Text('Draw Your Doodle'),
      ),
      body: Stack(
        children: [
          Positioned(
            left: offsetX,
            top: offsetY,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  Offset localPosition =
                      renderBox.globalToLocal(details.globalPosition);

                  double adjustedX = localPosition.dx - offsetX;
                  double adjustedY = localPosition.dy - offsetY * 1.5;

                  Offset adjustedPosition = Offset(adjustedX, adjustedY);

                  if (localPosition.dx >= leftBoundary &&
                      localPosition.dx <= rightBoundary &&
                      localPosition.dy >= topBoundary &&
                      localPosition.dy <= bottomBoundary) {
                    points.add(adjustedPosition);
                    print(points);
                  }
                });
              },
              onPanEnd: (details) {
                setState(() {
                  points.add(null);
                });
              },
              child: CustomPaint(
                painter: DrawingPainter(points: points),
                size: Size(drawingAreaSize, drawingAreaSize),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                try {
                  final encodedDrawing = await sendDrawingToServer(points);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ResultScreen(encodedDrawing: encodedDrawing),
                    ),
                  );
                } catch (e, stackTrace) {
                  print("Error sending drawing to server: $e");
                  print("Stack Trace: $stackTrace");
                }
              },
              tooltip: 'See Result',
              child: Icon(Icons.check),
              backgroundColor: Color.fromARGB(69, 158, 158, 158),
              foregroundColor: Colors.white,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  points.clear();
                });
              },
              tooltip: 'Clear Drawing',
              child: Icon(Icons.delete),
              backgroundColor: Color.fromARGB(100, 158, 158, 158),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  DrawingPainter({required this.points});

  final Paint framePaint = Paint()
    ..color = Color.fromARGB(129, 184, 184, 184)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), framePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
