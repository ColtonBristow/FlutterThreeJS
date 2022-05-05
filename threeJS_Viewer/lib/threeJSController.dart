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
      webController?.runJavascript('window.loadModel(\'${model.src}\', ${model.playAnimation})').then((value) => value);

      if (kDebugMode) {
        log("loaded model: ${model.src}");
      }
    }
  }

  void createCamera(PerspectiveCameraConfig camera) {
    //TODO: make multiple camera configs and the option to add multiple cameras for transitions
    webController?.runJavascript('window.createPerspectiveCamera($camera)');
  }

  void createOrbitControls(OrbitControls oc) {
    webController?.runJavascript('window.setOrbitControls(${oc.toString()})');

    if (kDebugMode) {
      log('adding the following controls ${oc.toString()}');
    }
  }
}
