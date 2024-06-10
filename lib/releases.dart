import 'package:flutter/material.dart';

class ReleasesPage extends StatelessWidget {
  const ReleasesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Releases'),
      ),
      body: Center(
        child: Text(
          'Releases Page Content',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}