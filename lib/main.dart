import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? image;
  String result = '';
  File? _video;
  VideoPlayerController? controller;
  late ImageLabeler imageLabeler;

  void initState() {
    // TODO: implement initState
    super.initState();
    imageLabeler = GoogleMlKit.vision.imageLabeler();
  }

  Future<void> pickvideo(ImageSource source) async {
    XFile? video = await ImagePicker().pickVideo(source: source);
    //if (video==null) return;
    _video = File(video!.path);
    controller = VideoPlayerController.file(_video!)
      ..initialize().then((_) {
        setState(() {});
        controller!.play();
      });
  }

  Future pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;
    final imageTem = File(image.path);
    setState(() => this.image = imageTem);
    imagelabelling();
  }

  imagelabelling() async {
    final inputImage = InputImage.fromFile(image!);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    result = "";
    for (ImageLabel label in labels) {
      final String text = label.label;
      final int index = label.index;
      final double confidence = label.confidence;
      setState(() {
        result += text + "  " + confidence.toStringAsFixed(2) + "\n";
      });
    }
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   imageLabeler.close();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            image != null
                ? Image.file(
                    image!,
                    height: 300,
                    width: 300,
                  )
                : ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt_outlined),
                    label: Text('Click a photo')),
            ElevatedButton.icon(
                onPressed: () => pickImage(ImageSource.gallery),
                icon: Icon(Icons.image_outlined),
                label: Text('Gallery')),
            _video != null
                ? AspectRatio(
                    aspectRatio: 16.0 / 9.0,
                    child: controller!.value.isInitialized
                        ? VideoPlayer(controller!)
                        : Container(),
                  )
                : AspectRatio(
                    aspectRatio: 16.0 / 9.0,
                    child: Container(
                      child: Text('pick video'),
                    ),
                  ),
            ElevatedButton(
              onPressed: () => pickvideo(ImageSource.gallery),
              child: Text('select video'),
            ),
            Container(
              child: Text(
                '$result',
              ),
            )
          ],
        ),
      ),
    );
  }
}
