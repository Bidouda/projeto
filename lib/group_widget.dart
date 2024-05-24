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
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: _grupos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Book(
                  titulo: _grupos[index].titulo,
                  categoria: _grupos[index].categoria,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(_grupos[index].titulo),
                subtitle: Text('Category: ${_grupos[index].categoria}'),
              ),
            ),
          ),
        );
      },
    );
  }
}
