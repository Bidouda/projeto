import 'package:flutter/material.dart';
import 'control.dart'; // Assuming this is where your database service is located

class DetailPage extends StatefulWidget {
  final int idEntrada;

  DetailPage({required this.idEntrada});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic>? entrada;

  @override
  void initState() {
    super.initState();
    _loadEntrada();
  }

  void _loadEntrada() async {
    final control = Control(); // Create an instance of Control
    entrada = await control.getEntradaById(widget.idEntrada);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (entrada == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Detail Page'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              children: entrada?.entries.map((entry) =>
                  TextFormField(
                    initialValue: entry.value.toString(),
                    decoration: InputDecoration(labelText: entry.key),
                  ),
              ).toList() ?? const [],
            ),
          ),
        ),
      ),
    );
  }
}
