import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../lang/local_keys.dart';
import '../../controllers/selection_controller.dart';

class ResultScreen extends StatelessWidget {
  static String routeName="/result-screen";
  final String? imagePath;
  final String? selectedObject;
 final SelectionController selectionController=Get.find();

  ResultScreen({super.key,  this.imagePath,  this.selectedObject});

  @override
  Widget build(BuildContext context) {
    // Get current date and time
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);

    // Extract object type from the file name (assuming it was saved with object name)


    return PopScope(
        canPop: false,
      onPopInvokedWithResult: (didPop,result)  {
      if (didPop) {
        return; // Exit if the system already handled the pop
      }
      _goToHome();
       // Prevent default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(title:  Text(LocalKeys.detectionResult.tr)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Captured Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(imagePath??"",),
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),

              // Metadata Display
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetadataRow(LocalKeys.objectType.tr, selectedObject??""),
                      _buildMetadataRow(LocalKeys.date.tr, formattedDate),
                      _buildMetadataRow(LocalKeys.time.tr, formattedTime),
                      _buildMetadataRow(LocalKeys.imagePath.tr, imagePath??""),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Back to Home Button
              ElevatedButton.icon(
                onPressed: _goToHome,
                icon: const Icon(Icons.home),
                label:  Text(LocalKeys.backToHome.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  /// Helper widget to build metadata rows
  Widget _buildMetadataRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  /// Force user to go to Home Screen
  void _goToHome() {
// Forces navigation to HomeView and removes previous routes
    Get.back();
    Get.back();

  }
}
