import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/model/logmodel.dart'; // Import the LogModel class
import '/controller/log_controller.dart'; // Import your LogController
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class DiaryEntryScreen extends StatefulWidget {
  DiaryEntryScreen({Key? key}) : super(key: key);

  final LogController logController = LogController();

  @override
  _DiaryEntryScreenState createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  DateTime _selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  int _rating = 3;
  final TextEditingController _diaryTextController = TextEditingController();
  String? _selectedImagePath;

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  Future<void> _saveEntry() async {
    //Get text from text controller
    final String diaryText = _diaryTextController.text;

    if (diaryText == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Enter a description")),
      );
      return;
    }

    // Create a new LogModel entry
    //Gotta convert to Timestamp cause Firestore has Timestamp and not Datetime
    Timestamp date = widget.logController.getTimestamp(_selectedDate);

    // Call the image picking function
    String? imageUrl;

    if (_selectedImagePath != null) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      imageUrl = await widget.logController
          .uploadImageToStorage(XFile(_selectedImagePath!), userId);
    }

    final LogModel newEntry = LogModel(
      date: date,
      description: diaryText,
      rating: _rating,
      imageUrl: imageUrl ?? '',
    );

    // Save entry to Firestore
    if (!await widget.logController
        .entryExists(widget.logController.getDatetime(newEntry))) {
      DocumentReference<Object?> documentReference =
          await widget.logController.addEntry(newEntry);

      //Update the entry with the image URL
      if (imageUrl != null) {
        await documentReference.update({'imageUrl': imageUrl});
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Date already exists in the Logs")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Diary Entry'),
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
                helperText: 'Describe your day in 140 characters',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Rate your day:'),
                Slider(
                  value: _rating.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (double value) {
                    setState(() {
                      _rating = value.toInt();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Pick Image"),
            ),
            if (_selectedImagePath != null)
              Image.file(
                File(_selectedImagePath!),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEntry,
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
