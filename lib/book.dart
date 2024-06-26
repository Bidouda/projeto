import 'package:flutter/material.dart';
import 'control.dart';
import 'detail_page.dart';
import 'create_release.dart';
import 'main.dart'; // Import the main.dart file to access the routeObserver

class Book extends StatefulWidget {
  final String titulo;
  final int categoria;
  final int idGrupo;

  const Book({super.key, required this.titulo, required this.categoria, required this.idGrupo});

  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> with RouteAware {
  late int _rating; // Add this to hold the rating value
  late int _tipo;
  late int _autor;
  List<Map<String, dynamic>> _authors = [];
  final bool _isBookAdded = false;
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

  final Control _dbService = Control();

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
    _rating = 1; // Initialize rating
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
      if (_authors.isNotEmpty) {
        _autor = _authors.first['id_autor']; // Ensure _autor is set to a valid initial value
      }
    });
  }

  void _updateGrupo() async {
    await _dbService.updateGrupo(_idGrupo, _tituloController.text, _categoria);
    print('Group updated!');

    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Group updated successfully!'),
      ),
    );
  }

  final TextEditingController _selectedAuthorController = TextEditingController();

  void _selectAuthor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Author',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _authors.length,
                itemBuilder: (context, index) {
                  final author = _authors[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _autor = author['id_autor'];
                        _selectedAuthorController.text = author['descricao_autor'];
                      });
                      Navigator.pop(context); // Close the bottom sheet when an author is selected
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.blue),
                          const SizedBox(width: 10.0),
                          Text(
                            author['descricao_autor'],
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteGrupo() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this group?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _dbService.deleteGrupo(widget.idGrupo);
                setState(() {
                  // Optionally, update the UI or show a confirmation message
                });
                print('Grupo deletado!');
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Navigate back to the previous screen
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }


  bool _addingAnother = false;

  void _insertEntrada() async {
    Map<String, dynamic> entrada = {
      'titulo': _tituloBooksController.text,
      'grupo': _idGrupo,
      'categoria': _categoria,
      'tipo': _tipo,
      'autor': _autor,
      'posicao': double.tryParse(_posicaoController.text) ?? 0,
      'progresso': double.tryParse(_progressoController.text) ?? 0,
      'total': double.tryParse(_totalController.text) ?? 0,
      'inicio': _inicioController.text,
      'fim': _fimController.text,
      'notas': _rating, // Add rating to the entrada map
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
        _rating = 1; // Reset rating
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
          title: const Text('Group'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateReleasePage(idGrupo: widget.idGrupo)),
                );
              },
            ),
          ],
          bottom: const TabBar(
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Titulo:',
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
                    'Categoria:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<int>(
                    key: UniqueKey(),
                    value: _categoria,
                    onChanged: (value) {
                      setState(() {
                        _categoria = value!;
                      });
                    },
                    items: const [
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _updateGrupo, // Call the update method here
                        child: const Text('Edit'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          _deleteGrupo();  // Call the delete method here
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Title:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tituloBooksController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter title',
                      ),
                      enabled: _showInputFields,
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
                      enabled: _showInputFields,
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
                      enabled: _showInputFields,
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
                      enabled: _showInputFields,
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
                          child: GestureDetector(
                            onTap: () {}, // Prevents selection
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _inicioController,
                                readOnly: true, // Makes the field read-only
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter start date',
                                ),
                                enabled: _showInputFields, // This controls whether the field should be active
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _showInputFields
                              ? () {
                            _selectDate(context, _inicioController); // Call _selectDate method
                          }
                              : null,
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
                          child: GestureDetector(
                            onTap: () {}, // Prevents selection
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _fimController,
                                readOnly: true, // Makes the field read-only
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter end date',
                                ),
                                enabled: _showInputFields, // This controls whether the field should be active
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _showInputFields
                              ? () {
                            _selectDate(context, _fimController); // Call _selectDate method
                          }
                              : null,
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
                      key: UniqueKey(),
                      value: _tipo,
                      onChanged: _showInputFields
                          ? (value) {
                        setState(() {
                          _tipo = value!;
                        });
                      }
                          : null,
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
                    const Text(
                      'Rating:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      value: _rating,
                      onChanged: (int? newValue) {
                        setState(() {
                          _rating = newValue!;
                        });
                      },
                      items: List.generate(5, (index) {
                        return DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text((index + 1).toString()),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    const Text(
                      'Author:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _selectedAuthorController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2.0),
                              ),
                              enabled: false,
                              hintText: 'Selected author',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10), // Add some spacing between the text field and the button
                        ElevatedButton(
                          onPressed: _showInputFields ? () => _selectAuthor(context) : null,
                          child: const Text('Select Author'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _insertEntrada();
                        },
                        child: Text(_addingAnother ? 'Add Another' : 'Add Entry'),
                      ),
                    ),
                    Visibility(
                      visible: _isBookAdded,
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
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
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No books found.'));
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
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16), // Updated margin
                            child: ListTile(
                              leading: const Icon(Icons.book), // Updated leading icon
                              title: Text(book['titulo'],
                                  style: const TextStyle(fontWeight: FontWeight.bold)), // Updated title style
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Position: ${book['posicao']}'),
                                ],
                              ), // Updated subtitle
                              trailing: const Icon(Icons.arrow_forward), // Added trailing icon
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
    return this[0].toUpperCase() + substring(1);
  }
}
