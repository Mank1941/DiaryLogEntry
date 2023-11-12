import 'package:flutter/material.dart';
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
  final TextEditingController _diaryTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.logController.getDatetime(widget.entry);
    _rating = widget.entry.rating;
    _diaryTextController.text = widget.entry.description;
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Update the existing entry
                widget.entry.description = _diaryTextController.text;
                //widget.entry.date =    widget.logController.getTimestamp(_selectedDate);
                widget.entry.rating = _rating;

                await widget.logController.updateEntry(widget.entry);
                Navigator.pop(context); // Go back to the previous screen
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
