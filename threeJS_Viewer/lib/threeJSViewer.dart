// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:developer';
import 'dart:io' show InternetAddress, Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:threeJS_Viewer/threeJSController.dart';
import 'package:threeJS_Viewer/threeJSModelViewer.dart';

// ignore: must_be_immutable
class ThreeJSViewer extends StatefulWidget {
  Function? onPageFinishedLoading;
  Function(WebResourceError error)? onError;
  PerspectiveCameraConfig? cameraConfig;
  LocalAssetsServer? addressServer;
  OrbitControls? orbitControls;
  void Function(JavascriptMessage)? javasciptErroronMessageReceived;
  int? port;
  bool? debug;
  List<ThreeModel> models;
  Completer<WebViewController>? controllerCompleter;
  Function(ThreeJSController)? onWebViewCreated;
  Function(double)? onLoadProgress;

  ThreeJSViewer({
    Key? key,
    this.javasciptErroronMessageReceived,
    this.port,
    this.orbitControls,
    this.onPageFinishedLoading,
    this.onError,
    this.cameraConfig,
    this.addressServer,
    this.debug,
    required this.models,
    this.controllerCompleter,
    this.onWebViewCreated,
    this.onLoadProgress,
  }) : super(key: key);

  @override
  _ThreeJSViewerState createState() => _ThreeJSViewerState();
}

class _ThreeJSViewerState extends State<ThreeJSViewer> {
  ThreeJSController controller = ThreeJSController(webController: null);
  double loadingProgress = 0;
  Set<JavascriptChannel> channels = {};
  Future<InternetAddress>? server;
  final LocalAssetsServer las = LocalAssetsServer(
    port: 8080,
    address: InternetAddress.loopbackIPv4,
    assetsBasePath: 'packages/threeJS_Viewer/web',
    logger: const DebugLogger(),
  );

  Future<InternetAddress>? initServer() async {
    print("initServer() run");
    if (widget.addressServer == null) {
      if (kDebugMode == true) print("widget.addressServer == null");

      return await las.serve();
    } else {
      if (kDebugMode == true) print("widget.addressServer != null");

      return await widget.addressServer!.serve();
    }
  }

  @override
  initState() {
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
    super.initState();
  }

  @override
  dispose() {
    // TODO: implement dispose
    super.dispose();
    las.stop();
    if (widget.addressServer != null) widget.addressServer!.stop();
  }

  @override
  Widget build(BuildContext context) {
    server ??= initServer();
    channels = {
      JavascriptChannel(
        name: "Print",
        onMessageReceived: (JavascriptMessage message) {
          if (widget.debug ?? false) {
            log("Print from js: ${message.message}");
          }
        },
      ),
      JavascriptChannel(
        name: "Error",
        onMessageReceived: widget.javasciptErroronMessageReceived ??= (JavascriptMessage message) {
          log("Error from js: ${message.message}");
        },
      ),
      JavascriptChannel(
        name: "ModelLoading",
        onMessageReceived: (JavascriptMessage message) {
          // Use this for loading values
          if (widget.debug ?? false) {
            log("${message.message}% model loaded");
          }
          //!
          //if (widget.onLoadProgress != null) widget.onLoadProgress!(double.tryParse(message.message)!);
        },
      ),
      JavascriptChannel(
        name: "CameraLoading",
        onMessageReceived: (JavascriptMessage message) {
          log("${message.message}% camera loaded");
        },
      ),
    };

    return FutureBuilder(
      future: server,
      builder: (context, snapshot) {
        if (snapshot.hasData == false) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          InternetAddress address = snapshot.data as InternetAddress;
          log('started local server http://${address.address}:${widget.port ?? 8080}');
          return WebView(
            allowsInlineMediaPlayback: true,
            // ignore: prefer_collection_literals
            gestureRecognizers: [
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            ].toSet(),
            debuggingEnabled: true,
            backgroundColor: Colors.transparent,
            initialUrl: 'http://${address.address}:${widget.port ?? 8080}',
            javascriptMode: JavascriptMode.unrestricted,
            onProgress: (int progress) {
              if (widget.onLoadProgress != null) widget.onLoadProgress!(progress / 1.0);
            },
            onWebViewCreated: (c) {
              widget.controllerCompleter?.complete(c);

              if (kDebugMode) log("controller initilized");
              controller = ThreeJSController(webController: c);

              if (widget.onWebViewCreated != null) widget.onWebViewCreated!(controller);
            },
            onPageFinished: (details) async {
              if (controller.webController == null && kDebugMode) {
                log('widget TJScontroller:  ${controller.toString()} \n widget WVController: + ${controller.webController.toString()}');
              }
              if (kDebugMode) {
                log("calling js");
              }

              //! TODO: Fix this ish related to javascript not compiling in time
              await Future.delayed(Duration(milliseconds: 500), () {
                controller.setupScene(widget.debug ?? false);

                controller.createCamera(widget.cameraConfig ?? PerspectiveCameraConfig(fov: 75, aspectRatio: null, far: 10000, near: 0.1));
                controller.createOrbitControls(
                  widget.orbitControls ??
                      OrbitControls(
                        minDistance: 3,
                        maxDistance: 500,
                        autoRotateSpeed: 2.5,
                      ),
                );
                controller.loadModels(widget.models);
                //Future<String?> error = widget.controller.loadModels(widget.models);
                controller.addAmbientLight('0xff0000', 1);
                widget.onPageFinishedLoading;
              });
            },
            javascriptChannels: channels,
            onWebResourceError: (error) {
              widget.onError ??
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      // ignore: avoid_unnecessary_containers
                      content: Container(
                        child: Text("$error"),
                      ),
                    ),
                  );
            },
          );
        }
      },
    );
  }
}
