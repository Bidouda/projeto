import 'package:flutter/material.dart';

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
  late int _categoria;
  late int _idGrupo; // Store idGrupo in widget's state

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.titulo);
    _categoria = widget.categoria;
    _idGrupo = widget.idGrupo; // Store idGrupo from widget's constructor in state
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
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
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Placeholder for Books',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
