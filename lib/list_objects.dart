import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<String>> _classNamesFuture;
  late FlutterTts flutterTts;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    _classNamesFuture = loadClassNames();
    flutterTts = FlutterTts();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<String>> loadClassNames() async {
    final String contents = await rootBundle.loadString('assets/classes.txt');
    List<String> lines =
        contents.split('\n').map((line) => line.trim()).toList();
    lines.sort();
    return lines;
  }

  Future<String> getImageUrl(String name) async {
    String imageUrl =
        await FirebaseStorage.instance.ref('$name.webp').getDownloadURL();
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            suffixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(
                () {}); // Triggers a rebuild whenever the user types something
          },
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: _classNamesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            // Filter the list based on the search query
            var filteredList = snapshot.data!.where((className) {
              return className
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
                String className = filteredList[index].replaceAll('_', ' ');
                return FutureBuilder<String>(
                  future: getImageUrl(filteredList[index]),
                  builder: (context, imageSnapshot) {
                    if (imageSnapshot.connectionState == ConnectionState.done &&
                        imageSnapshot.hasData) {
                      return GestureDetector(
                        onTap: () {
                          flutterTts.speak(className);
                        },
                        onLongPress: () {
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
                                          filter: ImageFilter.blur(
                                              sigmaX: 4, sigmaY: 4),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                                imageSnapshot.data!,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                        SizedBox(
                                            height:
                                                50), // Space for the floating button
                                      ],
                                    ),
                                    Positioned(
                                      bottom: -10,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          flutterTts.speak(className);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Color.fromARGB(
                                              255, 225, 225, 225),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Pronounce',
                                                style: TextStyle(fontSize: 15)),
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
                        },
                        child: GridTile(
                          child: Image.network(imageSnapshot.data!,
                              fit: BoxFit.cover),
                          footer: GridTileBar(
                            backgroundColor: Colors.black45,
                            title:
                                Text(className, style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      );
                    } else if (imageSnapshot.hasError) {
                      return Text('Error loading image');
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error loading names');
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
