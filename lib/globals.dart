// globals.dart
import 'dart:async';

List<String> lastSixPredictions = [];
StreamController<List<String>> lastSixPredictionsStreamController =
    StreamController.broadcast();
