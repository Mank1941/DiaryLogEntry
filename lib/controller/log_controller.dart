import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import "/model/logmodel.dart";

class LogController {
  var box = Hive.box('logs_box');

  bool addEntry(LogModel log) {
    //Conflict: date already exists
    DateTime targetDate = log.date;
    bool dateExists = box.values.any((existingLog) =>
        existingLog.date.day == log.date.day &&
        existingLog.date.month == log.date.month &&
        existingLog.date.year == log.date.year);

    //print("Does it? $dateExists");

    if (dateExists) {
      //print('Date already exists in the box.');
      return false;
    }

    box.add(log);
    return true; //Task Completed
  }

  bool deleteEntry(LogModel entry) {
    int index = box.values.toList().indexOf(entry);

    try {
      if (index != -1) {
        box.deleteAt(index);
        return true; // Deletion successful
      }
      return false; // Entry not found
    } catch (e) {
      return false; // An exception occurred, so the deletion failed
    }
  }

  void printEntries() {
    List<LogModel> logEntries = getAllEntries();
    for (var entry in logEntries) {
      final formattedDate = DateFormat('dd, MMM, yyyy').format(entry.date);
      print('Date: $formattedDate');
      print('Description: ${entry.description}');
      print('-------------------------');
    }
  }

  List<LogModel> getAllEntries() {
    return box.values.cast<LogModel>().toList();
  }
}
