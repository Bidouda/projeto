import 'package:flutter/material.dart';
import 'control.dart';
import 'grupo.dart';

class Create extends StatefulWidget {
  const Create({Key? key}) : super(key: key);

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
        title: Text("Create"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
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
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _tituloController,
            decoration: InputDecoration(
              labelText: "Title",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          DropdownButtonFormField(
            value: _selectedCategoria,
            items: [
              DropdownMenuItem(
                child: Text("Current"),
                value: 1,
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
                _selectedCategoria = value as int?;
              });
            },
            decoration: InputDecoration(
              labelText: "Select Category",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_tituloController.text.isNotEmpty && _selectedCategoria != null) {
                await _insertGrupo(_tituloController.text, _selectedCategoria!);
                _handleSuccess("Group created successfully!");
              } else {
                _handleError("Please enter a title and select a category.");
              }
            },
            child: Text("Create"),
          ),
          SizedBox(height: 20),
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
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _autorController,
            decoration: InputDecoration(
              labelText: "Author Name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_autorController.text.isNotEmpty) {
                await _insertAutor(_autorController.text);
                _handleSuccess("Author created successfully!");
              } else {
                _handleError("Please enter an author name.");
              }
            },
            child: Text("Create"),
          ),
          SizedBox(height: 20),
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
