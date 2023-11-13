import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/model/logmodel.dart';
import '/controller/log_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogEditScreen extends StatefulWidget {
  final LogModel entry;
  final LogController logController = LogController();

  LogEditScreen({required this.entry});

  @override
  _LogEditScreenState createState() => _LogEditScreenState();
}

class _LogEditScreenState extends State<LogEditScreen> {
  late DateTime _selectedDate;
  late int _rating;
  late String _imageUrl;
  String? _imagePath;
  final TextEditingController _diaryTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.logController.getDatetime(widget.entry);
    _rating = widget.entry.rating;
    _diaryTextController.text = widget.entry.description;
    _imageUrl = widget.entry.imageUrl;
    _imagePath = "";
  }

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

  Future<void> _saveEditedEntry() async {
    // Update the existing entry
    widget.entry.description = _diaryTextController.text;
    //widget.entry.date =    widget.logController.getTimestamp(_selectedDate);
    widget.entry.rating = _rating;

    if (_imageUrl.isEmpty) {
      if (_imagePath!.isNotEmpty) {
        String userId = FirebaseAuth.instance.currentUser!.uid;
        _imageUrl = (await widget.logController
            .uploadImageToStorage(XFile(_imagePath!), userId))!;
      }
    }

    widget.entry.imageUrl = _imageUrl;

    await widget.logController.updateEntry(widget.entry);
    Navigator.pop(context, widget.entry); // Go back to the previous screen
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      //We have gotten a new Image
      _imagePath = image.path;
      _imageUrl = "";

      setState(() {});
    }
    // if (image != null) {
    //   String userId = FirebaseAuth.instance.currentUser!.uid;
    //   String? newImageUrl =
    //       await widget.logController.uploadImageToStorage(image, userId);

    //   if (newImageUrl != null) {
    //     setState(() {
    //       widget.entry.imageUrl = newImageUrl;
    //     });
    //   }
    // }
  }

  Future<void> _deleteImage() async {
    // Delete if has imageUrl
    if (_imageUrl.isNotEmpty) {
      _imageUrl = "";

      setState(() {});
    } else if (_imagePath!.isNotEmpty) {
      _imagePath = "";
      setState(() {});
    }
    // // Check if there is an existing image URL
    // if (widget.entry.imageUrl.isNotEmpty) {
    //   // Delete the image from storage
    //   await widget.logController.deleteImageFromStorage(widget.entry.imageUrl);

    //   // Update the entry to remove the image URL
    //   widget.entry.imageUrl = '';
    //   await widget.logController.updateEntry(widget.entry);

    //   // Trigger a rebuild to reflect the changes
    //   setState(() {});
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Diary Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveEditedEntry(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _diaryTextController,
              maxLength: 140,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
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
                  "Date: ${widget.entry.date.toDate().toString().split(' ')[0]}",
                ),
              ],
            ),
            if (_imageUrl.isNotEmpty)
              //Display Image of Entry if has url
              Image.network(
                _imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              )
            else if (_imagePath != null)
              Image.file(
                File(_imagePath!),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            if (_imageUrl.isNotEmpty)
              ElevatedButton(
                onPressed: _deleteImage,
                child: const Text("Delete Image"),
              ),
            if (_imageUrl.isNotEmpty || _imagePath!.isNotEmpty)
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Replace Image"),
              ),
            if (_imageUrl.isEmpty && _imagePath!.isEmpty)
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Add Image"),
              ),
            // if (widget.entry.imageUrl.isNotEmpty)
            //   Image.network(
            //     widget.entry.imageUrl,
            //     height: 100,
            //     width: double.infinity,
            //     fit: BoxFit.cover,
            //   ),
            // ElevatedButton(
            //   onPressed: _pickImage,
            //   child: const Text("Change Image"),
            // ),
            // if (widget.entry.imageUrl.isNotEmpty)
            //   ElevatedButton(
            //     onPressed: _deleteImage,
            //     child: const Text("Delete Image"),
            //   ),
          ],
        ),
      ),
    );
  }
}
