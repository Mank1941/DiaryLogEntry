import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import "/model/logmodel.dart";
import "package:assignment2_2/services/auth_service.dart";
import 'package:assignment2_2/services/firestore_service.dart';

class LogController {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference logCollection;

  //Construct initializes the refence to the Firestore collection
  LogController()
      : logCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('logs');

  Future<DocumentReference<Object?>> addEntry(LogModel log) async {
    try {
      return await logCollection.add(log.toMap());
    } catch (e) {
      print('Error adding entry: $e');
      rethrow; // Rethrow the exception after logging it
    }
  }

  Future<void> updateEntry(LogModel updatedEntry) async {
    return await logCollection
        .doc(updatedEntry.id)
        .update(updatedEntry.toMap());
  }

  Future<void> deleteEntry(String id) async {
    return await logCollection.doc(id).delete();
  }

  Stream<List<LogModel>> getAllEntries() {
    return logCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => LogModel.fromMap(doc)).toList();
    });
  }

  void printEntries() {
    getAllEntries().listen((List<LogModel> logEntries) {
      for (var entry in logEntries) {
        final formattedDate =
            DateFormat('dd, MMM, yyyy').format(getDatetime(entry));
        print('Date: $formattedDate');
        print('Description: ${entry.description}');
        print('-------------------------');
      }
    });
  }

  Future<bool> entryExists(DateTime date) async {
    final QuerySnapshot logSnapshot =
        await logCollection.where('date', isEqualTo: date).get();

    return logSnapshot.docs.isNotEmpty;
  }

  DateTime getDatetime(LogModel log) {
    return DateTime.parse(log.date.toDate().toString());
  }

  Timestamp getTimestamp(DateTime date) {
    return Timestamp.fromDate(date);
  }

  Future<List<LogModel>> filterEntries(
      bool filter, int dateMonth, int dateYear) async {
    final DateTime startDate = DateTime(dateYear, dateMonth, 1);
    final DateTime endDate =
        DateTime(dateYear, dateMonth + 1, 1).subtract(Duration(days: 1));

    final QuerySnapshot logSnapshot = await logCollection
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .get();

    return logSnapshot.docs.map((doc) => LogModel.fromMap(doc)).toList();
  }

  Future<void> deleteEntryByEntry(LogModel entry) async {
    return await logCollection.doc(entry.id).delete();
  }
}
