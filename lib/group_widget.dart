import 'package:flutter/material.dart';
import 'control.dart';
import 'grupo.dart';
import 'book.dart'; // Import the book.dart file

class GruposListView extends StatefulWidget {
  final int category;

  GruposListView({required this.category});

  @override
  _GruposListViewState createState() => _GruposListViewState();
}

class _GruposListViewState extends State<GruposListView> {
  List<Grupo> _grupos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGrupos();
  }

  Future<void> _fetchGrupos() async {
    Control control = Control();
    List<Map<String, dynamic>> result = await control.queryFindCategoria(widget.category);
    setState(() {
      _grupos = result.map((map) => Grupo.fromMap(map)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _grupos.isEmpty
          ? Center(child: Text('No groups found.'))
          : ListView.builder(
        itemCount: _grupos.length,
        itemBuilder: (context, index) {
          final grupo = _grupos[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Icon(Icons.folder),
              title: Text(grupo.titulo, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text('Category: ${grupo.categoria}'),
                  Text('ID: ${grupo.idGrupo}'),
                ],
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Book(
                      titulo: grupo.titulo,
                      categoria: grupo.categoria,
                      idGrupo: grupo.idGrupo!, // Pass idGrupo as parameter
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
