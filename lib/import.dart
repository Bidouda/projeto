import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'control.dart'; // Import your Control class

class ImportExportPage extends StatelessWidget {
  const ImportExportPage({Key? key}) : super(key: key);

  Future<void> _importDatabase(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['sql'], // Allow only database files
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        Control control = Control();
        await control.importDatabase(file);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database imported successfully.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print("Error importing database: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error importing database.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                Control().clearDatabases(); // Call clearDatabases method before import
                await _importDatabase(context); // Call the import function when the button is pressed
              },
              child: Text('Replace Database'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _importDatabase(context); // Call the import function when the button is pressed
              },
              child: Text('Import Database'),
            ),
          ],
        ),
      ),
    );
  }
}
