// globals.dart
import 'dart:async';

List<String> lastTenPredictions = [];
StreamController<List<String>> lastTenPredictionsStreamController =
    StreamController.broadcast();
