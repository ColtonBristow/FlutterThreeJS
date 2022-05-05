import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:threeJS_Viewer/threeJSModelViewer.dart';

class ThreeLight {
  final Light type;
  final Vector3 position;
  final String colorRGB;
  final double distance;
  final double intensity;
  final double decay;

  ThreeLight({
    required this.type,
    required this.intensity,
    required this.decay,
    required this.position,
    required this.colorRGB,
    required this.distance,
  }) {
    if (kDebugMode) {
      log('created a light with the following properties: $this');
    }
  }

  @override
  String toString() {
    return '$type ,$position, $colorRGB, $distance, $intensity, $decay';
  }
}

//====== Lights ========//
// Lights are often an after thought, but lighting can really be the most important aspect of your scene.
//Three.js has a variety of built in lights to apply to materials like MeshLambertMaterial and MeshPhongMaterial.
// These lights effect the materials in different ways depending on the type of light and their properties as well
//as the properties of the materials themselves.
enum Light {
  ambientLight,
  directionalLight,
  hemisphereLight,
  pointLight,
  spotLight,
}
