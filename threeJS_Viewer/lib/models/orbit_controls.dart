import 'package:threeJS_Viewer/utils/translate_number.dart';

class OrbitControls {
  double? minPolarAngle;
  double? maxPolarAngle;
  double? minAzimuthAngle;
  double? maxAzimuthAngle;
  double? autoRotateSpeed;
  int? minDistance;
  int? maxDistance;
  bool? enablePan;
  bool? enableZoom;

  OrbitControls({
    this.autoRotateSpeed,
    this.minDistance,
    this.maxDistance,
    this.enablePan,
    this.enableZoom,
    this.minPolarAngle = -double.infinity,
    this.maxPolarAngle = double.infinity,
    this.minAzimuthAngle = -double.infinity,
    this.maxAzimuthAngle = double.infinity,
  });

  @override
  String toString() {
    return '${translateNumber(minPolarAngle, [double.infinity, -double.infinity])}, ${translateNumber(maxPolarAngle, [
          double.infinity,
          -double.infinity
        ])}, ${translateNumber(minAzimuthAngle, [double.infinity, -double.infinity])}, ${translateNumber(maxAzimuthAngle, [
          double.infinity,
          -double.infinity
        ])}, $minDistance, $maxDistance, $enablePan, $autoRotateSpeed, ${autoRotateSpeed == null ? false : true}, $enableZoom';
  }
}
