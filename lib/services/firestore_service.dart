import 'package:cloud_firestore/cloud_firestore.dart';
import '/model/logmodel.dart';

class FirestoreService {
  final CollectionReference logCollection;

  FirestoreService(String userId)
      : logCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('logs');

  // Methods for Firestore operations

  Future<DocumentReference<Object?>> addEntry(LogModel log) async {
    try {
      return await logCollection.add(log.toMap());
    } catch (e) {
      print('Error adding entry: $e');
      rethrow; // Rethrow the exception after logging it
    }
  }

  Future<void> updateEntry(LogModel updatedEntry) async {
    await logCollection.doc(updatedEntry.id).update(updatedEntry.toMap());
  }

  Future<void> deleteEntry(String id) async {
    await logCollection.doc(id).delete();
  }

  Stream<List<LogModel>> getAllEntries() {
    return logCollection
        .orderBy('date',
            descending: true) // Sort entries by date in descending order
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LogModel.fromMap(doc)).toList();
    });
  }

  Future<bool> entryExists(DateTime date) async {
    final QuerySnapshot logSnapshot =
        await logCollection.where('date', isEqualTo: date).get();

    return logSnapshot.docs.isNotEmpty;
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
    await logCollection.doc(entry.id).delete();
  }
}
