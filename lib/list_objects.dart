import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<String>> _classNamesFuture;
  late Future<Map<String, String>> _localizedNamesFuture;
  late FlutterTts flutterTts;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    searchController = TextEditingController();
    _classNamesFuture = loadClassNames();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizedNamesFuture = loadDoodleNames();

    Locale locale = Localizations.localeOf(context);
    flutterTts.setLanguage(locale.toLanguageTag()).then((result) {
      if (result != 1) {
        debugPrint("FlutterTts setLanguage failed");
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<String>> loadClassNames() async {
    final String contents = await rootBundle.loadString('assets/classes.txt');
    return contents.split('\n').map((line) => line.trim()).toList()..sort();
  }

  Future<Map<String, String>> loadDoodleNames() async {
    Locale locale = Localizations.localeOf(context);
    final jsonString = await rootBundle
        .loadString('assets/class_names_${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  Future<String> getImageUrl(String name) async {
    return await FirebaseStorage.instance.ref('$name.webp').getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.search + '...',
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 43, 43, 43)
                : Colors.grey[200],
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            suffixIcon: Icon(Icons.search),
            contentPadding: EdgeInsets.all(15),
          ),
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.w400,
          ),
          onChanged: (value) => setState(() {}),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: FutureBuilder<List<String>>(
          future: _classNamesFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            var filteredList = snapshot.data!
                .where((className) => className
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()))
                .toList();

            return FutureBuilder<Map<String, String>>(
              future: _localizedNamesFuture,
              builder: (context, localizedSnapshot) {
                if (!localizedSnapshot.hasData)
                  return CircularProgressIndicator();
                var filteredList = snapshot.data!.where((className) {
                  String? displayName = localizedSnapshot.data![className];
                  return displayName != null &&
                      displayName
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase());
                }).toList();
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 3.0,
                    mainAxisSpacing: 3.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    String className = filteredList[index];
                    String displayName =
                        localizedSnapshot.data![className] ?? className;
                    return FutureBuilder<String>(
                      future: getImageUrl(className),
                      builder: (context, imageSnapshot) {
                        if (imageSnapshot.hasData) {
                          return buildGridTile(
                              displayName, imageSnapshot.data!);
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildGridTile(String displayName, String? imageUrl) {
    return GestureDetector(
      onTap: () {
        flutterTts.speak(displayName);
      },
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
                            child: Image.network(imageUrl, fit: BoxFit.cover),
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
                          backgroundColor: Color.fromARGB(255, 225, 225, 225),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'OpenSans',
                                  fontWeight: FontWeight.w500),
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
        child: imageUrl != null
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : SizedBox(),
        footer: GridTileBar(
          backgroundColor: Colors.black45,
          title: Text(
            displayName,
            style: TextStyle(
                fontSize: 15,
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.w400,
                color: Colors.white),
          ),
        ),
      ),
    );
  }
}
