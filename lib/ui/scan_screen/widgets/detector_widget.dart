import 'dart:async';
import 'package:Hasssan_Hallak_live_object/ui/scan_screen/widgets/stats_widget.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../lang/local_keys.dart';
import '../../../controllers/scan_controller.dart';
import 'box_widget.dart';


class DetectorWidget extends StatefulWidget {


  final String selectedObject;


  const DetectorWidget({super.key, required this.selectedObject});

  @override
  State<DetectorWidget> createState() => _DetectorWidgetState();
}

class _DetectorWidgetState extends State<DetectorWidget>
    with WidgetsBindingObserver {
  // late List<CameraDescription> cameras;

  final ScanController controller = Get.put(ScanController());



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStateAsync();
  }

  void _initStateAsync() async {

    await controller.initializeCamera(selectObject: widget.selectedObject);
     controller.startDetector();

  }






  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScanController>(
      builder: (controller) {
        if (controller.cameraController == null || !controller.cameraController!.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        var aspect = 1 / controller.cameraController!.value.aspectRatio;

        return Stack(
          children: [
            AspectRatio(
              aspectRatio: aspect,
              child: CameraPreview(controller.cameraController!),
            ),
            _statsWidget(),
            AspectRatio(
              aspectRatio: aspect,
              child: _boundingBoxes(),
            ),
          ],
        );
      },
    );
  }


  // Widget _statsWidget() => (stats != null)
  //     ? Align(
  //   alignment: Alignment.bottomCenter,
  //   child: Container(
  //     color: Colors.white.withAlpha(150),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: stats!.entries
  //             .map((e) => StatsWidget(e.key, e.value))
  //             .toList(),
  //       ),
  //     ),
  //   ),
  // )
  //     : const SizedBox.shrink();


  Widget _statsWidget() {
    return Obx(() {
      if (controller.stats.isEmpty) return const SizedBox.shrink();

      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Colors.white.withAlpha(150),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: controller.stats.entries
                  .map((e) => StatsWidget(e.key, e.value))
                  .toList(),
            ),
          ),
        ),
      );
    });
  }

  //
  // Widget _boundingBoxes() {
  //   if (results == null || results!.isEmpty) {
  //     return Center(
  //       child: Text(
  //         "${LocalKeys.detecting.tr} ${widget.selectedObject}...",
  //         style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
  //       ),
  //     );
  //   }
  //   return Stack(
  //     children: results!
  //         .map((box) => BoxWidget(result: box, selectedObject: widget.selectedObject))
  //         .toList(),
  //   );
  // }


  Widget _boundingBoxes() {
    return Obx(() {
      if (controller.results.isEmpty) {
        return Center(
          child: Text(
            "${LocalKeys.detecting.tr} ${widget.selectedObject}...",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      }

      return Stack(
        children: controller.results
            .map((box) => BoxWidget(result: box, selectedObject: widget.selectedObject))
            .toList(),
      );
    });
  }





  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
    controller.cameraController?.stopImageStream();
        controller.detector?.stop();
        controller.subscription?.cancel();
        break;
      case AppLifecycleState.resumed:
        _initStateAsync();
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.cameraController?.dispose();
    controller.detector?.stop();
    controller.subscription?.cancel();
    super.dispose();
  }
}