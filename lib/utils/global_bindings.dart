import 'package:Hasssan_Hallak_live_object/controllers/scan_controller.dart';
import 'package:Hasssan_Hallak_live_object/controllers/selection_controller.dart';
import 'package:get/get.dart';



class GlobalBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(()=>SelectionController(),fenix: true);
    Get.lazyPut(()=>ScanController());


  }

}