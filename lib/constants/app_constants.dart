import 'package:flutter/material.dart';

import '../lang/local_keys.dart';

/// A class to store all app-wide constant values.
class AppConstants {

  static const String title="Hassan Hallak Task (Object Detection)";

  // Model Paths
  static const String modelPath = 'assets/models/ssd_mobilenet.tflite';
  static const String labelPath = 'assets/models/labelmap.txt';

  //isolate data
  static const String sendPort="sendPort";
  static const String selectedObject="selectedObject";
  static const String capture="capture";


  // Object Detection Confidence Threshold
  static const double confidenceThreshold = 0.5;

  // Model Input Size (Height = Width)
  static const int mlModelInputSize = 300;

  // Object Size Thresholds for Auto-Capture
  static const double minObjectSizeThreshold = 0.3; // Too small → "Move closer"
  static const double maxObjectSizeThreshold = 0.8; // Too large → "Move farther"

  // Guidance Messages for Object Positioning
  static const String moveCloserMessage = "Move closer";
  static const String moveFartherMessage = "Move farther";
  static const String objectInPositionMessage = "Object in position";
  static const String detectingObjectMessage = "Detecting"; // Used when no object is found

  // Available Object Types for Selection
  static const List<String> availableObjects = [
    LocalKeys.laptop, LocalKeys.mouse, LocalKeys.bottle
  ];

  // UI Design Constants
  static const double cardElevation = 5.0;
  static const double buttonPadding = 12.0;
  static const double borderRadius = 10.0;



  // Stats Keys for Detection
  static const String conversionTimeKey = 'Conversion time:';
  static const String recognitions = 'recognitions';
  static const String stats = 'stats';
  static const String preProcessingTimeKey = 'Pre-processing time:';
  static const String inferenceTimeKey = 'Inference time:';
  static const String totalPredictionTimeKey = 'Total prediction time:';
  static const String frameSizeKey = 'Frame';



  // Image Capture Delay (Prevents multiple captures)
  static const Duration captureCooldown = Duration(seconds: 3);
}
