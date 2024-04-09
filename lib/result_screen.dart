import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ResultScreen extends StatefulWidget {
  final List<String>? top5ClassesAndScores;

  ResultScreen({Key? key, required this.top5ClassesAndScores})
      : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final controller = PageController(viewportFraction: 1);
  ValueNotifier<int> colorIndexNotifier = ValueNotifier<int>(0);

  List<Color> _lightColors = [
    Color.fromARGB(255, 139, 220, 255),
    Color.fromARGB(255, 177, 161, 255), // New color added
    // Add more colors if you want
  ];

  List<Color> _darkColors = [
    Color.fromARGB(255, 53, 42, 119),
    Color.fromARGB(255, 0, 70, 168),
    // Add more colors if you want
  ];

  @override
  void initState() {
    super.initState();
    flutterTts.setSpeechRate(0.3);
  }

  @override
  void dispose() {
    colorIndexNotifier.dispose();
    super.dispose();
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

  List<String> get filteredTop5ClassesAndScores =>
      widget.top5ClassesAndScores!.where((prediction) {
        double score =
            double.parse(prediction.split('(').last.replaceAll(')', ''));
        return score > 0;
      }).toList();

  @override
  Widget build(BuildContext context) {
    if (widget.top5ClassesAndScores == null ||
        widget.top5ClassesAndScores!.isEmpty) {
      return Scaffold(
        body: Center(child: Text("No predictions available")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.explore,
          style: TextStyle(fontFamily: 'OpenSans', fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    padding: EdgeInsets.all(20),
                    height: MediaQuery.of(context).size.height * 0.20,
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.tryAgainMessage,
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'OpenSans',
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              );
            },
            tooltip: AppLocalizations.of(context)!.helpTooltip,
          ),
        ],
      ),
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
          return Column(
            children: [
              Padding(
                // Adjust padding as needed to position the text
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.of(context)!.yourDrawingLooksLike + ':',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: controller,
                      itemCount: filteredTop5ClassesAndScores.length,
                      itemBuilder: (context, index) {
                        String currentPrediction =
                            filteredTop5ClassesAndScores[index];
                        String key = currentPrediction.split(' ').first;
                        String className = localizedNames[key] ?? key;
                        String score = currentPrediction
                            .split('(')
                            .last
                            .replaceAll(')', '');
                        double scoreValue = double.tryParse(score) ?? 0;
                        String scorePercentage =
                            (scoreValue * 100).toStringAsFixed(1) + '%';
                        return buildPredictionPage(
                            key, className, scorePercentage, context);
                      },
                    ),
                    if (filteredTop5ClassesAndScores.length > 1)
                      Positioned(
                        top: 0,
                        bottom: 100,
                        left: 10,
                        child: Center(
                          child: IconButton(
                            icon:
                                Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () {
                              if (controller.page! > 0) {
                                controller.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    if (filteredTop5ClassesAndScores.length > 1)
                      Positioned(
                        top: 0,
                        bottom: 100,
                        right: 10,
                        child: Center(
                          child: IconButton(
                            icon: Icon(Icons.arrow_forward_ios,
                                color: Colors.white),
                            onPressed: () {
                              if (controller.page! <
                                  filteredTop5ClassesAndScores.length - 1) {
                                controller.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 8,
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: controller,
                          count: filteredTop5ClassesAndScores.length,
                          effect: WormEffect(
                            dotHeight: 10,
                            dotWidth: 10,
                            activeDotColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
          SizedBox(
            height: 20,
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "   $className",
                  style: TextStyle(fontFamily: 'OpenSans', fontSize: 30),
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          height: MediaQuery.of(context).size.height * 0.20,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  AppLocalizations.of(context)!.accuracy +
                                      score,
                                  style: TextStyle(
                                      fontSize: 21,
                                      fontFamily: 'OpenSans',
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.weare +
                                      score +
                                      AppLocalizations.of(context)!.confident +
                                      className +
                                      '.',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'OpenSans',
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Icons.info_outline,
                    size: 20,
                  ),
                  tooltip: "Learn more about this prediction",
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
          ),
          AnimatedBuilder(
            animation: colorIndexNotifier,
            builder: (context, child) {
              // Determine the current and next color based on the theme
              List<Color> colors =
                  Theme.of(context).brightness == Brightness.dark
                      ? _darkColors
                      : _lightColors;
              Color beginColor =
                  colors[colorIndexNotifier.value % colors.length];
              Color endColor =
                  colors[(colorIndexNotifier.value + 1) % colors.length];

              return Center(
                child: Container(
                  width: 250,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [beginColor, endColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.volume_up,
                      size: 24,
                      color: Colors.white,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.pronounce,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'OpenSans',
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors
                          .transparent, // Make the button background transparent
                      shadowColor: Colors.transparent, // Remove shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () => flutterTts.speak(className),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
