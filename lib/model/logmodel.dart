import "package:cloud_firestore/cloud_firestore.dart";
import "package:hive/hive.dart";

part 'logmodel.g.dart';

class LogModel extends HiveObject {
  final String? id;
  final Timestamp date;
  late final String description;
  final int rating;

  LogModel(
      {this.id,
      required this.date,
      required this.description,
      required this.rating});

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'description': description,
      'rating': rating,
    };
  }

  static LogModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return LogModel(
      id: doc.id,
      date: map['date'] ?? Timestamp.now(),
      description: map['description'] ?? '',
      rating: map['rating'] ?? 3,
    );
  }
}
