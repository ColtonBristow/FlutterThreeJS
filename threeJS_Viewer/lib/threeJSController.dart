import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:threeJS_Viewer/threeJSModelViewer.dart';

class ThreeJSController {
  WebViewController? webController;
  bool? debug;

  ThreeJSController({
    required this.webController,
  });

  void setupScene(bool debug) {
    webController?.runJavascript('window.setupScene($debug)');
  }

  void loadModels(List<ThreeModel> models) async {
    for (var model in models) {
      if (kDebugMode) {
        log("trying to load the following model: ${model.src}");
      }
      webController
          ?.runJavascript('globalThis.loadModel(\'${model.src}\', ${model.playAnimation})');
    }
  }

  void createCamera(PerspectiveCameraConfig camera) {
    if (kDebugMode) {
      log('trying to create a camera with the following properties: ${camera.toString()}');
    }

    //TODO: make multiple camera configs and the option to add multiple cameras for transitions
    webController?.runJavascript('globalThis.createPerspectiveCamera($camera)');
  }

  void createOrbitControls(OrbitControls oc) {
    if (kDebugMode) {
      log('trying to add the following controls ${oc.toString()}');
    }

    webController?.runJavascript('globalThis.setOrbitControls(${oc.toString()})');
  }

  void addAmbientLight(String color, int intensity) {
    webController?.runJavascript('globalThis.addAmbientLight(\'$color\', $intensity)');
  }

  void addDirectionalLight(DirectionalLight light) {
    webController?.runJavascript('globalThis.addDirectionalLight(${light.toString(map: true)})');
  }
}
