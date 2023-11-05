import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/model/logmodel.dart'; // Import the LogModel class
import '/controller/log_controller.dart'; // Import your LogController

class DiaryEntryScreen extends StatefulWidget {
  final Function onLogAdded;

  const DiaryEntryScreen({
    super.key,
    required this.onLogAdded,
  });

  @override
  _DiaryEntryScreenState createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  final LogController logController = LogController();

  DateTime selectedDate = DateTime.now(); // Initialize with today's date
  int? rating;
  TextEditingController diaryTextController = TextEditingController();

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveEntry() {
    //Get text from text controller
    final String diaryText = diaryTextController.text;
    //print("Description: " + diaryText);

    if (rating == null) {
      //Display error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select a rating before saving the entry.")),
      );
      return;
    }

    // Create a new LogModel entry
    final LogModel entry = LogModel(
      date: selectedDate,
      description: diaryText,
      rating: rating!,
    );

    print("Date: $selectedDate");

    // Use the LogController to add the entry
    if (logController.addEntry(entry)) {
      setState(() {
        diaryTextController.clear;
      });
      widget.onLogAdded.call();

      //Entry added succesfully
      Navigator.pop(context); //Go back to previous screen
    } else {
      //Display an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Date already exists in the Logs")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diary Entry"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: diaryTextController,
              decoration:
                  const InputDecoration(labelText: 'Diary Text (140 characters)'),
              maxLength: 140,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => _selectDate(context),
              child: const Text('Select Date'),
            ),
            Text(
                'Selected Date: ${DateFormat('MMMM dd, y').format(selectedDate)}'),
            //Implement a rating system (star rating or a scale of 1 to 5)
            const Text('Rating: '),
            Row(
              children: [1, 2, 3, 4, 5].map((value) {
                return Row(
                  children: [
                    Radio<int>(
                      value: value,
                      groupValue: rating,
                      onChanged: (int? newValue) {
                        setState(() {
                          rating = newValue;
                        });
                      },
                    ),
                    Text(value.toString()),
                  ],
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _saveEntry,
              child: const Text('Save Entry'),
            ),
            //Implement a button to save the entry
          ],
        ),
      ),
    );
  }
}
