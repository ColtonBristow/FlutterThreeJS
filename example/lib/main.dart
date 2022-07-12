import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:threeJS_Viewer/threeJSController.dart';
import 'package:threeJS_Viewer/threeJSModelViewer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ModelView(),
    );
  }
}

// ignore: must_be_immutable
class ModelView extends StatefulWidget {
  ModelView({Key? key}) : super(key: key);

  @override
  State<ModelView> createState() => _ModelViewState();
}

class _ModelViewState extends State<ModelView> {
  ThreeJSController? controller;
  double percLoaded = 0;
  String loadMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.animation),
        focusColor: Colors.red,
        backgroundColor: Colors.redAccent,
        onPressed: () {
          controller?.tweenCamera(0, 10, 15, 2000, false, yOffset: 8);
        },
      ),
      appBar: AppBar(
        title: Text("ThreeJSViewer"),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            ThreeJSViewer(
              scale: 20,
              progressBuilder: (double? progress, String message) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      color: Colors.red,
                      backgroundColor: Colors.black,
                    ),
                    SizedBox(
                      height: 20,
                      width: double.infinity,
                    ),
                    Text(message),
                  ],
                );
              },
              onWebViewCreated: (c) {
                controller = c;
              },
              debug: kDebugMode,
              onError: (details) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(details.description),
                  ),
                );
              },
              models: [
                ThreeModel(
                  src: "https://dfoxw2i5wdgo8.cloudfront.net/mobile/request/HMDesk.glb",
                  playAnimation: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
