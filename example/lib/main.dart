import 'package:flutter/material.dart';
import 'package:threeJS_Viewer/threeJSController.dart';
import 'package:threeJS_Viewer/threeJSModelViewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WebViewController? webViewController;
    ThreeJSController controller = ThreeJSController(webController: webViewController);

    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.animation),
          focusColor: Colors.red,
          backgroundColor: Colors.redAccent,
          onPressed: () {},
        ),
        appBar: AppBar(
          title: Text("ThreeJSViewer"),
          backgroundColor: Colors.redAccent,
        ),
        body: ThreeJSViewer(
          controller: controller,
          onError: (details) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(details.description),
              ),
            );
          },
          models: [
            ThreeModel(src: 'https://userbob.com/motb/woodenBible/GreatBibleWoodenCover.glb', playAnimation: false),
          ],
        ),
      ),
    );
  }
}
