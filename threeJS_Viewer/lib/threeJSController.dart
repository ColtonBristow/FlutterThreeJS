import 'package:threeJS_Viewer/threeJSModelViewer.dart';

class ThreeJSController {
  Function(String color, double alpha) setBackgroundColor;
  Function(Vector3 pos) setCameraPosition;
  Function(Vector3 pos) setCameraRotation;
  Function(String color, int intensity) addAmbientLight;
  Function(DirectionalLight light) addDirectionalLight;
  Function(bool enable) enableZoom;
  Function(Vector3 pos) setControlsTarget;
  Function(OrbitControls orbitControls) setOrbitControls;
  Function(bool enable) setStats;
  Function(Vector3 vector) tweenCamera;

  ThreeJSController({
    required this.tweenCamera,
    required this.setBackgroundColor,
    required this.addAmbientLight,
    required this.setCameraPosition,
    required this.setCameraRotation,
    required this.addDirectionalLight,
    required this.enableZoom,
    required this.setControlsTarget,
    required this.setOrbitControls,
    required this.setStats,
  });
}
