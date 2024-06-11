import 'package:flutter/material.dart';
import 'control.dart';

class EditRereadPage extends StatefulWidget {
  final int idReread;

  const EditRereadPage({Key? key, required this.idReread}) : super(key: key);

  @override
  _EditRereadPageState createState() => _EditRereadPageState();
}

class _EditRereadPageState extends State<EditRereadPage> {
  final Control _dbService = Control();
  late TextEditingController _quantidadeController;
  late DateTime _selectedStartDate;
  late DateTime? _selectedEndDate;
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _quantidadeController = TextEditingController();
    _selectedStartDate = DateTime.now();
    _selectedEndDate = null;
    _loadRereadData();
  }

  Future<void> _loadRereadData() async {
    Map<String, dynamic>? reread = await _dbService.getRereadById(widget.idReread);
    if (reread != null) {
      setState(() {
        _selectedStartDate = DateTime.parse(reread['inicio']);
        _selectedEndDate = reread['fim'] != null ? DateTime.parse(reread['fim']) : null;
        _quantidadeController.text = reread['quantidade'].toString();
        _canSave = true; // Enable save button as data is loaded
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _selectedStartDate : (_selectedEndDate ?? DateTime.now()),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
        _checkCanSave();
      });
    }
  }

  void _checkCanSave() {
    setState(() {
      _canSave = _selectedEndDate != null && _quantidadeController.text.isNotEmpty;
    });
  }

  Future<void> _saveReread() async {
    int idReread = widget.idReread;
    double quantidade = double.parse(_quantidadeController.text);
    String inicio = _selectedStartDate.toIso8601String().split('T')[0];
    String? fim = _selectedEndDate?.toIso8601String().split('T')[0];

    Map<String, dynamic> updatedData = {
      'quantidade': quantidade,
      'inicio': inicio,
      'fim': fim,
    };

    await _dbService.updateReread(idReread, updatedData);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Reread updated successfully!'),
    ));
    Navigator.pop(context, true); // Pass true indicating a change has been made
  }

  Future<void> _deleteReread() async {
    int idReread = widget.idReread;
    await _dbService.deleteReread(idReread);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Reread deleted successfully!'),
    ));
    Navigator.pop(context, true); // Pass true indicating a change has been made
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Reread'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Start Date',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            ElevatedButton.icon(
              icon: Icon(Icons.calendar_today),
              label: Text(_selectedStartDate.toLocal().toString().split(' ')[0]),
              onPressed: () => _selectDate(context, true),
            ),
            SizedBox(height: 16.0),
            Text(
              'End Date',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            ElevatedButton.icon(
              icon: Icon(Icons.calendar_today),
              label: Text(
                _selectedEndDate != null
                    ? _selectedEndDate!.toLocal().toString().split(' ')[0]
                    : 'Select End Date',
              ),
              onPressed: () => _selectDate(context, false),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _quantidadeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _checkCanSave(),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _canSave ? _saveReread : null,
              child: Text('Save Reread'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _deleteReread,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSave ? Colors.black : Colors.grey,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 16.0),
              ),
              child: Text('Delete Reread'),
            ),
          ],
        ),
      ),
    );
  }
}
