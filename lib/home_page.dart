import 'dart:typed_data';
import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'notes_page.dart'; // Import the Notes page
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'pomodoro.dart'; // Import the Pomodoro Timer


Future<String> saveImageToFile(Uint8List imageBytes) async {
  final directory = await getTemporaryDirectory(); // Get the temp directory
  final uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString(); // Generate unique file name using timestamp
  final filePath = '${directory.path}/generated_image_$uniqueFileName.png'; // Create a temp file path with unique name
  final file = File(filePath);
  await file.writeAsBytes(imageBytes); // Write the image bytes to the file
  return filePath; // Return the file path
}


Future<Uint8List?> generateImage(String prompt) async {
  const String apiToken = "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";
  const String modelId = "stabilityai/stable-diffusion-3.5-large"; // Model to be used

  final url = Uri.parse('https://api-inference.huggingface.co/models/$modelId');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $apiToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'inputs': prompt}),
  );

  if (response.statusCode == 200) {
    return response.bodyBytes; // Return the image as bytes
  } else {
    // Decode and log the error for debugging
    var errorResponse = jsonDecode(response.body);
    print('Failed to generate image: ${response.statusCode} - ${errorResponse["error"]}');
    return null;
  }
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "KADERAi",
    profileImage: "assets/images/kadr3-03.png",
  );
  List<ChatMessage> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage("assets/images/kadr3-02.png"),
          ),
        ),
        title: Text(
          "KADERAi",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF70BDF2), // light blue matching your image
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF70BDF2), Color(0xFF0066CC)], // Blue gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DashChat(
                currentUser: currentUser,
                messages: messages,
                onSend: _sendMessage,
                inputOptions: InputOptions(
                  trailing: [
                    IconButton(
                      onPressed: _sendMediaMessage,
                      icon: Icon(Icons.image_rounded, color: Colors.white),
                    ),
                  ],
                  inputDecoration: InputDecoration(
                    hintText: 'image/ or Ask KADER .......',
                    hintStyle: TextStyle(color: Colors.grey[300]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFF70BDF2), // Light blue for the input field
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotesPage()),
                  );
                },
                child: Icon(Icons.note_add),
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
              ),
            ),
            Positioned(
              top: 70,
              right: 10,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PomodoroTimer()),
                  );
                },
                child: Icon(Icons.timer),
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> customResponses = {
    "hello kader": "Jalaaaa! ontore jalaaaaa..... ki bolben bolen..",
    "how are you": "Valo nei gorte achi....",
    "who created you": "Team ByteForge from BUBT",
    "who develope you": "Team ByteForge from BUBT",
    "what is the capital of bangladesh": "Noakhali, oops DHAKA",
    "what is your name": "KADERai, inspired from Crows name",
  };

  void _sendMessage(ChatMessage chatMessage) async {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    String question = chatMessage.text.toLowerCase();

    if (question.startsWith("image/")) {
      String prompt = question.replaceFirst("image/", "").trim();
      Uint8List? imageBytes = await generateImage(prompt);

      if (imageBytes != null) {
        String imagePath = await saveImageToFile(imageBytes); // Save image with unique name

        ChatMessage imageMessage = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: "Here's the generated image:",
          medias: [
            ChatMedia(
              url: imagePath, // Use the unique file path here
              fileName: "generated_image.png",
              type: MediaType.image,
            ),
          ],
        );

        setState(() {
          messages = [imageMessage, ...messages];
        });
      } else {
        ChatMessage errorMessage = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: "Sorry, I couldn't generate the image.",
        );
        setState(() {
          messages = [errorMessage, ...messages];
        });
      }


      return;
    }

    // Your existing custom response logic
    for (var key in customResponses.keys) {
      if (question.contains(key)) {
        ChatMessage responseMessage = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: customResponses[key]!,
        );
        setState(() {
          messages = [responseMessage, ...messages];
        });
        return;
      }
    }

    // If no custom logic is triggered, call Gemini API as fallback
    try {
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }
      gemini.streamGenerateContent(question, images: images).listen((event) {
        String response = event.content?.parts?.fold(
          "",
              (previous, current) => "$previous ${current.text}",
        ) ?? "";
        ChatMessage message = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: response,
        );
        setState(() {
          messages = [message, ...messages];
        });
      });
    } catch (e) {
      print(e);
    }
  }






  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Describe the picture",
        medias: [
          ChatMedia(url: file.path, fileName: "", type: MediaType.image),
        ],
      );
      _sendMessage(chatMessage);
    }
  }
}
