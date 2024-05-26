import 'package:flutter/material.dart';
import 'control.dart';
import 'detail_page.dart';
import 'main.dart'; // Import the main.dart file to access the routeObserver

class Book extends StatefulWidget {
  final String titulo;
  final int categoria;
  final int idGrupo;

  Book({required this.titulo, required this.categoria, required this.idGrupo});

  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> with RouteAware {
  late int _tipo;
  late int _autor;
  List<Map<String, dynamic>> _authors = [];
  bool _isBookAdded = false;
  late TextEditingController _tituloController;
  late TextEditingController _tituloBooksController;
  late int _categoria;
  late int _idGrupo;
  late TextEditingController _posicaoController;
  late TextEditingController _progressoController;
  late TextEditingController _totalController;
  late TextEditingController _inicioController;
  late TextEditingController _fimController;
  late bool _showInputFields = true;

  Control _dbService = Control();

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.titulo);
    _categoria = widget.categoria;
    _idGrupo = widget.idGrupo;
    _tituloBooksController = TextEditingController();
    _posicaoController = TextEditingController();
    _progressoController = TextEditingController();
    _totalController = TextEditingController();
    _inicioController = TextEditingController();
    _fimController = TextEditingController();

    _tipo = 1;
    _autor = 1;
    _loadAuthors();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute as PageRoute);
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _posicaoController.dispose();
    _progressoController.dispose();
    _totalController.dispose();
    _inicioController.dispose();
    _fimController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _loadAuthors() async {
    final authors = await _dbService.getAllAuthors();
    setState(() {
      _authors = authors;
    });
  }

  void _updateGrupo() async {
    await _dbService.updateGrupo(_idGrupo, _tituloController.text, _categoria);
    print('Group updated!');
  }

  void _deleteGrupo() async {
    await _dbService.deleteGrupo(widget.idGrupo);
    setState(() {
      // Optionally, update the UI or show a confirmation message
    });
    print('Grupo deletado!');
    Navigator.pop(context); // Navigate back to the previous screen
  }

  bool _addingAnother = false;

  void _insertEntrada() async {
    Map<String, dynamic> entrada = {
      'titulo': _tituloBooksController.text,
      'grupo': _idGrupo,
      'categoria': _categoria,
      'tipo': _tipo,
      'autor': _autor,
      'posicao': int.tryParse(_posicaoController.text) ?? 0,
      'progresso': int.tryParse(_progressoController.text) ?? 0,
      'total': int.tryParse(_totalController.text) ?? 0,
      'inicio': _inicioController.text,
      'fim': _fimController.text,
    };

    if (!_addingAnother) {
      await _dbService.insertEntrada(entrada);
      setState(() {
        _addingAnother = true;
        // Clear text fields
        _tituloBooksController.clear();
        _posicaoController.clear();
        _progressoController.clear();
        _totalController.clear();
        _inicioController.clear();
        _fimController.clear();
        // Reset dropdown values
        _tipo = 1;
        _autor = 1;
        _showInputFields = false; // Hide input fields after adding entry
      });
      print('Entrada inserida!');
    } else {
      setState(() {
        _addingAnother = false;
        _showInputFields = true; // Show input fields when adding another
      });
    }
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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Group'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _refreshPage,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Info'),
              Tab(text: 'Insert'),
              Tab(text: 'Books'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
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
                        onPressed: _updateGrupo, // Call the update method here
                        child: Text('Edit'),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          _deleteGrupo();  // Call the delete method here
                        },
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Title:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _tituloBooksController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter title',
                      ),
                      enabled: _showInputFields,
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
                      enabled: _showInputFields,
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
                      enabled: _showInputFields,
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
                      enabled: _showInputFields,
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
                            enabled: _showInputFields,
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _showInputFields
                              ? () {
                            _selectDate(context, _inicioController); // Call _selectDate method
                          }
                              : null,
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
                            enabled: _showInputFields,
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _showInputFields
                              ? () {
                            _selectDate(context, _fimController); // Call _selectDate method
                          }
                              : null,
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
                      onChanged: _showInputFields
                          ? (value) {
                        setState(() {
                          _tipo = value!;
                        });
                      }
                          : null,
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
                      onChanged: _showInputFields
                          ? (value) {
                        setState(() {
                          _autor = value!;
                        });
                      }
                          : null,
                      items: _authors.map((author) {
                        return DropdownMenuItem<int>(
                          value: author['id_autor'],
                          child: Text(author['descricao_autor']),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _insertEntrada();
                        },
                        child:
                        Text(_addingAnother ? 'Add Another' : 'Add Entry'),
                      ),
                    ),
                    Visibility(
                      visible: _isBookAdded,
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Book added',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _dbService.queryFindGrupo(_idGrupo),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No books found.'));
                }

                final books = snapshot.data!;

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16), // Updated margin
                            child: ListTile(
                              leading: Icon(Icons.book), // Updated leading icon
                              title: Text(book['titulo'],
                                  style: TextStyle(fontWeight: FontWeight.bold)), // Updated title style
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text('Position: ${book['posicao']}'),
                                ],
                              ), // Updated subtitle
                              trailing: Icon(Icons.arrow_forward), // Added trailing icon
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPage(idEntrada: book['id_entrada']),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _refreshPage() {
    _loadAuthors();
    setState(() {});
  }

  @override
  void didPopNext() {
    _refreshPage();
  }
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1);
  }
}
