import "package:hive/hive.dart";

part 'logmodel.g.dart';

@HiveType(typeId: 0)
class LogModel extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String description;

  @HiveField(2)
  int rating;

  LogModel(
      {required this.date, required this.description, required this.rating});
}
