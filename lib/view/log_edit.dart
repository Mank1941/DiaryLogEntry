import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/model/logmodel.dart'; // Import the LogModel class
import '/controller/log_controller.dart'; // Import your LogController
import 'package:cloud_firestore/cloud_firestore.dart';

class LogEditScreen extends StatefulWidget {
  final LogModel logEntry; // Pass the log entry to edit

  LogEditScreen({Key? key, required this.logEntry}) : super(key: key);

  final LogController logController = LogController();

  @override
  _LogEditScreenState createState() => _LogEditScreenState();
}

class _LogEditScreenState extends State<LogEditScreen> {
  TextEditingController _diaryTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _diaryTextController =
        TextEditingController(text: widget.logEntry.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Diary Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _diaryTextController,
              maxLength: 140,
              maxLines: 4, // This allows for multiple lines
              keyboardType: TextInputType
                  .multiline, // This sets up the keyboard for multiline input
              decoration: const InputDecoration(
                labelText: 'Description',
                helperText: 'Edit your day in 140 characters',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save the edited description and pop the screen
                widget.logEntry.description = _diaryTextController.text;
                Navigator.pop(context, widget.logEntry);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
