import 'package:flutter/material.dart';
import 'control.dart'; // Import the database service class

class Book extends StatefulWidget {
  final String titulo;
  final int categoria;
  final int idGrupo; // Add idGrupo parameter

  Book({required this.titulo, required this.categoria, required this.idGrupo}); // Receive idGrupo as part of the constructor

  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> {
  late TextEditingController _tituloController;
  late TextEditingController _tituloBooksController;
  late int _categoria;
  late int _idGrupo; // Store idGrupo in widget's state

  late TextEditingController _posicaoController;
  late TextEditingController _progressoController;
  late TextEditingController _totalController;
  late TextEditingController _inicioController;
  late TextEditingController _fimController;

  late int _tipo;
  late int _autor;

  Control _dbService = Control(); // Instantiate the database service

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.titulo); // Info tab controller
    _categoria = widget.categoria;
    _idGrupo = widget.idGrupo; // Store idGrupo from widget's constructor in state
    _tituloBooksController = TextEditingController();
    _posicaoController = TextEditingController();
    _progressoController = TextEditingController();
    _totalController = TextEditingController();
    _inicioController = TextEditingController();
    _fimController = TextEditingController();

    _tipo = 1; // Initialize with default value
    _autor = 1; // Initialize with default value
    // New controller for Books tab's title
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

  void _insertEntrada() async {
    Map<String, dynamic> entrada = {
      'titulo': _tituloBooksController.text, // Add 'titulo' parameter
      'grupo': _idGrupo,
      'categoria': _categoria,
      'tipo': _tipo,
      'autor': _autor,
      'posicao': int.tryParse(_posicaoController.text),
      'progresso': int.tryParse(_progressoController.text),
      'total': int.tryParse(_totalController.text),
      'inicio': _inicioController.text,
      'fim': _fimController.text,
    };

    await _dbService.insertEntrada(entrada);
    print('Entrada inserida!');
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Group'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Info'),
              Tab(text: 'Books'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Info Tab
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Titulo:',
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
                    'Categoria:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  DropdownButton<int>(
                    value: _categoria,
                    onChanged: (value) {
                      setState(() {
                        _categoria = value!;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: 1,
                        child: Text('Current'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('Paused'),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text('Completed'),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: Text('Dropped'),
                      ),
                      DropdownMenuItem(
                        value: 5,
                        child: Text('Planning'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Placeholder for Edit button action
                        },
                        child: Text('Edit'),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Placeholder for Delete button action
                        },
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Books Tab
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Titulo:', // Add this text field
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _tituloBooksController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter title',
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Posição:',
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
                      'Start:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextField(
                        controller: _inicioController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter start date',
                        )
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDate(context, _inicioController),
                      child: Text('Select Start Date'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'End:',
                      style: TextStyle(fontSize:                  18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextField(
                        controller: _fimController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter end date',
                        )
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDate(context, _fimController),
                      child: Text('Select End Date'),
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
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _dbService.getAllAuthors(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final authors = snapshot.data!;
                          return DropdownButton<int>(
                            value: _autor,
                            onChanged: (value) {
                              setState(() {
                                _autor = value!;
                              });
                            },
                            items: authors.map((author) {
                              return DropdownMenuItem<int>(
                                value: author['id_autor'],
                                child: Text(author['descricao_autor']),
                              );
                            }).toList(),
                          );
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        }
                        // By default, show a loading spinner.
                        return CircularProgressIndicator();
                      },
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _insertEntrada,
                        child: Text('Add Entry'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

