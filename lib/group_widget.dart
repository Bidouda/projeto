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
            elevation: 4, // Add elevation for shadow effect
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Add rounded corners
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16), // Add padding
              leading: CircleAvatar( // Use CircleAvatar for rounded leading icon
                backgroundColor: Colors.black, // Customize background color
                child: Icon(Icons.folder, color: Colors.white), // Icon with white color
              ),
              title: Text(
                grupo.titulo,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
