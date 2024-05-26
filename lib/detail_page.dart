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
  Control _dbService = Control();
  List<Map<String, dynamic>> _authors = [];
  bool _isLoading = true;

  late TextEditingController _tituloController;
  late TextEditingController _posicaoController;
  late TextEditingController _progressoController;
  late TextEditingController _totalController;
  late TextEditingController _inicioController;
  late TextEditingController _fimController;
  late int _tipo;
  late int _autor;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController();
    _posicaoController = TextEditingController();
    _progressoController = TextEditingController();
    _totalController = TextEditingController();
    _inicioController = TextEditingController();
    _fimController = TextEditingController();
    _loadAuthors();
    _loadEntrada();
  }

  void _loadEntrada() async {
    entrada = await _dbService.getEntradaById(widget.idEntrada);
    setState(() {
      _tituloController.text = entrada?['titulo'] ?? '';
      _posicaoController.text = entrada?['posicao'].toString() ?? '';
      _progressoController.text = entrada?['progresso'].toString() ?? '';
      _totalController.text = entrada?['total'].toString() ?? '';
      _inicioController.text = entrada?['inicio'] ?? '';
      _fimController.text = entrada?['fim'] ?? '';
      _tipo = entrada?['tipo'] ?? 1;
      _autor = entrada?['autor'] ?? 1;
      _isLoading = false;
    });
  }

  void _loadAuthors() async {
    final authors = await _dbService.getAllAuthors();
    setState(() {
      _authors = authors;
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        final formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        controller.text = formattedDate; // Update the text field with the selected date
      });
    }
  }

  void _editEntrada() async {
    final updatedData = {
      'titulo': _tituloController.text,
      'posicao': int.tryParse(_posicaoController.text) ?? 0,
      'progresso': int.tryParse(_progressoController.text) ?? 0,
      'total': int.tryParse(_totalController.text) ?? 0,
      'inicio': _inicioController.text,
      'fim': _fimController.text,
      'tipo': _tipo,
      'autor': _autor,
    };
    await _dbService.updateEntrada(widget.idEntrada, updatedData);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Entry updated')));
  }

  void _deleteEntrada() async {
    await _dbService.deleteEntrada(widget.idEntrada);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Entry deleted')));
    Navigator.pop(context); // Go back to the previous screen
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _posicaoController.dispose();
    _progressoController.dispose();
    _totalController.dispose();
    _inicioController.dispose();
    _fimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Page'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                'Position:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _posicaoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter position',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Text(
                'Progress:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _progressoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter progress',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _totalController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter total',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Text(
                'Start Date:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inicioController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter start date',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      _selectDate(context, _inicioController); // Call _selectDate method
                    },
                    icon: Icon(Icons.calendar_today),
                    label: Text('Select Start Date'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'End Date:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fimController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter end date',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      _selectDate(context, _fimController); // Call _selectDate method
                    },
                    icon: Icon(Icons.calendar_today),
                    label: Text('Select End Date'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Type:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButton<int>(
                value: _tipo,
                onChanged: (value) {
                  setState(() {
                    _tipo = value!;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Novel'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Novella'),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('Short Story'),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: Text('Graphic Novel'),
                  ),
                  DropdownMenuItem(
                    value: 5,
                    child: Text('Drama & Poetry'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Author:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButton<int>(
                value: _autor,
                onChanged: (value) {
                  setState(() {
                    _autor = value!;
                  });
                },
                items: _authors.map((author) {
                  return DropdownMenuItem<int>(
                    value: author['id_autor'],
                    child: Text(author['descricao_autor']),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _editEntrada,
                    child: Text('Edit'),
                  ),
                  ElevatedButton(
                    onPressed: _deleteEntrada,
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}