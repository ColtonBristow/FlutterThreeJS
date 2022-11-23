// ignore_for_file: file_names

import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:threeJS_Viewer/threeJSModelViewer.dart';

class ThreeJSController {
  InAppWebViewController? webController;
  bool? debug;

  ThreeJSController({
    required this.webController,
  });

  Future<void> setupScene(bool debug) async {
    return webController?.evaluateJavascript(source: 'window.setupScene($debug)');
  }

  Future<void> loadModels(List<ThreeModel> models, double scale) async {
    for (var model in models) {
      if (kDebugMode) {
        log("trying to load the following model: ${model.src}");
      }

      await webController?.evaluateJavascript(source: 'window.loadModel(\'${model.src}\', ${model.playAnimation}, $scale)');
    }
  }

  Future<void> createCamera(PerspectiveCameraConfig camera) async {
    if (kDebugMode) {
      log('trying to create a camera with the following properties: ${camera.toString()}');
    }

    await webController?.evaluateJavascript(source: 'window.createPerspectiveCamera($camera)');
  }

  Future<void> createOrbitControls(OrbitControls oc) async {
    if (kDebugMode) {
      log('trying to add the following controls ${oc.toString()}');
    }

    await webController?.evaluateJavascript(source: 'window.setOrbitControls(${oc.toString()})');
  }

  Future<void> addAmbientLight(String color, int intensity) async {
    await webController?.evaluateJavascript(source: 'window.addAmbientLight(\'$color\', $intensity)');
  }

  Future<void> addDirectionalLight(DirectionalLight light) async {
    await webController?.evaluateJavascript(source: 'window.addDirectionalLight(${light.toString(map: true)})');
  }

  void resetCameraControls(bool autoRotate, {double? yOffset}) {
    webController?.evaluateJavascript(source: 'window.resetCameraControls($autoRotate, $yOffset)');
  }

  void tweenCamera(double targetX, double targetY, double targetZ, double duration, bool autoRotate, {double? yOffset}) async {
    await webController?.evaluateJavascript(source: 'window.tweenCamera($targetX, $targetY, $targetZ, $duration, $yOffset)');
    if (Platform.isIOS) resetCameraControls(autoRotate, yOffset: yOffset);
  }
}
