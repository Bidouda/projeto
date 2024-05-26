import 'package:flutter/material.dart';
import 'control.dart';

class EditAuthorPage extends StatefulWidget {
  final int idAutor;

  const EditAuthorPage({Key? key, required this.idAutor}) : super(key: key);

  @override
  _EditAuthorPageState createState() => _EditAuthorPageState();
}

class _EditAuthorPageState extends State<EditAuthorPage> {
  final Control _dbControl = Control();
  late TextEditingController _authorController;
  String _descricaoAutor = '';

  @override
  void initState() {
    super.initState();
    _authorController = TextEditingController();
    _loadAuthorDescription();
  }

  Future<void> _loadAuthorDescription() async {
    final authorData = await _dbControl.getAuthorById(widget.idAutor);
    if (authorData != null) {
      setState(() {
        _descricaoAutor = authorData['descricao_autor'];
        _authorController = TextEditingController(text: _descricaoAutor);
      });
    }
  }

  Future<void> _updateAuthorDescription() async {
    final newDescricaoAutor = _authorController.text.trim();
    if (newDescricaoAutor.isNotEmpty) {
      await _dbControl.updateAuthorDescription(widget.idAutor, newDescricaoAutor);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Author description updated successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Author description cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteAuthor() async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this author?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                await _dbControl.deleteAuthor(widget.idAutor);
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Author'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _authorController,
              decoration: InputDecoration(labelText: 'Author Description'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateAuthorDescription,
              child: Text('Save Changes'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _deleteAuthor,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set background color to red for delete button
              ),
              child: Text('Delete Author'),
            ),
          ],
        ),
      ),
    );
  }
}
