import 'package:Blind_Dine/screens/MenuPriceSearchScreen.dart';
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

  const MyApp(this.cameras);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu Speak',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[350],
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => TextRecognitionScreen(),
        '/camera': (context) => CameraScreen(cameras),
        '/search': (context)  {
          final Map<String, String> menuItemsAndPrices =
      ModalRoute.of(context)!.settings.arguments as Map<String, String>;return MenuPriceSearchScreen(menuItemsAndPrices: menuItemsAndPrices);
      },}
    );
  }
}
