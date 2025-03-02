

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as image_lib;

import 'package:tflite_flutter/tflite_flutter.dart';

import '../constants/app_constants.dart';
import '../models/recognition.dart';
import '../controllers/scan_controller.dart';
import '../utils/image_utils.dart';




/// All the command codes that can be sent and received between [Detector] and
/// [_DetectorServer].
enum _Codes {
  init,
  busy,
  ready,
  detect,
  result,
  capture,
}

/// A command sent between [Detector] and [_DetectorServer].
class _Command {
   _Command(this.code, {this.args});

  final _Codes code;
  final List<Object>? args;

}

/// A Simple Detector that handles object detection via Service
///
/// All the heavy operations like pre-processing, detection, ets,
/// are executed in a background isolate.
/// This class just sends and receives messages to the isolate.
class Detector {


//  Detector._({this._isolate, this._interpreter, this._labels, this._selectedObject,this.cameraController});
  Detector({this.isolate, this.interpreter, this.labels, this.selectedObject,this.cameraController});

  final Isolate? isolate;
   CameraController? cameraController;
   final Interpreter? interpreter;
   final List<String>? labels;
  final String? selectedObject;

  // To be used by detector (from UI) to send message to our Service ReceivePort
  late final SendPort _sendPort;

  bool _isReady = false;

  // Stream to send results to the UI
  final StreamController<Map<String, dynamic>> resultsStream =
  StreamController<Map<String, dynamic>>();

  /// Open the database at [path] and launch the server on a background isolate.
   Future<Detector> start({
    required String selectedObject,

  }) async {

    final ReceivePort receivePort = ReceivePort();

    // Bundle parameters into a Map
    final params = {
      AppConstants.sendPort: receivePort.sendPort,
      AppConstants.selectedObject: selectedObject,
    };

    // Spawn the isolate and pass the parameters


    _DetectorServer detectorServer=_DetectorServer(
        sendPort:  receivePort.sendPort,selectedObject:  selectedObject,
      cameraController: cameraController

        );
    final Isolate isolate=await detectorServer.localRun(params,null);

    // final Isolate isolate = await Isolate.spawn(
    //   _DetectorServer._run,
    //   params,
    // );

     var model= await _loadModel();
     var allLabels=  await _loadLabels();
    final Detector result = Detector(
     isolate:  isolate,
     interpreter: model,
      labels: allLabels,
     selectedObject: selectedObject,
      cameraController: cameraController
    );

    // Listen for messages from the isolate
    receivePort.listen((message) {
      result._handleCommand(message as _Command);
    });

    return result;
  }

  /// Load the TensorFlow Lite model.
  static Future<Interpreter> _loadModel() async {
    final interpreterOptions = InterpreterOptions();

    // Use XNNPACK Delegate for Android
    if (Platform.isAndroid) {
      interpreterOptions.addDelegate(XNNPackDelegate());
    }

    return Interpreter.fromAsset(
      AppConstants.modelPath,
      options: interpreterOptions..threads = 4,
    );
  }

  /// Load the labels for the model.
  static Future<List<String>> _loadLabels() async {
    return (await rootBundle.loadString(AppConstants.labelPath)).split('\n');
  }

  /// Starts CameraImage processing.
  void processFrame(CameraImage cameraImage) {


    if (_isReady) {
      _sendPort.send(_Command(_Codes.detect, args: [cameraImage]),);
    }
  }

  /// Handler invoked when a message is received from the port communicating
  /// with the database server.
  Future<void> _handleCommand(_Command command) async {
    switch (command.code) {
      case _Codes.init:
        _sendPort = command.args?[0] as SendPort;
        RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
        _sendPort.send(_Command(_Codes.init, args: [
          rootIsolateToken,
          interpreter?.address??-1,
          labels??[],
        ]));
        break;

      case _Codes.ready:
        _isReady = true;
        break;

      case _Codes.busy:
        _isReady = false;
        break;

      case _Codes.result:
        _isReady = true;
        resultsStream.add(command.args?[0] as Map<String, dynamic>);
        break;


      case _Codes.capture:
        ScanController scanController = Get.find();
        if (scanController.cameraController?.value.isInitialized ?? false) {
          try {
            final image = await scanController.cameraController?.takePicture();
            if (image?.path.isNotEmpty ?? false) {
              resultsStream.add({AppConstants.capture: image?.path});
            } else {
              debugPrint("Captured image path is empty!");
            }
          } catch (e) {
            debugPrint("Failed to capture image: $e");
          }
        }
        break;



      default:
        debugPrint('Detector unrecognized command: ${command.code}');
    }
  }

  /// Kills the background isolate and its detector server.
  void stop() {
    isolate?.kill();
  }
}

/// The portion of the [Detector] that runs on the background isolate.
///
/// This is where we use the new feature Background Isolate Channels, which
/// allows us to use plugins from background isolates.
/// The portion of the [Detector] that runs on the background isolate.
/// The portion of the [Detector] that runs on the background isolate.
class _DetectorServer {
  /// Input size of image (height = width = 300)

  bool _isCapturing = false;


  Interpreter? _interpreter;
  List<String>? _labels;
  final String? selectedObject;
  final SendPort? sendPort;
   CameraController? cameraController;

  _DetectorServer( {this.selectedObject,this.sendPort,this.cameraController});

  /// The main entrypoint for the background isolate sent to [Isolate.spawn].
 static  void _run(Map<String, dynamic> params) {

    final SendPort sendPort = params[AppConstants.sendPort];
    final String selectedObject = params[AppConstants.selectedObject];
   // final CameraController cameraController = params['cameraController'];

    ReceivePort receivePort = ReceivePort();
    final _DetectorServer server = _DetectorServer(sendPort: sendPort,selectedObject: selectedObject );
    receivePort.listen((message) {
      final _Command command = message as _Command;
      server._handleCommand(command);
    });

    sendPort.send(_Command(_Codes.init, args: [receivePort.sendPort]));
  }

   Future<Isolate> localRun(Map<String, dynamic> params,CameraController? controller) async {
     // cameraController=controller;
      final SendPort sendPortValue = params[AppConstants.sendPort];
      final String selectedObjectValue = params[AppConstants.selectedObject];
      ReceivePort receivePort = ReceivePort();

     final Isolate isolate = await Isolate.spawn(
       _run,
       params,
     );
     return isolate;
  }

    void run(Map<String, dynamic> params) {

    ReceivePort receivePort = ReceivePort();
    receivePort.listen((message) {
      final _Command command = message as _Command;
      _handleCommand(command);
    });
    sendPort?.send(_Command(_Codes.init, args: [receivePort.sendPort]));
  }




  /// Handle the [command] received from the [ReceivePort].
  void _handleCommand(_Command command,{CameraController? controller}) {
    switch (command.code) {
      case _Codes.init:
        RootIsolateToken rootIsolateToken = command.args?[0] as RootIsolateToken;
        BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
        _interpreter = Interpreter.fromAddress(command.args?[1] as int);
        _labels = command.args?[2] as List<String>;
        sendPort?.send( _Command(_Codes.ready));
        break;

      case _Codes.detect:
        controller;
        sendPort?.send( _Command(_Codes.busy));
        _convertCameraImage(command.args?[0] as CameraImage,cameraController:cameraController);
        break;

      default:
        debugPrint('_DetectorService unrecognized command ${command.code}');
    }
  }

  void _convertCameraImage(CameraImage cameraImage, {required CameraController? cameraController}) {
    var preConversionTime = DateTime.now().millisecondsSinceEpoch;

    convertCameraImageToImage(cameraImage).then((image) {
      if (image != null) {
        if (Platform.isAndroid) {
          image = image_lib.copyRotate(image, angle: 90);
        }

        final results = analyseImage(image, preConversionTime,cameraController:cameraController);
        sendPort?.send(_Command(_Codes.result, args: [results]));
      }
    });
  }

  Map<String, dynamic> analyseImage(image_lib.Image? image, int preConversionTime, {required CameraController? cameraController}) {
    var conversionElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preConversionTime;

    var preProcessStart = DateTime.now().millisecondsSinceEpoch;

    // Pre-process the image
    final imageInput = image_lib.copyResize(
      image!,
      width: AppConstants.mlModelInputSize,
      height: AppConstants.mlModelInputSize,
    );

    // Create matrix representation [300, 300, 3]
    final imageMatrix = List.generate(
      imageInput.height,
          (y) => List.generate(
        imageInput.width,
            (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

    var preProcessElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preProcessStart;

    var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;

    final output = _runInference(imageMatrix);

    // Location
    final locationsRaw = output.first.first as List<List<double>>;
    final List<Rect> locations = locationsRaw
        .map((list) => list.map((value) => (value * AppConstants.mlModelInputSize)).toList())
        .map((rect) => Rect.fromLTRB(rect[1], rect[0], rect[3], rect[2]))
        .toList();

    // Classes
    final classesRaw = output.elementAt(1).first as List<double>;
    final classes = classesRaw.map((value) => value.toInt()).toList();

    // Scores
    final scores = output.elementAt(2).first as List<double>;

    // Number of detections
    final numberOfDetectionsRaw = output.last.first as double;
    final numberOfDetections = numberOfDetectionsRaw.toInt();

    final List<String> classification = [];
    for (var i = 0; i < numberOfDetections; i++) {
      classification.add(_labels![classes[i]]);
    }

    // Generate recognitions
    List<Recognition> recognitions = [];
    for (int i = 0; i < numberOfDetections; i++) {
      var score = scores[i];
      var label = classification[i];

      if (score >= AppConstants.confidenceThreshold &&  selectedObject!=null && selectedObject!.isNotEmpty && label == selectedObject) {
        final box = locations[i];
        final boxArea = (box.width * box.height) / (AppConstants.mlModelInputSize *AppConstants.mlModelInputSize);
        final guidanceMessage = _getGuidanceMessage(boxArea);

        recognitions.add(
          Recognition(i, label, score, locations[i], guidanceMessage),
        );

        // Trigger capture when guidance is "Object in position"
        if (guidanceMessage == AppConstants.objectInPositionMessage) {
          _captureImage();
        }
      }
    }

    var inferenceElapsedTime =
        DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;

    var totalElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preConversionTime;

    return {
      AppConstants.recognitions: recognitions,
      AppConstants.stats: <String, String>{
        AppConstants.conversionTimeKey: conversionElapsedTime.toString(),
        AppConstants.preProcessingTimeKey: preProcessElapsedTime.toString(),
        AppConstants.inferenceTimeKey: inferenceElapsedTime.toString(),
        AppConstants.totalPredictionTimeKey: totalElapsedTime.toString(),
        AppConstants.frameSizeKey: '${image.width} X ${image.height}',
      },
    };
  }

  String _getGuidanceMessage(double boxArea) {
    if (boxArea <AppConstants.minObjectSizeThreshold) return "Move closer";
    else if (boxArea > AppConstants.maxObjectSizeThreshold) return "Move farther";
    else return "Object in position";
  }

  void _captureImage() async{

    if (_isCapturing) return;  // Prevent multiple captures
    _isCapturing = true;       // Lock further captures

    sendPort?.send(_Command(_Codes.capture));

    // Introduce a cooldown period before allowing another capture
    await Future.delayed(const Duration(seconds: 3));

    _isCapturing = false;

  }

  List<List<Object>> _runInference(List<List<List<num>>> imageMatrix) {
    final input = [imageMatrix];
    final output = {
      0: [List<List<num>>.filled(10, List<num>.filled(4, 0))],
      1: [List<num>.filled(10, 0)],
      2: [List<num>.filled(10, 0)],
      3: [0.0],
    };

    _interpreter!.runForMultipleInputs([input], output);
    return output.values.toList();
  }
}