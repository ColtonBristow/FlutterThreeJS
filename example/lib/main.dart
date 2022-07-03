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

class ModelView extends StatelessWidget {
  const ModelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WebViewController? webViewController;
    ThreeJSController controller = ThreeJSController(webController: webViewController);

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.animation),
          focusColor: Colors.red,
          backgroundColor: Colors.redAccent,
          onPressed: () {
            controller.tweenCamera(12, 4, 7, 2000, false);
          },
        ),
        appBar: AppBar(
          title: Text("ThreeJSViewer"),
          backgroundColor: Colors.redAccent,
        ),
        body: Container(
          color: Colors.black,
          child: ThreeJSViewer(
            debug: true,
            onError: (details) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(details.description),
                ),
              );
            },
            models: [
              ThreeModel(
                src: 'https://dfoxw2i5wdgo8.cloudfront.net/mobile/request/GreatBibleWoodenCover.glb',
                playAnimation: false,
              ),
            ],
          ),
        ));
  }
}
