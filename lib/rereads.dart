import 'package:flutter/material.dart';
import 'control.dart';
import 'AddRereadPage.dart'; // Import the AddRereadPage
import 'EditRereadPage.dart';

class RereadsPage extends StatefulWidget {
  final int idEntrada;

  const RereadsPage({super.key, required this.idEntrada});

  @override
  _RereadsPageState createState() => _RereadsPageState();
}

class _RereadsPageState extends State<RereadsPage> {
  final Control _dbService = Control();
  late Future<List<Map<String, dynamic>>> _rereads;
  final bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _rereads = _getRereads();
  }

  Future<List<Map<String, dynamic>>> _getRereads() async {
    return _dbService.getRereadsByIdEntrada(widget.idEntrada);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rereads'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _rereads,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Map<String, dynamic>> rereads = snapshot.data!;
            if (rereads.isEmpty) {
              return const Center(child: Text('No rereads found for this entry.'));
            } else {
              return ListView.builder(
                itemCount: rereads.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> reread = rereads[index];
                  String startDate = (reread['inicio'] as String).substring(0, 10);
                  String endDate = reread['fim'] != null ? (reread['fim'] as String).substring(0, 10) : 'N/A';
                  return GestureDetector(
                    onTap: () async {
                      bool refreshNeeded = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRereadPage(idReread: reread['id_releitura']),
                        ),
                      );
                      if (refreshNeeded ?? false) {
                        setState(() {
                          _rereads = _getRereads(); // Refresh rereads data
                        });
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text('Reread ${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start Date: $startDate'),
                            Text('End Date: $endDate'),
                            Text('Quantity: ${reread['quantidade']}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          } else {
            return const Center(child: Text('No rereads found for this entry.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRereadPage(idEntrada: widget.idEntrada), // Navigate to AddRereadPage
            ),
          );
          setState(() {
            _rereads = _getRereads(); // Refresh rereads data
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
