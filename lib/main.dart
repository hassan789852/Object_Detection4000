/*
 * Copyright 2023 The TensorFlow Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *             http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:Hasssan_Hallak_live_object/ui/result_screen/result_screen.dart';
import 'package:Hasssan_Hallak_live_object/ui/scan_screen/scan_screen.dart';
import 'package:Hasssan_Hallak_live_object/ui/selection_screen/selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


import 'constants/app_constants.dart';
import 'utils/global_bindings.dart';
import 'lang/translation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Load translations before running the app
  await TranslationService.loadTranslations();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: TranslationService(),
      locale: TranslationService.locale,
      fallbackLocale: TranslationService.fallbackLocale,
      title: AppConstants.title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      initialBinding: GlobalBindings(),
      getPages: [
        GetPage(name: '/', page: () => const SelectionScreen()),
        GetPage(name: ScanPage.routeName, page: () =>  const ScanPage()),
        GetPage(name: ResultScreen.routeName, page: () =>  ResultScreen()),
      ],
    );

  }
}
