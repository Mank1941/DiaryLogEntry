import 'dart:math';

import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import "/model/logmodel.dart";

class LogController {
  final Box logBox;

  LogController(this.logBox);

  Future<bool> addEntry(LogModel log) async {
    //Conflict: date already exists
    DateTime targetDate = log.date;

    if (await entryExists(targetDate)) {
      //print('Date already exists in the box.');
      return false;
    }

    logBox.put(targetDate.toString(), log);
    return true; //Task Completed
  }

  Future<void> updateEntry(DateTime date, LogModel updatedEntry) async {
    if (!await entryExists(date)) {
      throw Exception('No entry found for this date');
    }
    await logBox.put(date.toString(), updatedEntry);
  }

  Future<bool> removeEntry(DateTime date) async {
    if (!await entryExists(date)) {
      //throw Exception('No entry found for this date');
      return false;
    }
    await logBox.delete(date.toString());
    return true;
  }

  Future<bool> entryExists(DateTime date) async {
    return logBox.containsKey(date.toString());
  }

  Future<List<LogModel>> searchEntries(String keyword) async {
    return logBox.values
        .cast<LogModel>()
        .where((entry) => entry.description.contains(keyword))
        .toList();
  }

  List<LogModel> filterEntries(bool filter, int dateMonth, int dateYear) {
    print(filter);
    if (filter) {
      print("Hello3");
      return logBox.values
          .cast<LogModel>()
          .where((entry) =>
              entry.date.year == dateYear && entry.date.month == dateMonth)
          .toList();
    }
    return getAllEntries();
  }

  void deleteEntry(int index) {
    logBox.deleteAt(index);
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
    return logBox.values.cast<LogModel>().toList();
  }

  Future<void> deleteEntryByEntry(LogModel entry) async {
    final key = logBox.keys
        .firstWhere((k) => logBox.get(k) == entry, orElse: () => null);
    if (key != null) {
      await logBox.delete(key);
    } else {
      print('Entry not found');
    }
  }
}

void main() async {
  Hive.init('path_to_hive_box'); // Initialize Hive
  Hive.registerAdapter(LogModelAdapter()); // Register your custom TypeAdapter

  var diaryBox = await Hive.openBox<LogModel>('diaryBox');
  var diaryController = LogController(diaryBox);

  // Now you can use diaryController to manage diary entries
}
