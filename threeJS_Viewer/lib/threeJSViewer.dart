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
  ThreeJSController? controller;
  Function? onPageFinishedLoading;
  Iterable<JavascriptChannel>? channels;
  Function? onError;
  PerspectiveCameraConfig? cameraConfig;
  LocalAssetsServer? addressServer;
  bool? debug;

  ThreeJSViewer({
    Key? key,
    this.cameraConfig,
    this.controller,
    this.channels,
    this.onError,
    this.onPageFinishedLoading,
    this.addressServer,
    this.debug,
  }) : super(key: key);

  @override
  _ThreeJSViewerState createState() => _ThreeJSViewerState();
}

class _ThreeJSViewerState extends State<ThreeJSViewer> {
  Future<InternetAddress>? address;
  double loadingProgress = 0;
  int port = 4000;
  Set<JavascriptChannel> channels = {};

  initServer() async {
    if (widget.addressServer == null) {
      final server = LocalAssetsServer(
        port: 4000,
        address: InternetAddress.loopbackIPv4,
        assetsBasePath: 'packages/threeJS_Viewer/web',
        logger: const DebugLogger(),
      );
      setState(() {});
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
    var wcontroller;
    return FutureBuilder(
      future: address,
      builder: (context, snapshot) {
        if (snapshot.hasData == false) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          InternetAddress address = snapshot.data as InternetAddress;
          log('started local server http://${address.address}:$port');
          return WebView(
            debuggingEnabled: true,
            backgroundColor: Colors.transparent,
            initialUrl: 'http://${address.address}:$port',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (c) {
              setState(() {
                wcontroller = c;
              });
              widget.controller = ThreeJSController(webController: c);
            },
            onPageFinished: (details) {
              widget.onPageFinishedLoading;
              log("calling js");
              var setupResults = wcontroller.runJavascriptReturningResult('window.setupScene(${widget.debug ?? false})');
            },
            javascriptChannels: channels,
            onWebResourceError: (error) {
              widget.onError;
            },
          );
        }
      },
    );
  }
}
