import 'dart:io';

import 'package:flutter/material.dart';
import '/view/log_add_view.dart';
import '/controller/log_controller.dart';
import '/model/logmodel.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DiaryLogScreen extends StatefulWidget {
  const DiaryLogScreen({super.key});

  @override
  _DiaryLogScreenState createState() => _DiaryLogScreenState();
}

class _DiaryLogScreenState extends State<DiaryLogScreen> {
  final LogController logController = LogController();
  List<LogModel> diaryEntries = [];

  @override
  void initState() {
    super.initState();
    _loadDiaryEntry();
  }

  //Load Entries
  void _loadDiaryEntry() {
    setState(() {
      diaryEntries = logController.getAllEntries();
      _sortLogs();
      //print("Hello");
    });
  }

  void _sortLogs() {
    diaryEntries.sort((a, b) {
      // Compare by year
      int yearComparison = a.date.year.compareTo(b.date.year);
      if (yearComparison != 0) {
        return yearComparison;
      }

      // Compare by month
      int monthComparison = a.date.month.compareTo(b.date.month);
      if (monthComparison != 0) {
        return monthComparison;
      }

      // Compate by day
      int dayCOmparison = a.date.day.compareTo(b.date.day);
      return dayCOmparison;
    });
  }

  void _filterEntries(int? month, int? year) {
    setState(() {
      //print("Hello world");
      diaryEntries = diaryEntries
          .where((log) => log.date.month == month && log.date.year == year)
          .toList();
    });
  }

  void _deleteEntry(LogModel entry) {
    logController.deleteEntry(entry);
    _loadDiaryEntry(); // Reload the list after deletion
  }

  bool _isDifferentMonthYear(int index) {
    //To help break to a new group
    if (index == 0) {
      return true; // Always show for the first log
    }

    final currentLog = diaryEntries[index];
    final previousLog = diaryEntries[index - 1];

    // Compare the month and year of the current log with the previous log
    return currentLog.date.month != previousLog.date.month ||
        currentLog.date.year != previousLog.date.year;
  }

  Widget _ratingToStars(int rating) {
    final starIcon =
        Icon(Icons.star, color: Colors.amber); // Star icon with amber color
    final emptyStarIcon = Icon(Icons.star_border,
        color: Colors.amber); // Empty star icon with amber color

    // Create a list of star icons based on the rating
    final stars = List<Widget>.generate(5, (index) {
      if (index < rating) {
        return starIcon;
      } else {
        return emptyStarIcon;
      }
    });

    return Row(
      children: stars,
    );
  }

  Widget _buildLogEntry(LogModel entry, int index) {
    return Row(
      children: [
        // Rating Icons
        _ratingToStars(entry.rating),
        Padding(
          padding: EdgeInsets.only(left: 32.0),
        ),
        //Delete Icom
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            _deleteEntry(entry);
          },
        ),
      ],
    );
  }

  PopupMenuButton<String> _buildPopupMenuButton() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert), // Three-dot vertical icon
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'export_pdf',
            child: Text('Export PDF'),
          ),
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
      onSelected: (String choice) {
        if (choice == 'export_pdf') {
          // Handle PDF export action
          _exportLogsToPDF(diaryEntries);
        } else if (choice == 'filter') {
          // Handle filter action
          _showFilterDialog();
        } else if (choice == 'reset filter') {
          // Handle filter action
          _loadDiaryEntry();
        }
      },
    );
  }

  Future<void> _showFilterDialog() async {
    int? selectedMonth = DateTime.now().month; // Default to the current month
    int? selectedYear = DateTime.now().year; // Default to the current year

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Logs'),
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
                  setState(() {
                    selectedMonth = value;
                  });
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
                  setState(() {
                    selectedYear = value;
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                // Filter logs for the selected month and year
                Navigator.of(context).pop();
                _filterEntries(selectedMonth, selectedYear);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportLogsToPDF(List<LogModel> logEntries) async {
    final pdf = pw.Document();

    // Define a title for the PDF
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return [
          pw.Header(
            level: 0,
            child: pw.Text('Diary Log Entries'),
          ),
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Date', 'Description', 'Rating'],
              for (var entry in logEntries)
                <String>[
                  DateFormat('MMMM dd, y').format(entry.date),
                  entry.description,
                  entry.rating.toString(),
                ],
            ],
          ),
        ];
      },
    ));

    // Save the PDF to a file
    final file = File('diary_log.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    //var diaryEntries = logController.getAllEntries();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Log'),
        actions: [
          _buildPopupMenuButton(),
        ],
      ),
      body: ListView.builder(
          itemCount: diaryEntries.length,
          itemBuilder: (BuildContext context, int index) {
            final entry = diaryEntries[index];
            final formattedDate = DateFormat('E, d').format(entry.date);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isDifferentMonthYear(index))
                  Column(children: [
                    const Divider(
                      color: Colors.grey,
                      thickness: 2.0,
                      height: 0,
                    ),
                    //Month and Year
                    Text(DateFormat('MMMM, y').format(entry.date),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        )),
                  ]),
                // Day
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // Description
                Text(entry.description,
                    style: TextStyle(
                      fontSize: 18,
                    )),
                _buildLogEntry(entry, index),
              ],
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DiaryEntryScreen(
                      onLogAdded: () {
                        _loadDiaryEntry();
                      },
                    )),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
