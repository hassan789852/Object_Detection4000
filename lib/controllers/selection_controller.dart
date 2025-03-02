import 'package:get/get.dart';

class SelectionController extends GetxController {
  var selectedObject = "".obs;

  void selectObject(String object) {
    selectedObject.value = object;
  }
}