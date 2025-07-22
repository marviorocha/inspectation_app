import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras(); // Load available cameras once
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(cameras: cameras),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  bool _showCamera = false;

  Future<void> _initCamera() async {
    final camera = widget.cameras.first;

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    // Try to zoom to 0.6x if supported
    final minZoom = await _cameraController!.getMinZoomLevel();
    final maxZoom = await _cameraController!.getMaxZoomLevel();
    double targetZoom = 0.6;

    await _cameraController!.setZoomLevel(
      targetZoom.clamp(minZoom, maxZoom),
    );

    setState(() {
      _showCamera = true;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Example')),
      body: Center(
        child: _showCamera
            ? _cameraController != null &&
                    _cameraController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  )
                : const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _initCamera,
                child: const Text('Open Camera'),
              ),
      ),
    );
  }
}
