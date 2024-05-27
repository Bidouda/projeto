import 'package:flutter/material.dart';
import 'control.dart';
import 'grupo.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> with SingleTickerProviderStateMixin {
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  int? _selectedCategoria;
  bool _showSuccessCard = false;
  bool _showErrorCard = false;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _insertGrupo(String titulo, int categoria) async {
    Control control = Control();
    Grupo grupo = Grupo(titulo: titulo, categoria: categoria);
    await control.insertDatabase(grupo);
  }

  Future<void> _insertAutor(String nome) async {
    Control control = Control();
    await control.insertAutor(nome);
  }

  void _handleSuccess(String message) {
    setState(() {
      _showSuccessCard = true;
      _showErrorCard = false;
      _errorMessage = message;
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
        title: const Text("Create"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Groups"),
            Tab(text: "Authors"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGroupsTab(),
          _buildAuthorsTab(),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _tituloController,
            decoration: const InputDecoration(
              labelText: "Title",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField(
            value: _selectedCategoria,
            items: const [
              DropdownMenuItem(
                value: 1,
                child: Text("Current"),
              ),
              DropdownMenuItem(
                value: 2,
                child: Text("Paused"),
              ),
              DropdownMenuItem(
                value: 3,
                child: Text("Completed"),
              ),
              DropdownMenuItem(
                value: 4,
                child: Text("Dropped"),
              ),
              DropdownMenuItem(
                value: 5,
                child: Text("Planning"),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategoria = value;
              });
            },
            decoration: const InputDecoration(
              labelText: "Select Category",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_tituloController.text.isNotEmpty && _selectedCategoria != null) {
                await _insertGrupo(_tituloController.text, _selectedCategoria!);
                _handleSuccess("Group created successfully!");
              } else {
                _handleError("Please enter a title and select a category.");
              }
            },
            child: const Text("Create"),
          ),
          const SizedBox(height: 20),
          if (_showSuccessCard)
            Card(
              color: Colors.green.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),
            ),
          if (_showErrorCard)
            Card(
              color: Colors.red.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _autorController,
            decoration: const InputDecoration(
              labelText: "Author Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_autorController.text.isNotEmpty) {
                await _insertAutor(_autorController.text);
                _handleSuccess("Author created successfully!");
              } else {
                _handleError("Please enter an author name.");
              }
            },
            child: const Text("Create"),
          ),
          const SizedBox(height: 20),
          if (_showSuccessCard)
            Card(
              color: Colors.green.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),
            ),
          if (_showErrorCard)
            Card(
              color: Colors.red.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }
}
