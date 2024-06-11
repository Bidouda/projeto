import 'package:flutter/material.dart';
import 'control.dart';
import 'package:intl/intl.dart';

class CreateReleasePage extends StatefulWidget {
  final int idGrupo;
  final Control _dbService = Control();

  CreateReleasePage({required this.idGrupo});

  @override
  _CreateReleasePageState createState() => _CreateReleasePageState();
}

class _CreateReleasePageState extends State<CreateReleasePage> {
  TextEditingController _tituloController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Release'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _tituloController.text.isNotEmpty && _selectedDate != null
                ? () {
              _showConfirmationDialog();
            }
                : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter title',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Release Date:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () {
                _selectDate(context);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select release date',
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}'
                          : 'Select release date',
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Are you sure you want to save this release?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel"
              ),
            ),
            TextButton(
              onPressed: () async {
                await _insertLancamento();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Release saved successfully!'),
                  ),
                );
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _insertLancamento() async {
    String titulo = _tituloController.text;
    String lancamento = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : '';

    await widget._dbService.insertLancamento(widget.idGrupo, titulo, lancamento);
    print('Lançamento inserido!');
  }
}
