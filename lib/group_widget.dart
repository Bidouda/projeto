import 'package:flutter/material.dart';
import 'control.dart';
import 'grupo.dart';
import 'book.dart'; // Import the book.dart file

class GruposListView extends StatefulWidget {
  final int category;

  const GruposListView({super.key, required this.category});

  @override
  _GruposListViewState createState() => _GruposListViewState();
}

class _GruposListViewState extends State<GruposListView> {
  List<Grupo> _grupos = [];
  bool _isLoading = true;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true; // Set mounted flag to true when initializing
    _fetchGrupos();
  }

  @override
  void dispose() {
    _isMounted = false; // Set mounted flag to false when disposing
    super.dispose();
  }

  Future<void> _fetchGrupos() async {
    if (!_isMounted) return; // Check if the widget is mounted
    Control control = Control();
    List<Map<String, dynamic>> result = await control.queryFindCategoria(widget.category);
    if (!_isMounted) return; // Check again after async operation completes
    setState(() {
      _grupos = result.map((map) => Grupo.fromMap(map)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _grupos.isEmpty
          ? const Center(child: Text('No groups found.'))
          : ListView.builder(
        itemCount: _grupos.length,
        itemBuilder: (context, index) {
          final grupo = _grupos[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4, // Add elevation for shadow effect
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Add rounded corners
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16), // Add padding
              leading: const CircleAvatar( // Use CircleAvatar for rounded leading icon
                backgroundColor: Colors.black, // Customize background color
                child: Icon(Icons.folder, color: Colors.white), // Icon with white color
              ),
              title: Text(
                grupo.titulo,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
