import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import "/model/logmodel.dart";

class LogController {
  // final AuthService _authService = AuthService();
  // late FirestoreService _firestoreService;

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

  Future<String?> uploadImageToStorage(XFile image, String userId) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference storageRef =
        storage.ref().child('images/$userId/${image.name}');

    try {
      final uploadTask = await storageRef.putFile(File(image.path));

      if (uploadTask.state == TaskState.success) {
        final String downloadURL = await storageRef.getDownloadURL();
        return downloadURL;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
    return null;
  }

  Future<String?> loadImageStorage(String imageUrl) async {
    if (imageUrl.isNotEmpty) {
      try {
        final ref = FirebaseStorage.instance.ref(imageUrl);
        return await ref.getDownloadURL();
      } catch (e) {
        print('Error loading image from Firebase Storage: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> deleteImageFromStorage(String imageUrl) async {
    Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);
    await ref.delete();
  }

  // Other methods and functionalities
  DateTime getDatetime(LogModel log) {
    return DateTime.parse(log.date.toDate().toString());
  }

  Timestamp getTimestamp(DateTime date) {
    return Timestamp.fromDate(date);
  }
}
