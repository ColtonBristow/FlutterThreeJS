// ignore_for_file: avoid_print, file_names
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:threeJS_Viewer/threeJSController.dart';
import 'package:threeJS_Viewer/threeJSModelViewer.dart';

// ignore: must_be_immutable
class ThreeJSViewer extends StatefulWidget {
  bool debug;
  List<ThreeModel> models;
  Function(ThreeJSController)? onWebViewCreated;
  Widget Function(double?, String)? progressBuilder;
  final double scale;
  final Function(String message, int code) onError;

  ThreeJSViewer({
    Key? key,
    this.debug = false,
    required this.models,
    this.onWebViewCreated,
    this.progressBuilder,
    required this.scale,
    required this.onError,
  }) : super(key: key);

  @override
  State<ThreeJSViewer> createState() => _ThreeJSViewerState();
}

class _ThreeJSViewerState extends State<ThreeJSViewer> {
  ThreeJSController controller = ThreeJSController(webController: null);
  double? modelProgress;
  String loadMessage = "Initializing Server...";
  final InAppLocalhostServer localhostServer = InAppLocalhostServer(documentRoot: 'packages/threeJS_Viewer/web', port: 8080);

  Future<void> initServer() async {
    if (!localhostServer.isRunning()) await localhostServer.start();
  }

  @override
  void dispose() {
    super.dispose();
    if (localhostServer.isRunning()) localhostServer.close();
  }

  @override
  Widget build(BuildContext context) {
    initServer();
    return Stack(
      children: [
        InAppWebView(
          initialOptions:
              InAppWebViewGroupOptions(crossPlatform: InAppWebViewOptions(cacheEnabled: false, clearCache: true, transparentBackground: true)),
          onConsoleMessage: (controller, consoleMessage) => print("Message from Javascript: $consoleMessage"),
          initialUrlRequest: URLRequest(url: Uri.parse('http://localhost:8080/index.html')),
          onWebViewCreated: (c) {
            controller = ThreeJSController(webController: c);
            if (widget.onWebViewCreated != null) widget.onWebViewCreated!(controller);
            /* controller.webController?.addJavaScriptHandler(
                handlerName: 'Error',
                callback: (args) {
                  log("Javascript Error Handler: ${args[0]}");
                }); */

            controller.webController?.addJavaScriptHandler(
                handlerName: 'ModelLoading',
                callback: (args) {
                  //log('Model Loading Handler: ${args[0] * 1.0}');
                  setState(() {
                    loadMessage = "Loading Model...";
                    modelProgress = args[0] * 1.0;
                  });
                });
            /* controller.webController?.addJavaScriptHandler(
                handlerName: 'CameraLoading',
                callback: (args) {
                  log("Camera Loading Handler: ${args[0]}");
                }); */
          },
          onLoadStop: (c, url) async {
            if (controller.webController == null && kDebugMode) {
              log('widget TJScontroller:  ${controller.toString()} \n widget WVController: + ${controller.webController.toString()}');
            }
            if (kDebugMode) {
              log("calling js");
            }

            controller.setupScene(widget.debug);

            controller.createCamera(PerspectiveCameraConfig(fov: 75, aspectRatio: null, far: 10000, near: 0.1));
            controller.createOrbitControls(
              OrbitControls(
                minDistance: 0,
                maxDistance: 500,
                autoRotateSpeed: 2.5,
              ),
            );
            controller.loadModels(widget.models, widget.scale);
            controller.addAmbientLight('0xff0000', 4);
          },
          onLoadError: (controller, url, code, message) {
            widget.onError(message, code);
          },
          onLoadHttpError: (controller, url, statusCode, description) {
            widget.onError(description, statusCode);
          },
        ),
        if (modelProgress != 100.0 && widget.progressBuilder != null)
          widget.progressBuilder!(
            modelProgress == null ? null : (modelProgress! / 100.0),
            loadMessage,
          )
      ],
    );
  }
}
