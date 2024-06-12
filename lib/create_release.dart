import 'package:flutter/material.dart';
import 'control.dart';
import 'package:intl/intl.dart';

class CreateReleasePage extends StatefulWidget {
  final int idGrupo;
  final Control _dbService = Control();

  CreateReleasePage({super.key, required this.idGrupo});

  @override
  _CreateReleasePageState createState() => _CreateReleasePageState();
}

class _CreateReleasePageState extends State<CreateReleasePage> {
  final TextEditingController _tituloController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Release'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
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
            const Text(
              'Title:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter title',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Release Date:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                _selectDate(context);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
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
                    const Icon(Icons.calendar_today),
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
          title: const Text("Confirmation"),
          content: const Text("Are you sure you want to save this release?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel"
              ),
            ),
            TextButton(
              onPressed: () async {
                await _insertLancamento();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Release saved successfully!'),
                  ),
                );
              },
              child: const Text("Save"),
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
