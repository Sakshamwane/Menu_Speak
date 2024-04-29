import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class MenuPriceSearchScreen extends StatefulWidget {
  final Map<String, String> menuItemsAndPrices;

  MenuPriceSearchScreen({required this.menuItemsAndPrices});

  @override
  _MenuPriceSearchScreenState createState() => _MenuPriceSearchScreenState();
}

class _MenuPriceSearchScreenState extends State<MenuPriceSearchScreen> {
  String searchQuery = '';
  String searchResult = '';

  stt.SpeechToText speech = stt.SpeechToText();
  FlutterTts flutterTts = FlutterTts();

  void handleSearch() {
  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase(); // Convert query to lowercase for case-insensitive search
    String foundKey="h";

    // Iterate through menu item keys
    for (var key in widget.menuItemsAndPrices.keys) {
      if (key.toLowerCase() == query) {
        foundKey = key;
        break; // Break the loop when a match is found
      }
    }

    if (foundKey != null) {
      final price = widget.menuItemsAndPrices[foundKey];
      setState(() {
        searchResult = '$foundKey - $price';
      });
    } else {
      setState(() {
        searchResult = 'Menu item not found.';
      });
    }
  } else {
    setState(() {
      searchResult = 'Please enter a menu item.';
    });
  }
}

  Future<void> startListening() async {
    if (await speech.initialize()) {
      // Start listening
      speech.listen(onResult: (result) {
        if (result.finalResult) {
          String query = result.recognizedWords;
          // Set the search query based on the recognized voice input
          setState(() {
            searchQuery = query;
          });
          // Call the handleSearch function to perform the search
          handleSearch();
          // Provide voice feedback for the search result
          speakResult(searchResult);
        }
      });
    }
  }

  Future<void> speakResult(String result) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Item Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for a menu item',
              ),
            ),
            ElevatedButton(
              onPressed: handleSearch,
              child: Text('Search'),
            ),
            SizedBox(height: 16),
            Text(searchResult),
            ElevatedButton(
              onPressed: startListening, // Button for voice search
              child: Text('Voice Search'),
            ),
          ],
        ),
      ),
    );
  }
}
