import 'package:flutter/material.dart';
import 'control.dart';
import 'grupo.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  final _tituloController = TextEditingController();
  int? _selectedCategoria; // Use a nullable int for the dropdown selection
  bool _showSuccessCard = false;
  bool _showErrorCard = false;
  String? _errorMessage;

  Future<void> _insertGrupo(String titulo, int categoria) async {
    Control control = new Control();
    Grupo grupo = Grupo(titulo: titulo, categoria: categoria);
    await control.insertDatabase(grupo);
  }

  void _handleSuccess() {
    setState(() {
      _showSuccessCard = true;
      _showErrorCard = false;
    });
  }

  void _handleError(String message) {
    setState(() {
      _showSuccessCard = false;
      _showErrorCard = true;
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            DropdownButtonFormField(
              value: _selectedCategoria, // Set initial value
              items: [
                DropdownMenuItem(
                  child: Text("Current"),
                  value: 1, // Assuming category IDs start from 1
                ),
                DropdownMenuItem(
                  child: Text("Paused"),
                  value: 2,
                ),
                DropdownMenuItem(
                  child: Text("Completed"),
                  value: 3,
                ),
                DropdownMenuItem(
                  child: Text("Dropped"),
                  value: 4,
                ),
                DropdownMenuItem(
                  child: Text("Planning"),
                  value: 5,
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoria = value as int;
                });
              },
              hint: Text("Select Category"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_tituloController.text.isNotEmpty && _selectedCategoria != null) {
                  await _insertGrupo(_tituloController.text, _selectedCategoria!);
                  _handleSuccess();
                } else {
                  _handleError("Please enter a title and select a category.");
                }
              },
              child: Text("Create"),
            ),
            if (_showSuccessCard)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Group created successfully!"),
                ),
              ),
            if (_showErrorCard)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_errorMessage!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
