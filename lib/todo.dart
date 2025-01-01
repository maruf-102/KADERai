import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToDoPage extends StatefulWidget {
  @override
  _ToDoPageState createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  final TextEditingController _taskController = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Load tasks from local storage
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getStringList('tasks') ?? [];
    _tasks = tasksString.map((task) {
      final taskData = task.split('|');
      return {'task': taskData[0], 'completed': taskData[1] == 'true'};
    }).toList();
    setState(() {});
  }

  // Save tasks to local storage
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = _tasks.map((task) => "${task['task']}|${task['completed']}").toList();
    prefs.setStringList('tasks', tasksString);
  }

  // Add a new task
  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add({'task': _taskController.text, 'completed': false});
        _taskController.clear();
      });
      _saveTasks();
    }
  }

  // Edit a task
  void _editTask(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _editController = TextEditingController(text: _tasks[index]['task']);
        return AlertDialog(
          title: Text("Edit Task"),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(
              hintText: "Edit your task",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _tasks[index]['task'] = _editController.text;
                });
                _saveTasks();
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Toggle task completion
  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index]['completed'] = !_tasks[index]['completed'];
    });
    _saveTasks();
  }

  // Remove a task
  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To-Do List"),
        centerTitle: true,
        backgroundColor: Color(0xFF70BDF2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: "Enter a task",
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addTask,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        _tasks[index]['task'],
                        style: TextStyle(
                          decoration: _tasks[index]['completed'] ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                      leading: Checkbox(
                        value: _tasks[index]['completed'],
                        onChanged: (value) {
                          _toggleTaskCompletion(index);
                        },
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editTask(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeTask(index),
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
