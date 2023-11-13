import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/logmodel.dart';
import '../controller/log_controller.dart';
import 'log_edit_view.dart'; // Import your LogEditScreen

class LogDetailScreen extends StatefulWidget {
  final LogModel entry;

  LogDetailScreen({Key? key, required this.entry}) : super(key: key);

  @override
  _LogDetailScreenState createState() => _LogDetailScreenState();
}

class _LogDetailScreenState extends State<LogDetailScreen> {
  final LogController logController = LogController();
  late LogModel entry;

  @override
  void initState() {
    super.initState();
    entry = widget.entry;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedEntry = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogEditScreen(entry: entry),
                ),
              );
              if (updatedEntry != null) {
                setState(() {
                  entry = updatedEntry;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Show a confirmation dialog before deleting
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Entry'),
                    content: const Text(
                        'Are you sure you want to delete this entry?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Perform deletion here
                          // Call a function to delete the entry or use your preferred method
                          // Example: widget.logController.deleteEntry(entry);
                          logController.deleteEntryByEntry(entry);
                          Navigator.pop(context); // Close the dialog
                          Navigator.pop(context); // Close the LogDetailScreen
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade900),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EE, MMM d').format(
                DateTime.parse(entry.date.toDate().toString()).toLocal(),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  color: index < entry.rating ? Colors.deepPurple : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              entry.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            if (entry.imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Image.network(entry.imageUrl!,
                    height: 200, fit: BoxFit.cover),
              )
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(8.0),
            //   child: Image.network(
            //     entry.imageUrl,
            //     height: 100,
            //     width: double.infinity,
            //     fit: BoxFit.cover,
            //   ),
            // ),
            // FutureBuilder<String?>(
            //     future: logController.loadImageStorage(entry.imageUrl),
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return CircularProgressIndicator(); // or a placeholder widget
            //       } else if (snapshot.hasError || snapshot.data == null) {
            //         return const Text('Error loading image');
            //       } else {
            //         return Image.network(
            //           snapshot.data!,
            //           height: 100,
            //           width: double.infinity,
            //           fit: BoxFit.cover,
            //         );
            //       }
            //     })
          ],
        ),
      ),
    );
  }
}
