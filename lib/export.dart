import 'package:flutter/material.dart';
import 'control.dart'; // Import the Control class from control.dart

class ExportPage extends StatelessWidget {
  const ExportPage({Key? key}) : super(key: key);

  Future<void> _exportDatabase(BuildContext context) async {
    try {
      Control control = Control();
      await control.startDatabase(); // Make sure the database is opened

      // Call the exportToSQL function from the Control class
      await control.exportToSQL();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database exported to SQL file.'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print("Error exporting database: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error exporting database.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _exportDatabase(context); // Call the export function when the button is pressed
          },
          child: Text('Export Database'),
        ),
      ),
    );
  }
}
