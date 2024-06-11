import 'package:flutter/material.dart';
import 'control.dart';

class ReleasesPage extends StatefulWidget {
  const ReleasesPage({Key? key}) : super(key: key);

  @override
  _ReleasesPageState createState() => _ReleasesPageState();
}

class _ReleasesPageState extends State<ReleasesPage> {
  Future<void> _deleteLancamento(BuildContext context, int idLancamento) async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this lancamento?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                try {
                  await Control().deleteLancamento(idLancamento);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lancamento deleted successfully.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting lancamento: $e'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Yes'),
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
        title: Text('Releases'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Control().getLancamentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No releases available'));
          } else {
            final lancamentos = snapshot.data!;
            final today = DateTime.now();
            return ListView.builder(
              itemCount: lancamentos.length,
              itemBuilder: (context, index) {
                final lancamento = lancamentos[index];
                final lancamentoDate = DateTime.parse(lancamento['lancamento']);
                final isPastLancamento = lancamentoDate.isBefore(today);
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      '${lancamento['grupo_titulo']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          'Title: ${lancamento['lancamento_titulo']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Date: ${lancamento['lancamento']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isPastLancamento ? Colors.red : Colors.grey,
                            // Apply color if lancamento is in the past
                          ),
                        ),
                        // Add more fields as needed
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteLancamento(context, lancamento['id_lancamento']);
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
