import 'package:flutter/material.dart';
import 'control.dart'; // Import the database service class
import 'book.dart'; // Import the Book widget

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _bookController = TextEditingController();
  List<Map<String, dynamic>> _groupResults = [];
  List<Map<String, dynamic>> _bookResults = [];
  final Control _dbControl = Control();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _groupController.dispose();
    _bookController.dispose();
    super.dispose();
  }

  Future<void> _searchGroups() async {
    final results = await _dbControl.queryFind(_groupController.text);
    setState(() {
      _groupResults = results;
    });
  }

  Future<void> _searchBooks() async {
    final results = await _dbControl.queryFindEntradas(_bookController.text);
    setState(() {
      _bookResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: "Groups"),
            Tab(text: "Books"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Groups Tab
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _groupController,
                        decoration: InputDecoration(
                          labelText: "Group Title",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _searchGroups,
                      child: Text('Search'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _groupResults.isEmpty
                    ? Center(child: Text('No groups found.'))
                    : ListView.builder(
                  itemCount: _groupResults.length,
                  itemBuilder: (context, index) {
                    final group = _groupResults[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: Icon(Icons.folder),
                        title: Text(group['titulo'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text('Category: ${group['categoria']}'),
                            Text('ID: ${group['id_grupo']}'),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Book(
                                titulo: group['titulo'],
                                categoria: group['categoria'],
                                idGrupo: group['id_grupo'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Books Tab
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bookController,
                        decoration: InputDecoration(
                          labelText: "Book Title",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _searchBooks,
                      child: Text('Search'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _bookResults.isEmpty
                    ? Center(child: Text('No books found.'))
                    : ListView.builder(
                  itemCount: _bookResults.length,
                  itemBuilder: (context, index) {
                    final book = _bookResults[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: Icon(Icons.book),
                        title: Text(book['titulo'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text('Category: ${book['categoria']}'),
                            Text('Type: ${book['tipo']}'),
                            Text('Author: ${book['autor']}'),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          // Handle tap event
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
