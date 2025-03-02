import 'package:Hasssan_Hallak_live_object/controllers/selection_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../constants/app_constants.dart';
import '../../lang/local_keys.dart';
import '../../models/screen_params.dart';
import '../scan_screen/scan_screen.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenParams.screenSize = MediaQuery.sizeOf(context);
    final SelectionController controller = Get.find();

    // List of selectable objects


    return Scaffold(
      appBar: AppBar(
        title: Text(LocalKeys.selectObject.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             Text(LocalKeys.chooseObject.tr ,style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            // Buttons to select objects
            ...AppConstants.availableObjects.map((object) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Obx(() => ElevatedButton(
                onPressed: () {
                  controller.selectObject(object);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.selectedObject.value == object ? Colors.blue : Colors.grey[300],
                ),
                child: Text(object.tr, style: const TextStyle(fontSize: 16)),
              )),
            )),

            const SizedBox(height: 20),

            // Get Started button
            ElevatedButton(
              onPressed:  () {
               if( controller.selectedObject.value.isNotEmpty) {
                 Get.toNamed(ScanPage.routeName);
               }
              } ,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child:  Text(LocalKeys.getStarted.tr, style: const TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
