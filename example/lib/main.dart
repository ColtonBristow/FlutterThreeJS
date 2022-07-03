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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Container(
        color: Colors.black,
        child: Stack(children: [
          percLoaded != 100
              ? Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    value: null,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    backgroundColor: Colors.white,
                  ),
                )
              : Container(),
          ThreeJSViewer(
            onLoadProgress: (double percentLoaded) {
              print("Perc loaded: ${percentLoaded}");
              setState(() {
                percLoaded = percentLoaded;
              });
            },
            onWebViewCreated: (c) {
              controller = c;
            },
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
                src: "https://dfoxw2i5wdgo8.cloudfront.net/mobile/request/bigKhachkar.glb",
                playAnimation: false,
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
