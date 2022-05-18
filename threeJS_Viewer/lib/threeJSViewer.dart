import 'dart:async';
import 'dart:developer';
import 'dart:io' show InternetAddress, Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:threeJS_Viewer/threeJSController.dart';
import 'package:threeJS_Viewer/threeJSModelViewer.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class ThreeJSViewer extends StatefulWidget {
  ThreeJSController controller;
  Function? onPageFinishedLoading;
  Iterable<JavascriptChannel>? channels;
  Function(WebResourceError error)? onError;
  PerspectiveCameraConfig? cameraConfig;
  LocalAssetsServer? addressServer;
  OrbitControls? orbitControls;
  bool? debug;
  List<ThreeModel> models;
  Completer<WebViewController>? controllerCompleter;

  ThreeJSViewer({
    Key? key,
    required this.controller,
    this.orbitControls,
    this.onPageFinishedLoading,
    this.channels,
    this.onError,
    this.cameraConfig,
    this.addressServer,
    this.debug,
    required this.models,
    this.controllerCompleter,
  }) : super(key: key);

  @override
  _ThreeJSViewerState createState() => _ThreeJSViewerState();
}

class _ThreeJSViewerState extends State<ThreeJSViewer> {
  double loadingProgress = 0;
  int port = 4000;
  Set<JavascriptChannel> channels = {};
  Future<InternetAddress>? server;

  initServer() async {
    if (widget.addressServer == null) {
      final las = LocalAssetsServer(
        port: 4000,
        address: InternetAddress.loopbackIPv4,
        assetsBasePath: 'packages/threeJS_Viewer/web',
        logger: const DebugLogger(),
      );

      server = las.serve();
    } else {
      server = widget.addressServer?.serve();
    }
  }

  initChannels() {
    channels = {
      JavascriptChannel(
        name: "Print",
        onMessageReceived: (JavascriptMessage message) {
          log("from js: ${message.message}");
        },
      ),
      JavascriptChannel(
        name: "Debug",
        onMessageReceived: (JavascriptMessage message) {
          log("from three js: ${message.message}");
        },
      ),
      JavascriptChannel(
        name: "PostMessage",
        onMessageReceived: (JavascriptMessage message) {
          log("from three js: ${message.message}");
        },
      )
    };
  }

  @override
  initState() {
    if (Platform.isAndroid) WebView.platform = AndroidWebView();

    initServer();
    initChannels();
    super.initState();
  }

  @override
  dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: server,
      builder: (context, snapshot) {
        if (snapshot.hasData == false) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          InternetAddress address = snapshot.data as InternetAddress;
          log('started local server http://${address.address}:$port');
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
            initialUrl: 'http://${address.address}:$port',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (c) {
              widget.controllerCompleter?.complete(c);
              widget.controller = ThreeJSController(webController: c);
            },
            onPageFinished: (details) {
              if (widget.controller.webController == null && kDebugMode) {
                log('widget TJScontroller:  ${widget.controller.toString()} \n widget WVController: + ${widget.controller.webController.toString()}');
              }
              if (kDebugMode) {
                log("calling js");
              }

              Future.delayed(const Duration(milliseconds: 200), () {
                widget.controller.setupScene(widget.debug ?? false);
                widget.controller.createCamera(widget.cameraConfig ?? PerspectiveCameraConfig(fov: 75, aspectRatio: null, far: 10000, near: 0.1));
                widget.controller.createOrbitControls(
                  widget.orbitControls ??
                      OrbitControls(
                        minDistance: 3,
                        maxDistance: 500,
                        autoRotateSpeed: 2.5,
                      ),
                );
                widget.controller.loadModels(widget.models);
                widget.controller.addAmbientLight('0xff0000', 1);
                widget.onPageFinishedLoading;
              });
            },
            javascriptChannels: channels,
            onWebResourceError: (error) {
              widget.onError ?? () {};
            },
          );
        }
      },
    );
  }
}

class PlatformViewVerticalGestureRecognizer extends VerticalDragGestureRecognizer {
  PlatformViewVerticalGestureRecognizer({
    Object? debugOwner,
    @Deprecated(
      'Migrate to supportedDevices. '
      'This feature was deprecated after v2.3.0-1.0.pre.',
    )
        PointerDeviceKind? kind,
    Set<PointerDeviceKind>? supportedDevices,
  }) : super(
          debugOwner: debugOwner,
          kind: kind,
          supportedDevices: supportedDevices,
        );

  Offset _dragDistance = Offset.zero;

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    _dragDistance = _dragDistance + event.delta;
    if (event is PointerMoveEvent) {
      final double dy = _dragDistance.dy.abs();
      final double dx = _dragDistance.dx.abs();

      if (dy > dx && dy > kTouchSlop) {
        // vertical drag - accept
        resolve(GestureDisposition.accepted);
        _dragDistance = Offset.zero;
      } else if (dx > kTouchSlop && dx > dy) {
        // horizontal drag - stop tracking
        stopTrackingPointer(event.pointer);
        _dragDistance = Offset.zero;
      }
    }
  }

  @override
  String get debugDescription => 'horizontal drag (platform view)';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
