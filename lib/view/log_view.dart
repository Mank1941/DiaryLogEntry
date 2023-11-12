import 'package:assignment2_2/view/components/log_entry_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/controller/log_controller.dart';
import '/model/logmodel.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'log_edit_view.dart';

class DiaryLogScreen extends StatefulWidget {
  DiaryLogScreen({Key? key}) : super(key: key);

  final LogController logController = LogController();

  @override
  _DiaryLogScreen createState() => _DiaryLogScreen();
}

class _DiaryLogScreen extends State<DiaryLogScreen> {
  @override
  void initState() {
    super.initState();
    sendDataToFirebase();
  }

  void sendDataToFirebase() async {
    FirebaseFirestore.instance
        .collection('data')
        .add({'timestamp': FieldValue.serverTimestamp()});
  }

  //Filtering variables
  bool filter = false;
  int filter_selectedMonth =
      DateTime.now().month; // Default to the current month
  int filter_selectedYear = DateTime.now().year; // Default to the current year

  PopupMenuButton<String> _buildPopupMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert), // Three-dot vertical icon
      itemBuilder: (context) {
        return <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'filter',
            child: Text('Filter'),
          ),
          const PopupMenuItem<String>(
            value: 'reset filter',
            child: Text('Reset Filter'),
          ),
        ];
      },
      onSelected: (String choice) async {
        if (choice == 'filter') {
          // Handle filter action
          await _showFilterDialog(context);
        } else if (choice == 'reset filter') {
          // Handle filter action
          filter = false;
        }
        //print(filter);
      },
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    int selectedMonth = DateTime.now().month; // Default to the current month
    int selectedYear = DateTime.now().year; // Default to the current year

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Logs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Dropdown for selecting the month
              DropdownButton<int>(
                value: selectedMonth,
                items: List.generate(12, (index) {
                  return DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text(
                        DateFormat.MMMM().format(DateTime(2021, index + 1))),
                  );
                }),
                onChanged: (value) {
                  selectedMonth = value!;
                  // setState(() {});
                },
              ),
              // Dropdown for selecting the year
              DropdownButton<int>(
                value: selectedYear,
                items: List.generate(10, (index) {
                  return DropdownMenuItem<int>(
                    value: DateTime.now().year - index,
                    child: Text((DateTime.now().year - index).toString()),
                  );
                }),
                onChanged: (value) {
                  selectedYear = value!;
                  //setState(() {});
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Filter logs for the selected month and year
                Navigator.of(context).pop();
                filter = true;
                filter_selectedMonth = selectedMonth;
                filter_selectedYear = selectedYear;
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Log'),
        actions: [
          //_buildPopupMenuButton(context),
          IconButton(
            tooltip: ("Log-out"),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: StreamBuilder<List<LogModel>>(
        stream: widget.logController.getAllEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Loading indicator
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No entries found'),
            );
          } else {
            final logs = snapshot.data!;
            // Build list
            List<Widget> widgets = [];
            DateTime? lastDate;

            for (int i = 0; i < logs.length; i++) {
              final entry = logs[i];
              DateTime date = widget.logController.getDatetime(entry);

              if (lastDate == null ||
                  date.month != lastDate.month ||
                  date.year != lastDate.year) {
                final headerText = DateFormat('MMMM yyyy').format(date);
                widgets.add(DateHeader(text: headerText));
              }
              widgets.add(
                InkWell(
                  onTap: () async {},
                  child: LogEntryWidget(
                    entry: LogModel(
                      id: entry
                          .id, // Assuming 'id' is the field for document ID
                      date: entry.date,
                      description: entry.description,
                      rating: entry.rating,
                    ),
                    onDelete: () {
                      widget.logController.deleteEntryByEntry(entry);
                    },
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LogEditScreen(entry: entry)),
                      );
                    },
                  ),
                ),
              );
              lastDate = date;
            }
            return ListView(
              children: widgets,
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addEntry');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DateHeader extends StatelessWidget {
  final String text;

  const DateHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
