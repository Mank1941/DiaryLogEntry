import "package:cloud_firestore/cloud_firestore.dart";
import "package:hive/hive.dart";

//part 'logmodel.g.dart';

class LogModel extends HiveObject {
  String? id;
  Timestamp date;
  String description;
  int rating;
  String imageUrl;

  LogModel(
      {this.id,
      required this.date,
      required this.description,
      required this.rating,
      required this.imageUrl});

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'description': description,
      'rating': rating,
      'imageUrl': imageUrl,
    };
  }

  static LogModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return LogModel(
      id: doc.id,
      date: map['date'] ?? Timestamp.now(),
      description: map['description'] ?? '',
      rating: map['rating'] ?? 3,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  void printDetails() {
    print('ID: $id');
    print('Date: ${date.toDate().toString()}');
    print('Description: $description');
    print('Rating: $rating');
    print('Image URL: $imageUrl');
  }
}
