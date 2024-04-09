import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'globals.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late FlutterTts flutterTts;
  late Future<Map<String, String>> _localizedNamesFuture;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    //_loadLocalizedClassNames();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now it's safe to load localized names or access theme data.
    _localizedNamesFuture =
        loadLocalizedClassNames(Localizations.localeOf(context));
    Locale locale = Localizations.localeOf(context);
    flutterTts.setLanguage(locale.toLanguageTag()).then((result) {
      if (result != 1) {
        debugPrint("FlutterTts setLanguage failed");
      }
    });
  }

  void _loadLocalizedClassNames() {
    Locale locale = Localizations.localeOf(context);
    _localizedNamesFuture = loadLocalizedClassNames(locale);
  }

  Future<Map<String, String>> loadLocalizedClassNames(Locale locale) async {
    final jsonString = await rootBundle
        .loadString('assets/class_names_${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  @override
  Widget build(BuildContext context) {
    List<Color> lightColors = [
      Color.fromARGB(255, 139, 220, 255),
      Color.fromARGB(255, 177, 161, 255),
      Color.fromARGB(255, 159, 255, 249),
      Color.fromARGB(255, 246, 255, 194)
    ];

    List<Color> darkColors = [
      Color.fromRGBO(22, 90, 102, 1),
      Color.fromRGBO(76, 12, 83, 1),
      Color.fromRGBO(8, 29, 52, 1),
      Color.fromRGBO(80, 27, 107, 1),
    ];

    List<Color> colors = Theme.of(context).brightness == Brightness.dark
        ? darkColors
        : lightColors;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: colors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Text(
                  AppLocalizations.of(context)!.history,
                  style: TextStyle(
                      fontFamily: 'OpenSans', fontWeight: FontWeight.w600),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: StreamBuilder<List<String>>(
                  stream: lastSixPredictionsStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData) {
                      return Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Color.fromARGB(255, 0, 0, 0).withOpacity(0.4)
                                : Color.fromARGB(255, 255, 255, 255)
                                    .withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)!
                                      .noDataInHistory,
                                  style: TextStyle(
                                    fontFamily: 'OpenSans',
                                    fontWeight: FontWeight.w300,
                                    fontSize: 18,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Color.fromARGB(255, 255, 255, 255)
                                        : Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Color.fromARGB(255, 0, 0, 0).withOpacity(0.4)
                                : Color.fromARGB(255, 255, 255, 255)
                                    .withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)!
                                      .noDataInHistory,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Color.fromARGB(255, 255, 255, 255)
                                        : Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    List<String> predictions = snapshot.data!;
                    return FutureBuilder<Map<String, String>>(
                      future: _localizedNamesFuture,
                      builder: (context, localizedSnapshot) {
                        if (localizedSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (localizedSnapshot.hasError) {
                          return Center(
                              child: Text(
                                  AppLocalizations.of(context)!.localizedData));
                        }

                        if (!localizedSnapshot.hasData ||
                            localizedSnapshot.data!.isEmpty) {
                          return Center(
                              child: Text(
                                  AppLocalizations.of(context)!.localizedData));
                        }

                        // Data is present, build the UI
                        return _buildGridView(
                            predictions, localizedSnapshot.data!);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridView(
      List<String> predictions, Map<String, String> localizedNames) {
    return GridView.builder(
      padding: EdgeInsets.all(5),
      itemCount: predictions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemBuilder: (context, index) {
        String predictionKey = predictions[index];
        String localizedPrediction =
            localizedNames[predictionKey] ?? predictionKey;
        return _buildGridTile(localizedPrediction, predictionKey);
      },
    );
  }

  Widget _buildGridTile(String displayName, String predictionKey) {
    return FutureBuilder<String>(
      future: FirebaseStorage.instance
          .ref('${predictionKey.replaceAll(' ', '_')}.webp')
          .getDownloadURL(),
      builder: (context, snapshot) {
        // Define a variable for imageUrl at the top of the FutureBuilder
        String? imageUrl;

        // Check if the snapshot has data and set the imageUrl if it exists
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          imageUrl = snapshot.data;
        }

        return GestureDetector(
          onTap: () => flutterTts.speak(displayName),
          onLongPress: () {
            if (imageUrl != null) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    insetPadding: EdgeInsets.all(15),
                    backgroundColor: Colors.transparent,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child:
                                    Image.network(imageUrl!, fit: BoxFit.cover),
                              ),
                            ),
                            SizedBox(height: 50),
                          ],
                        ),
                        Positioned(
                          bottom: -10,
                          child: ElevatedButton(
                            onPressed: () {
                              flutterTts.speak(displayName);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor:
                                  Color.fromARGB(255, 225, 225, 225),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  displayName,
                                  style: TextStyle(
                                      fontFamily: 'OpenSans',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.volume_up, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
          child: GridTile(
            footer: Container(
              padding: EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'OpenSans',
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
              ),
            ),
            child: imageUrl != null
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : Center(
                    child: snapshot.hasError
                        ? Text('Error loading image')
                        : CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
