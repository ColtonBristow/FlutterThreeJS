import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:threeJS_Viewer/threeJSModelViewer.dart';

//! TODO: Make all javascript methods return results to improve debug quality in flutter

class ThreeJSController {
  WebViewController? webController;
  bool? debug;

  ThreeJSController({
    required this.webController,
  });

  Future<void> setupScene(bool debug) async {
    return webController?.runJavascript('window.setupScene($debug)');
  }

  Future<void> loadModels(List<ThreeModel> models, double scale) async {
    for (var model in models) {
      if (kDebugMode) {
        log("trying to load the following model: ${model.src}");
      }

      await webController?.runJavascript('window.loadModel(\'${model.src}\', ${model.playAnimation}, ${scale})');
    }
  }

  Future<void> createCamera(PerspectiveCameraConfig camera) async {
    if (kDebugMode) {
      log('trying to create a camera with the following properties: ${camera.toString()}');
    }

    //TODO: make multiple camera configs and the option to add multiple cameras for transitions
    await webController?.runJavascript('window.createPerspectiveCamera($camera)');
  }

  Future<void> createOrbitControls(OrbitControls oc) async {
    if (kDebugMode) {
      log('trying to add the following controls ${oc.toString()}');
    }

    await webController?.runJavascript('window.setOrbitControls(${oc.toString()})');
  }

  Future<void> addAmbientLight(String color, int intensity) async {
    await webController?.runJavascript('window.addAmbientLight(\'$color\', $intensity)');
  }

  Future<void> addDirectionalLight(DirectionalLight light) async {
    await webController?.runJavascript('window.addDirectionalLight(${light.toString(map: true)})');
  }

  void resetCameraControls(bool autoRotate) {
    webController?.runJavascript('window.resetCameraControls(${autoRotate})');
  }

  void tweenCamera(double targetX, double targetY, double targetZ, double duration, bool autoRotate) {
    webController?.runJavascript('window.tweenCamera(${targetX}, ${targetY}, ${targetZ}, ${duration})');
    if (Platform.isIOS) resetCameraControls(autoRotate);
  }
}
