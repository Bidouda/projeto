import 'package:flutter/material.dart';
import 'control.dart';

class AddRereadPage extends StatefulWidget {
  final int idEntrada;

  const AddRereadPage({Key? key, required this.idEntrada}) : super(key: key);

  @override
  _AddRereadPageState createState() => _AddRereadPageState();
}

class _AddRereadPageState extends State<AddRereadPage> {
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
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    super.dispose();
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
    int idEntrada = widget.idEntrada;
    int releitura = 1; // Adjust this according to your logic for marking it as a reread
    double quantidade = double.parse(_quantidadeController.text);
    String inicio = _selectedStartDate.toIso8601String().split('T')[0];
    String? fim = _selectedEndDate?.toIso8601String().split('T')[0];

    Map<String, dynamic> rereadData = {
      'id_entrada': idEntrada,
      'releitura': releitura,
      'quantidade': quantidade,
      'inicio': inicio,
      'fim': fim,
    };

    await _dbService.insertReread(rereadData);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Reread saved successfully!'),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Reread'),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSave ? Colors.black : Colors.grey,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
