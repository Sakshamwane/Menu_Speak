import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:Blind_Dine/screens/text_recognition_screen.dart';
import 'screens/camera_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  MyApp(this.cameras);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blind Dine',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => TextRecognitionScreen(),
        '/camera': (context) => CameraScreen(cameras),
      },
    );
  }
}
