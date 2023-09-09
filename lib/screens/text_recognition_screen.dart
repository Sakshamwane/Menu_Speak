import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextRecognitionScreen extends StatefulWidget {
  @override
  _TextRecognitionScreenState createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  FlutterTts flutterTts = FlutterTts();
  final ImagePicker _imagePicker = ImagePicker();
  late String recognizedText = '';
  late String sequentialText='';

  Future<void> speakText(String text) async {
  await flutterTts.setLanguage("en-US"); // Set the language (adjust as needed)   
  await flutterTts.speak(text);
  }

  Future<void> _pickImage(ImageSource source) async {
    this.recognizedText = '';
    final image = await _imagePicker.pickImage(source: source);

    if (image == null) return;

    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();

    final RecognizedText text = await textDetector.processImage(inputImage);
    String recognizedText = '';

    for (TextBlock block in text.blocks) {
      for (TextLine line in block.lines) {
        // recognizedText += line.text + '\n';
        for(TextElement element in line.elements){
          recognizedText += element.text;
        }
        recognizedText+='\n';
      }
    }

    setState(() {
      this.recognizedText = recognizedText;
    });

    textDetector.close();
    await processRecognizedText();
  }

  //Processing Text:
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



    // Create a map pairing menu items with their prices
    Map<String, String> menuItemsAndPrices = {};

    // Create a map pairing menu items with their prices
    for (int i = 0; i < menuItems.length; i++) {
      menuItemsAndPrices[menuItems[i]] = prices[i];
    }

    // Generate sequential text and speak it
    final String sequentialText = menuItemsAndPrices.entries.map((entry) => '${entry.key} - ${entry.value}').join('\n');
    // print('Sequential Text: $sequentialText'); // Add this line

    setState(() {
      // Set the sequentialText state to trigger a rebuild of the widget
      this.sequentialText = sequentialText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blind Dine')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 500,
              width: 300,
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
                    child: Expanded(child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(sequentialText,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      
                    ),
                    ),)),
                  ),
            ),
            const SizedBox(height: 20),
            //Speak button
            ElevatedButton(
              onPressed: () {
              speakText(sequentialText);
            },
            child: const Text('Speak Recognized Text'),
            ),
            //Pick image button
            ElevatedButton(
              onPressed: (){ _pickImage(ImageSource.gallery);},
              child: const Text('Pick Image from Gallery'),
            ),
            //Capture image button
            ElevatedButton(
              onPressed: (){ _pickImage(ImageSource.camera);},
              child: const Text('Capture Image from Camera'),
            ),
          ],
        ),
      ),
    );
  }
}