import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  TextEditingController _noteController = TextEditingController();
  List<String> notes = [];  // List to store all notes

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Save the note to a text file
  Future<void> _saveNote() async {
    String note = _noteController.text.trim();
    if (note.isEmpty) return;

    setState(() {
      notes.add(note); // Add note to the list
      _noteController.clear();
    });

    final directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/notes.txt');
    await file.writeAsString(notes.join('\n'));
  }

  // Load notes from file
  Future<void> _loadNotes() async {
    final directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/notes.txt');
    if (await file.exists()) {
      String content = await file.readAsString();
      setState(() {
        notes = content.split('\n');  // Load notes into the list
      });
    }
  }

  // Delete the selected note
  Future<void> _deleteNoteAt(int index) async {
    setState(() {
      notes.removeAt(index);
    });

    final directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/notes.txt');
    await file.writeAsString(notes.join('\n'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Enter your note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveNote,
              child: const Text('Save Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(notes[index]),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,         // Use the standard delete icon
                        color: Colors.redAccent,
                        size: 24.0,           // Set the size
                      ),
                      onPressed: () => _deleteNoteAt(index),  // Delete specific note
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
