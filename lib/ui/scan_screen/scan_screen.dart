import 'package:Hasssan_Hallak_live_object/ui/scan_screen/widgets/detector_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../models/screen_params.dart';
import '../../controllers/selection_controller.dart';

/// [ScanPage] stacks [DetectorWidget]
class ScanPage extends StatefulWidget {
  static String routeName="/scan-page";
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  SelectionController selectionController=Get.find();
  @override
  Widget build(BuildContext context) {
    ScreenParams.screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      key: GlobalKey(),
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Hassan Hallak Task"),
      ),
      body:Obx((){
        return DetectorWidget(selectedObject: selectionController.selectedObject.value);
      })


    );
  }
}
