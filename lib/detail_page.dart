import 'package:flutter/material.dart';
import 'control.dart'; // Assuming this is where your database service is located
import 'rereads.dart';

class DetailPage extends StatefulWidget {
  final int idEntrada;

  const DetailPage({super.key, required this.idEntrada});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic>? entrada;
  final Control _dbService = Control();
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry updated')));
  }

  void _deleteEntrada() async {
    await _dbService.deleteEntrada(widget.idEntrada);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry deleted')));
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
        title: const Text('Detail Page'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                'Position:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _posicaoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter position',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text(
                'Progress:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _progressoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter progress',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _totalController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter total',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text(
                'Start Date:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inicioController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter start date',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      _selectDate(context, _inicioController); // Call _selectDate method
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Select Start Date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'End Date:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fimController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter end date',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      _selectDate(context, _fimController); // Call _selectDate method
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Select End Date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Type:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButton<int>(
                value: _tipo,
                onChanged: (value) {
                  setState(() {
                    _tipo = value!;
                  });
                },
                items: const [
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
              const SizedBox(height: 20),
              const Text(
                'Author:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _editEntrada,
                    child: const Text('Edit'),
                  ),
                  ElevatedButton(
                    onPressed: _deleteEntrada,
                    child: const Text('Delete'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RereadsPage(idEntrada: widget.idEntrada)),
                      );
                    },
                    child: const Text('Rereads'),
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