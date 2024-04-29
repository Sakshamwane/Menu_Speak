import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:io';
import 'package:edge_detection/edge_detection.dart';
import 'package:path/path.dart'; 
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'MenuPriceSearchScreen.dart';

class TextRecognitionScreen extends StatefulWidget {
  @override
  _TextRecognitionScreenState createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  FlutterTts flutterTts = FlutterTts();
  final ImagePicker _imagePicker = ImagePicker();
  late String recognizedText = '';
  late String sequentialText='';
  // Create a map pairing menu items with their prices
    Map<String, String> menuItemsAndPrices = {};
  

   Future<void> _pickImage(ImageSource source) async {
    
    String imagePath = ''; 

  try {
  // Generate a filepath for saving the captured image
    imagePath = join(
    (await getApplicationSupportDirectory()).path,
    "${DateTime.now().millisecondsSinceEpoch ~/ 1000}.jpeg",
  );

  // Use the Edge Detection package to capture and process the image
  bool success = await EdgeDetection.detectEdge(
    imagePath,
    canUseGallery: true,
    androidScanTitle: 'Scanning', 
    androidCropTitle: 'Crop',
    androidCropBlackWhiteTitle: 'Black White',
    androidCropReset: 'Reset',
  );

  if (success) {
    print("Edge detection successful");
    // After successful edge detection, call text recognition on the processed image
   await _processImageForTextRecognition(imagePath);
  }
  } catch (e) {
      print("Error during edge detection: $e");
  }
}

  Future<void> _processImageForTextRecognition(String imagePath) async {
  // Create an instance of the text recognizer
    final textRecognizer = GoogleMlKit.vision.textRecognizer();

  try {

    String text = " ";
    // Create a FirebaseVisionImage from the image path
    final inputImage = InputImage.fromFilePath(imagePath);

    // Process the image to extract text
    final recognizedText = await textRecognizer.processImage(inputImage);

    // Extract and handle the recognized text
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        for(TextElement element in line.elements){
          text += element.text;
          print("Recognized Text: $text");
        }
        text += '\n';
      }
    }

    setState(() {
      this.recognizedText = text;
    });
    print("Text recognition successful");
  } catch (e) {
    print("Text Recognition Error: $e");
  } finally {
    // Clean up the text recognizer when done
    await textRecognizer.close();
    await processRecognizedText();
  }
}

  
  Future<void> processRecognizedText() async {
    this.sequentialText='';
    int uppercaseLineCount = 0; 
    // Let's assume recognizedText contains the recognized text

    List<String> lines = recognizedText.split('\n');

  List<String> menuItems = [];
  List<String> prices = [];
  bool isMenuPhase = true;

  for (int i = 0; i < lines.length; i++) {
    String line = lines[i].trim();

    // Check if the line contains numeric characters (indicating it's a price)
    bool isPrice = RegExp(r'\d').hasMatch(line);

    // Check if the line contains all uppercase letters (indicating it's a heading)
    bool isHeading = RegExp(r'^[A-Z]+$').hasMatch(line);

    if (isHeading) {
      // This line is a heading, so switch to the menu phase
      isMenuPhase = true;
      continue;
    }

    if (isPrice) {
      // This line is a price, so switch to the prices phase
      isMenuPhase = false;
      prices.add(line);
    } else if (isMenuPhase) {
      // If it's not a price or heading and we're in the menu phase, consider it a menu item
      menuItems.add(line);
    }
  }

    menuItemsAndPrices.clear();

    // Create a map pairing menu items with their prices
    for (int i = 0; i < menuItems.length; i++) {
      menuItemsAndPrices[menuItems[i]] = prices[i];
    }

    // Generate sequential text and speak it
    final String sequentialText = menuItemsAndPrices.entries.map((entry) => '${entry.key} - ${entry.value}').join('\n');
    print('Sequential Text: $sequentialText'); 
    print("Text processing successful");


    setState(() {
      this.sequentialText = sequentialText;
    });
  }

  Future<void> speakText(String text) async {
  await flutterTts.setLanguage("en-US");    
  await flutterTts.speak(text);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu Speak'),

      leading: IconButton(
      icon: Icon(Icons.menu),
      onPressed: () {
        Scaffold.of(context).openEndDrawer(); // Open the menu drawer.
      },
    ),
    
    ),
         endDrawer: Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text('Menu'),
        ),
        ListTile(
          title: Text('Home'),
          onTap: () {
            // Navigate to the TextRecognitionScreen.
    Navigator.of(context).pop(); // Close the drawer.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TextRecognitionScreen()),
    );
          },
        ),
        ListTile(
          title: Text('Search'),
          onTap: () {
            Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MenuPriceSearchScreen(menuItemsAndPrices: menuItemsAndPrices),
  ),
);

          },
        ),
        // Add more ListTile widgets for additional menu options.
      ],
    ),
  ),

      body: 
      Builder(
    builder: (BuildContext context) {
      return Center(

        child: 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 15),
            Container(
              margin: EdgeInsets.all(10),
              child: const Text("Welcome, ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Colors.black,
                    ),
            ),
            ),
            // const SizedBox(height: 10),
            Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 70,
              width: 400,
              // padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              child: 
              const Text("Exploring Menus Made Simple", 
              textAlign: TextAlign.left,
              style: TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                    ),
              ),
              decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30))
            ),
            ),
            // const SizedBox(height: 25),
            Container(
              height: 300,
              width: 400,
              margin: EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: 
                  Center(
                    child: Expanded(
                      child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(sequentialText,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                    ),)),
                  ),
              ),
            ),

            // const SizedBox(height: 60),

           Container(
            height: 180,
            width: 400,
            margin: EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.all(Radius.circular(30))
            ),

            child:  Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Container(
            height: 50,
            width: 250,
            child: ElevatedButton.icon(
              icon: const Icon(
                Icons.headset_rounded,
                color: Colors.black,
                size: 40,
              ),
              label: const Text("Speak Text",
              style: const TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                    ),),
              onPressed: (){ speakText(sequentialText);},
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
    )
  )
)
            ),
          ),
            const SizedBox(height: 30),
           Container(
            height: 50,
            width: 250,
            child: ElevatedButton.icon(
              icon: const Icon(
                Icons.camera_enhance,
                color: Colors.black,
                size: 40,
              ),
              label: const Text("Get Image",
              style: const TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                    ),),
              onPressed: (){ _pickImage(ImageSource.camera);},
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
    )
  )
)
            ),
          ),
            ],),
           )
            
          ],
        ),
          ],
        )
        
      ); 
      },
  ),
   
    );
  }
}