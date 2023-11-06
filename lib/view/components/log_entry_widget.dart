import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/logmodel.dart';

class LogEntryWidget extends StatelessWidget {
  final LogModel entry;
  final Function onDelete;

  LogEntryWidget({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        print('Long Press Registered');
        // edit the tile
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade900),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EE, MMM d').format(
                      DateTime.parse(entry.date.toDate().toString()).toLocal()),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      color: index < entry.rating
                          ? Colors.deepPurple
                          : Colors.grey,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => onDelete(),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              entry.description,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
