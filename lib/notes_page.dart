import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  TextEditingController _noteController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  List<Map<String, String?>> notes = []; // List to store all notes with timestamp and image path
  List<Map<String, String?>> filteredNotes = [];
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _saveNote() async {
    String note = _noteController.text.trim();
    if (note.isEmpty && _selectedImagePath == null) return;

    String timestamp = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());

    setState(() {
      notes.add({"note": note, "timestamp": timestamp, "imagePath": _selectedImagePath});
      _noteController.clear();
      _selectedImagePath = null;
    });

    final directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/notes.txt');
    await file.writeAsString(notes.map((note) {
      return "${note["note"]}\t${note["timestamp"]}\t${note["imagePath"] ?? ""}";
    }).join('\n'));

    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/notes.txt');
    if (await file.exists()) {
      String content = await file.readAsString();
      setState(() {
        notes = content.split('\n').map((line) {
          var parts = line.split('\t');
          return {
            "note": parts[0],
            "timestamp": parts[1],
            "imagePath": parts.length > 2 ? parts[2] : null,
          };
        }).toList();
        filteredNotes = List.from(notes);
      });
    }
  }

  Future<void> _deleteNoteAt(int index) async {
    setState(() {
      notes.removeAt(index);
      filteredNotes.removeAt(index);
    });

    final directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/notes.txt');
    await file.writeAsString(notes.map((note) {
      return "${note["note"]}\t${note["timestamp"]}\t${note["imagePath"] ?? ""}";
    }).join('\n'));
  }

  void _filterNotes(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredNotes = List.from(notes);
      });
    } else {
      setState(() {
        filteredNotes = notes.where((note) => note["note"]!.toLowerCase().contains(query.toLowerCase())).toList();
      });
    }
  }

  void _editNoteAt(int index) {
    _noteController.text = notes[index]["note"]!;
    _selectedImagePath = notes[index]["imagePath"];
    _deleteNoteAt(index);
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
            // Note input field
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Write a note',
                labelStyle: TextStyle(color: Colors.indigoAccent),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Image picker and selected image preview
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  label: const Text('Add Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (_selectedImagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_selectedImagePath!),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Save Note button
            ElevatedButton(
              onPressed: _saveNote,
              child: const Text('Save Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search notes...',
                labelStyle: TextStyle(color: Colors.indigoAccent),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.indigoAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterNotes,
            ),
            const SizedBox(height: 20),

            // Notes list
            Expanded(
              child: ListView.builder(
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];
                  final noteText = note["note"]!;
                  final noteTimestamp = note["timestamp"]!;
                  final imagePath = note["imagePath"];

                  return Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: imagePath != null && imagePath.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(imagePath),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Icon(
                        Icons.note,
                        color: Colors.indigoAccent,
                        size: 40,
                      ),
                      title: Text(
                        noteText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          "Last edited: $noteTimestamp",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () => _editNoteAt(index),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteNoteAt(index),
                          ),
                        ],
                      ),
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
