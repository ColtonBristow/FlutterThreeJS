import 'dart:async';
import 'dart:developer';
import 'dart:io' show InternetAddress, Platform;

import 'package:flutter/material.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:threeJS_Viewer/threeJSController.dart';
import 'package:threeJS_Viewer/threeJSModelViewer.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class ThreeJSViewer extends StatefulWidget {
  final List<ThreeModel> models;
  final Function(ThreeJSController controller) onPageLoaded;
  final PerspectiveCameraConfig cameraConfig;
  final Duration loaderDuration;
  final Function(bool ready)? onServerReady;
  final Function(double? percentage)? onObjectLoading;
  final Function()? onObjectLoaded;
  final Function(Object error)? onError;
  final Widget? showWhenLoading;
  WebViewController? controller;

  ThreeJSViewer({
    Key? key,
    required this.models,
    required this.onPageLoaded,
    required this.cameraConfig,
    this.controller,
    this.onServerReady,
    this.onError,
    this.onObjectLoaded,
    this.onObjectLoading,
    this.showWhenLoading,
    this.loaderDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  _ThreeJSViewerState createState() => _ThreeJSViewerState();
}

class _ThreeJSViewerState extends State<ThreeJSViewer> {
  bool isListening = false;
  bool isReady = false;
  String? address;
  int? port;
  bool hasError = false;

  Set<JavascriptChannel> channels = {};

  Future<String?>? setupScene() {
    if (hasError) {
      log('error setting up scene');
      return null;
    }

    return widget.controller?.runJavascriptReturningResult('setupScene()');
  }

  void loadModels() {
    if (hasError) return;
    for (var model in widget.models) {
      widget.controller?.runJavascript('window.loadModel(\'${model.src}\', ${model.playAnimation})');
    }
  }

  Future<String?>? createCamera(PerspectiveCameraConfig cameraConfig) {
    if (hasError) return null;
    return widget.controller?.runJavascriptReturningResult('window.createPerspectiveCamera($cameraConfig)');
  }

  void createOrbitControls() {
    if (hasError) return;
    widget.controller?.runJavascript('window.createOrbitControls(undefined)');
  }

  void setBackgroundColor(String color, double alpha) {
    if (hasError) return;
    widget.controller?.runJavascript('window.setBackgroundColor(\'$color\', $alpha)');
  }

  void setCameraPosition(Vector3 pos) {
    if (hasError) return;
    widget.controller?.runJavascript('window.setCameraPosition($pos)');
  }

  void setCameraRotation(Vector3 pos) {
    if (hasError) return;
    widget.controller?.runJavascript('window.setCameraRotation($pos)');
  }

  void setOrbitControls(OrbitControls orbitControls) {
    if (hasError) return;
    widget.controller?.runJavascript('window.setOrbitControls($orbitControls)');
  }

  void addAmbientLight(String color, int intensity) {
    if (hasError) return;
    widget.controller?.runJavascript('window.addAmbientLight(\'$color\', $intensity)');
  }

  void addDirectionalLight(DirectionalLight light) {
    if (hasError) return;
    widget.controller?.runJavascript('window.addDirectionalLight(${light.toString(map: true)})');
  }

  void setControlsTarget(Vector3 pos) {
    if (hasError) return;
    widget.controller?.runJavascript('window.setControlsTarget($pos)');
  }

  void enableZoom(bool enable) {
    if (hasError) return;
    widget.controller?.runJavascript('window.enableZoom($enable)');
  }

  void setStats(bool enable) {
    if (hasError) return;
    widget.controller?.runJavascript('window.setStats($enable)');
  }

  void _onObjectLoaded() {
    if (widget.onObjectLoaded != null) widget.onObjectLoaded!();
    Timer(widget.loaderDuration, () {
      setState(() {
        isReady = true;
      });
    });
  }

  void tweenCamera(Vector3 vector) {
    widget.controller?.runJavascript("tweenCamera(${vector.toString()})");
  }

  void _onPageFinishedLoading(_) async {
    await Future.delayed(const Duration(milliseconds: 100));
    await setupScene();
    await createCamera(widget.cameraConfig);
    createOrbitControls();
    loadModels();
    widget.onPageLoaded(
      ThreeJSController(
        tweenCamera: tweenCamera,
        setBackgroundColor: setBackgroundColor,
        addAmbientLight: addAmbientLight,
        setCameraPosition: setCameraPosition,
        setCameraRotation: setCameraRotation,
        addDirectionalLight: addDirectionalLight,
        enableZoom: enableZoom,
        setControlsTarget: setControlsTarget,
        setOrbitControls: setOrbitControls,
        setStats: setStats,
      ),
    );
  }

  @override
  initState() {
    if (Platform.isAndroid) WebView.platform = AndroidWebView();

    _initChannels();
    _initServer();
    super.initState();
  }

  _initChannels() {
    channels = {
      JavascriptChannel(
          name: 'OnObjectLoading',
          onMessageReceived: (message) {
            double? value = double.tryParse(message.message);
            if (widget.onObjectLoading != null) widget.onObjectLoading!(value);
            if (value == 100) {
              _onObjectLoaded();
            }
          }),
      JavascriptChannel(
          name: 'Print',
          onMessageReceived: (message) {
            log(message.message);
          })
    };
  }

  _initServer() async {
    if (widget.onServerReady != null) widget.onServerReady!(false);
    final server = LocalAssetsServer(
      port: 4000,
      address: InternetAddress.loopbackIPv4,
      assetsBasePath: 'packages/threeJS_Viewer/web',
      logger: const DebugLogger(),
    );

    final address = await server.serve();

    setState(() {
      this.address = address.address;
      port = server.boundPort!;
      isListening = true;
    });
    if (widget.onServerReady != null) widget.onServerReady!(true);
  }

  @override
  Widget build(BuildContext context) {
    log('now listening on http://$address:$port');
    return isListening
        ? Stack(
            children: [
              if (!isReady) widget.showWhenLoading ?? const SizedBox(),
              WebView(
                debuggingEnabled: true,
                backgroundColor: Colors.transparent,
                initialUrl: 'http://$address:$port',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (c) {
                  widget.controller = c;
                },
                onPageFinished: _onPageFinishedLoading,
                javascriptChannels: channels,
                onWebResourceError: (error) {
                  hasError = true;
                  if (widget.onError != null) {
                    widget.onError!(error.description);
                  }
                },
              ),
            ],
          )
        : const SizedBox();
  }
}
