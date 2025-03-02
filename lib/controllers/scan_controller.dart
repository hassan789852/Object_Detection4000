import 'dart:async';

import 'package:Hasssan_Hallak_live_object/ui/result_screen/result_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../constants/app_constants.dart';
import '../models/recognition.dart';
import '../models/screen_params.dart';
import '../service/detector_service.dart';

class ScanController extends GetxController {


  String? selectedObject;

   CameraController? cameraController;
  late List<CameraDescription> cameras;
  Detector? detector;






  bool isCameraInitialized = false;




  StreamSubscription<Map<String, dynamic>>? subscription;

  final RxList<Recognition> results = <Recognition>[].obs;
  final RxMap<String, String> stats = <String, String>{}.obs;

  int frameCounter = 0; // Used to limit FPS processing

  Future<void> initializeCamera({required String selectObject}) async {
    this.selectedObject=selectObject;
    try {
      debugPrint("Initializing camera...");
      cameras = await availableCameras();

      if (cameras.isEmpty) {
        debugPrint("No cameras found!");
        return;
      }

      debugPrint("Found ${cameras.length} cameras. Using first one.");

      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await    cameraController!.initialize();

      // await   Future.delayed(Duration(seconds: 1));

      if (!cameraController!.value.isInitialized) {
        debugPrint("globalCameraController failed to initialize!");
        return;
      }

      debugPrint("Camera initialized successfully! Starting image stream...");

      await cameraController?.startImageStream(onLatestImageAvailable);

      if(cameraController!=null) {
        ScreenParams.previewSize =cameraController!.value.previewSize!;
      }


      debugPrint("Camera setup complete. Preview size: ${ScreenParams.previewSize}");
      update();
    } catch (e) {
      debugPrint("Camera initialization failed: $e");
      update();
    }
  }

  void startDetector() {
     detector=Detector(
        selectedObject:selectedObject,
        cameraController:cameraController);
// Prevent multiple initializations

     detector!.start(selectedObject: selectedObject??"",).then((instance) {
      detector = instance;
      _subscribeToDetectorStream();
      update();
    }).catchError((error) {
      debugPrint("Error initializing detector: $error");
    });
  }

  void _subscribeToDetectorStream() {


    subscription = detector!.resultsStream.stream.listen((values) async {
      results.assignAll(values[AppConstants.recognitions] ?? []);
      stats.assignAll(values[AppConstants.stats] ?? {});

      if (values.containsKey(AppConstants.capture)) {
        await _handleCaptureEvent(values[AppConstants.capture]);
      }
    });

    update();
  }

  Future<void> _handleCaptureEvent(String imagePath) async {
    debugPrint("Captured image: $imagePath");

    // Stop streaming to prevent further detections during navigation
    await stopStreaming();

    // Navigate to the Result Screen
    Get.to(() => ResultScreen(imagePath: imagePath, selectedObject: selectedObject))
        ?.then((_) async {
      // Reinitialize camera after returning from results
      await initializeCamera(selectObject: selectedObject??"");
    });
  }



  void onLatestImageAvailable(CameraImage cameraImage) async {

    frameCounter ++;
    if(frameCounter%5==0){
      frameCounter=0;

      detector?.processFrame(cameraImage);
    }

  }

  Future<void> stopStreaming() async{
    cameraController?.stopImageStream();
    detector?.stop();
  }





}




