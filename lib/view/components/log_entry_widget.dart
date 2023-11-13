import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/logmodel.dart';
import '../log_detail_view.dart';

class LogEntryWidget extends StatelessWidget {
  final LogModel entry;
  final Function onDelete;

  const LogEntryWidget({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        //print('Long Press Registered');
        // edit the tile
      },
      onTap: () {
        entry.printDetails();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LogDetailScreen(entry: entry),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
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
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
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
                  icon: const Icon(Icons.delete),
                  onPressed: () => onDelete(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              entry.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            if (entry.imageUrl.isNotEmpty)
              Image.network(entry.imageUrl, height: 100, width: 100),
          ],
        ),
      ),
    );
  }
}
