import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'result_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'globals.dart';

class DrawingScreen extends StatefulWidget {
  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

Future<List<List<double>>> sendDrawingToServer(
    List<Offset?> points, double canvasSize) async {
  var uri = Uri.parse(
      'https://doodle-me-flask-64dde020fc72.herokuapp.com/preprocess');

  double width = canvasSize;
  double height = canvasSize;

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
  var response = await http.post(
    uri,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      'strokes': formattedStrokes,
      'canvasSize': {'width': width, 'height': height},
    }),
  );

  if (response.statusCode == 200) {
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
    throw Exception('Failed to load processed drawing');
  }
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<Offset?> points = [];
  String predictedClass = '';
  Interpreter? interpreter;
  List<String>? top5ClassesAndScores;
  List<String>? classLabels;
  Map<String, String> localizedClassNames = {};
  int _colorIndex = 0;
  double _blurRadius = 5.0;
  double topOffsetY = 0.0;
  double topOffsetX = 0.0;
  final GlobalKey _gestureDetectorKey = GlobalKey();

  List<Color> _lightColors = [
    Color.fromARGB(255, 139, 220, 255),
    Color.fromARGB(255, 177, 161, 255),
    Color.fromARGB(255, 159, 255, 249),
    Color.fromARGB(255, 246, 255, 194)
  ];

  List<Color> _darkColors = [
    Color.fromRGBO(22, 90, 102, 1),
    Color.fromRGBO(76, 12, 83, 1),
    Color.fromRGBO(8, 29, 52, 1),
    Color.fromRGBO(80, 27, 107, 1),
  ];

  Future<void> loadModel(List<List<double>> encodedDrawing) async {
    try {
      interpreter =
          await Interpreter.fromAsset('assets/models/CNN_model.tflite');
      final labelData = await rootBundle.loadString('assets/classes.txt');
      classLabels = labelData.split('\n');
      predict(encodedDrawing);
    } catch (e) {
      print('Failed to load model: $e');
      setState(() {
        predictedClass = 'Failed to load model';
      });
    }
  }

  void predict(List<List<double>> encodedDrawing) async {
    var normalizedData = encodedDrawing.expand((row) => row).toList();

    var input = Float32List.fromList(normalizedData).reshape([1, 28, 28, 1]);

    var output = List.filled(1 * classLabels!.length, 0.0)
        .reshape([1, classLabels!.length]);

    interpreter?.run(input, output);
    List<double> scores = output[0].cast<double>();

    int highestScoreIndex =
        scores.indexWhere((score) => score == scores.reduce(math.max));

    String predictedKey = classLabels![highestScoreIndex];
    String localizedPredictedClass =
        localizedClassNames[predictedKey] ?? predictedKey;

    setState(() {
      predictedClass = localizedPredictedClass;
    });

    final topIndices = List.generate(scores.length, (i) => i)
      ..sort((a, b) => scores[b].compareTo(scores[a]));

    final top5Indices = topIndices.take(5);
    top5ClassesAndScores = top5Indices
        .map((i) => '${classLabels![i]} (${scores[i].toStringAsFixed(2)})')
        .toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => calculateOffset());
    predictedClass = '';
    _startColorTransition();
  }

  void _startColorTransition() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _colorIndex++;
        if (_colorIndex == _lightColors.length) {
          _colorIndex = 0;
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadLocalizedClassNames();
  }

  Future<void> loadLocalizedClassNames() async {
    Locale locale = Localizations.localeOf(context);
    String fileName = 'assets/class_names_${locale.languageCode}.json';
    String jsonString = await rootBundle.loadString(fileName);
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    setState(() {
      localizedClassNames =
          jsonMap.map((key, value) => MapEntry(key, value.toString()));
    });
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = json.encode(lastTenPredictions);
    await prefs.setString('historyData', historyJson);
  }

  void calculateOffset() {
    final RenderBox renderBox =
        _gestureDetectorKey.currentContext?.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    topOffsetY = offset.dy;
    topOffsetX = offset.dx;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final offsetX = 5.0;
    final offsetY = 5.0;
    final drawingAreaSize = screenSize.width - 2 * offsetX;
    final leftBoundary = offsetX;
    final rightBoundary = offsetX + drawingAreaSize;
    final topBoundary = offsetY;
    final bottomBoundary = drawingAreaSize;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AnimatedContainer(
          duration: Duration(seconds: 5),
          onEnd: () {
            setState(() {
              // Ensure the color transition continues
              _startColorTransition();
            });
          },
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      _darkColors[_colorIndex % _darkColors.length],
                      _darkColors[(_colorIndex + 1) % _darkColors.length],
                      _darkColors[(_colorIndex + 2) % _darkColors.length],
                      _darkColors[(_colorIndex + 3) % _darkColors.length],
                    ]
                  : [
                      _lightColors[_colorIndex % _lightColors.length],
                      _lightColors[(_colorIndex + 1) % _lightColors.length],
                      _lightColors[(_colorIndex + 2) % _lightColors.length],
                      _lightColors[(_colorIndex + 3) % _lightColors.length],
                    ],
            ),
          ),
          child: AppBar(
            backgroundColor: Color.fromARGB(0, 255, 255, 255),
            elevation: 0,
            title: Text(
              AppLocalizations.of(context)!.drawyourdoodle,
              style: TextStyle(
                  fontFamily: 'OpenSans', fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(seconds: 5),
            onEnd: () {
              setState(() {
                _startColorTransition();
                isDarkMode = Theme.of(context).brightness == Brightness.dark;
              });
            },
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        _darkColors[_colorIndex % _darkColors.length],
                        _darkColors[(_colorIndex + 1) % _darkColors.length],
                        _darkColors[(_colorIndex + 2) % _darkColors.length],
                        _darkColors[(_colorIndex + 3) % _darkColors.length],
                      ]
                    : [
                        _lightColors[_colorIndex % _lightColors.length],
                        _lightColors[(_colorIndex + 1) % _lightColors.length],
                        _lightColors[(_colorIndex + 2) % _lightColors.length],
                        _lightColors[(_colorIndex + 3) % _lightColors.length],
                      ],
              ),
            ),
            child: BackdropFilter(
              filter:
                  ImageFilter.blur(sigmaX: _blurRadius, sigmaY: _blurRadius),
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: offsetX,
            top: offsetY,
            child: GestureDetector(
              key: _gestureDetectorKey,
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  Offset localPosition =
                      renderBox.globalToLocal(details.globalPosition);
                  double adjustedX = localPosition.dx - topOffsetX;
                  double adjustedY = localPosition.dy - topOffsetY;

                  Offset adjustedPosition = Offset(adjustedX, adjustedY);

                  if (adjustedX >= leftBoundary &&
                      adjustedX <= rightBoundary &&
                      adjustedY >= topBoundary &&
                      adjustedY <= bottomBoundary) {
                    points.add(adjustedPosition);
                  }
                });
              },
              onPanEnd: (details) async {
                setState(() {
                  points.add(null);
                });
                final encodedDrawing =
                    await sendDrawingToServer(points, drawingAreaSize);
                loadModel(encodedDrawing);
              },
              child: CustomPaint(
                painter: DrawingPainter(points: points),
                size: Size(drawingAreaSize, drawingAreaSize),
              ),
            ),
          ),
          Positioned(
            bottom: (screenSize.height - drawingAreaSize) / 3,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color.fromARGB(255, 0, 0, 0).withOpacity(0.4)
                      : Color.fromARGB(255, 255, 255, 255).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.looksLike + ' ',
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'OpenSans',
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Color.fromARGB(255, 226, 226, 226)
                              : Color.fromARGB(198, 29, 29, 29),
                        ),
                      ),
                      TextSpan(
                        text: predictedClass,
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'OpenSans',
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Color.fromARGB(255, 255, 255, 255)
                              : Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      TextSpan(
                        text: '...',
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'OpenSans',
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Color.fromARGB(255, 226, 226, 226)
                              : Color.fromARGB(198, 29, 29, 29),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                if (top5ClassesAndScores != null &&
                    top5ClassesAndScores!.isNotEmpty) {
                  String topPrediction =
                      top5ClassesAndScores![0].split(' ').first;
                  if (!lastTenPredictions.contains(topPrediction)) {
                    lastTenPredictions.insert(0, topPrediction);
                    if (lastTenPredictions.length > 10) {
                      lastTenPredictions.removeLast();
                    }
                    lastTenPredictionsStreamController.add(lastTenPredictions);
                    saveHistory();
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(
                          top5ClassesAndScores: top5ClassesAndScores),
                    ),
                  );
                } else {
                  // Show a SnackBar when top5ClassesAndScores is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(AppLocalizations.of(context)!.drawingisempty),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              tooltip: 'See Result',
              child: Icon(Icons.check),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.7),
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  points.clear();
                  predictedClass = '';
                  top5ClassesAndScores = [];
                });
              },
              tooltip: 'Clear Drawing',
              child: Icon(Icons.delete),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.7),
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
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

  Paint backgroundPaint = Paint()..color = Colors.white.withOpacity(0.5);

  final Paint framePaint = Paint()
    ..color = Color.fromARGB(255, 255, 255, 255).withOpacity(0.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5;

  final double borderRadius = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0;

    RRect roundedRectangle = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(roundedRectangle, backgroundPaint);

    canvas.drawRRect(roundedRectangle, framePaint);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
