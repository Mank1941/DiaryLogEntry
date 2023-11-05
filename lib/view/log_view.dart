import 'dart:io';

import 'package:assignment2_2/view/components/log_entry_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/view/log_add_view.dart';
import '/controller/log_controller.dart';
import '/model/logmodel.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DiaryLogScreen extends StatelessWidget {
  final LogController logController;

  bool filter = false;
  int filter_selectedMonth =
      DateTime.now().month; // Default to the current month
  int filter_selectedYear = DateTime.now().year; // Default to the current year

  DiaryLogScreen({Key? key, required this.logController}) : super(key: key);

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
    //var diaryEntries = logController.getAllEntries();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Log'),
        actions: [
          _buildPopupMenuButton(context),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: logController.logBox.listenable(),
        builder: (context, Box box, widget) {
          if (box.isEmpty) {
            return const Center(
              child: Text('No entries found'),
            );
          } else {
            final entries = box.values.cast<LogModel>().toList();
            entries.sort((a, b) => b.date
                .compareTo(a.date)); // Sort entries by date in descending order
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ValueListenableBuilder(
                valueListenable: logController.logBox.listenable(),
                builder: (context, Box box, widget) {
                  if (box.isEmpty) {
                    return const Center(
                      child: Text('No entries found'),
                    );
                  } else {
                    final entries = box.values.cast<LogModel>().toList();
                    entries.sort((a, b) => b.date.compareTo(a.date));

                    List<Widget> widgets = [];
                    DateTime? lastDate;
                    for (int i = 0; i < entries.length; i++) {
                      final entry = entries[i];
                      if (lastDate == null ||
                          entry.date.month != lastDate.month ||
                          entry.date.year != lastDate.year) {
                        final headerText =
                            DateFormat('MMMM yyyy').format(entry.date);
                        widgets.add(DateHeader(text: headerText));
                      }
                      widgets.add(
                        LogEntryWidget(
                          entry: entry,
                          onDelete: () {
                            logController.deleteEntryByEntry(entry);
                          },
                        ),
                      );
                      lastDate = entry.date;
                    }

                    return ListView(
                      children: widgets,
                    );
                  }
                },
              ),
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

  const DateHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
