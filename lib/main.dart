import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(VisionAidApp());
}

class VisionAidApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VisionAid AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: VisionHomePage(),
    );
  }
}

class VisionHomePage extends StatefulWidget {
  @override
  _VisionHomePageState createState() => _VisionHomePageState();
}

class _VisionHomePageState extends State<VisionHomePage> {
  CameraController? _controller;
  FlutterTts flutterTts = FlutterTts();
  bool _isCameraInitialized = false;
  String detectedObject = "No object detected";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (cameras == null || cameras!.isEmpty) return;
    _controller = CameraController(cameras![0], ResolutionPreset.medium);
    await _controller!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _detectObject() async {
    // TODO: connect this with your AI model (Python / TensorFlow Lite)
    // For now, we’ll just simulate detection:
    setState(() {
      detectedObject = "Bottle";
    });

    // Speak the detected object
    await flutterTts.speak("Detected object is $detectedObject");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("VisionAid AI"),
        centerTitle: true,
      ),
      body: _isCameraInitialized
          ? Stack(
        children: [
          CameraPreview(_controller!),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _detectObject,
                icon: Icon(Icons.search),
                label: Text("Scan Object"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Detected: $detectedObject",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
