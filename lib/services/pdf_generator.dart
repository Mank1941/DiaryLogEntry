import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '/model/logmodel.dart';
import '/controller/log_controller.dart';

class PdfGenerator {
  final LogController logController = LogController();

  Future<void> generatePDF(List<LogModel> entries) async {
    final pdf = pw.Document();

    for (var entry in entries) {
      // Add a new page for each diary log entry
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text('Date: ${entry.date.toDate()}'),
                pw.Text('Description: ${entry.description}'),
                pw.Text('Rating: ${entry.rating}'),
                if (entry.imageUrl.isNotEmpty)
                  pw.Image(
                    pw.MemoryImage(File(entry.imageUrl).readAsBytesSync()),
                  ),
                // Add other details you want to include
              ],
            );
          },
        ),
      );
    }

    // Get the Documents directory path
    final documentsDirectoryPath = await getApplicationDocumentsDirectory();

    // Create the PDF file and write the content to it
    final pdfFile = File('${documentsDirectoryPath.path}/diary_logs.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    print('PDF file saved to: ${pdfFile.path}');
  }
}
