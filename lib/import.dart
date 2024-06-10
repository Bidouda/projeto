import 'package:flutter/material.dart';

class ImportExportPage extends StatelessWidget {
  const ImportExportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import'),
      ),
      body: Center(
        child: Text(
          'Import Page Content',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}