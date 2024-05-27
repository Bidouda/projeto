import 'package:flutter/material.dart';
import 'control.dart'; // Import the database service class
import 'book.dart'; // Import the Book widget
import 'detail_page.dart'; // Import the DetailPage widget
import 'EditAuthorPage.dart';
import 'main.dart'; // Import to access routeObserver

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with SingleTickerProviderStateMixin, RouteAware {
  final List<String?> _groupTitles = [];
  late final TabController _tabController;
  late final TextEditingController _bookSearchController = TextEditingController();
  late final TextEditingController _groupController = TextEditingController();
  final TextEditingController _bookController = TextEditingController();
  List<Map<String, dynamic>> _groupResults = [];
  List<Map<String, dynamic>> _bookResults = [];
  final Control _dbControl = Control();
  final TextEditingController _authorSearchController = TextEditingController();
  List<Map<String, dynamic>> _authorResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tabController.dispose();
    _groupController.dispose();
    _bookController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the current route has been popped off, meaning the user has navigated back to this page.
    _refreshPage();
  }

  Future<void> _refreshPage() async {
    await _searchGroups();
    await _searchBooks();
    await _searchAuthors();
  }

  Future<void> _searchGroups() async {
    final results = await _dbControl.queryFind(_groupController.text);
    setState(() {
      _groupResults = results;
    });
  }

  Future<void> _searchBooks() async {
    final results = await _dbControl.queryFindEntradas(_bookSearchController.text);
    setState(() {
      _bookResults = results;
    });

    // Fetch group titles for each book entry
    for (var book in _bookResults) {
      final groupTitle = await _dbControl.getGroupTitleById(book['grupo']);
      setState(() {
        _groupTitles.add(groupTitle);
      });
    }
  }

  Future<void> _searchAuthors() async {
    final results = await _dbControl.queryFindAuthors(_authorSearchController.text);
    setState(() {
      _authorResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Groups"),
            Tab(text: "Books"),
            Tab(text: "Authors"),
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
                        decoration: const InputDecoration(
                          labelText: "Group Title",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _searchGroups,
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _groupResults.isEmpty
                    ? const Center(child: Text('No groups found.'))
                    : ListView.builder(
                  itemCount: _groupResults.length,
                  itemBuilder: (context, index) {
                    final group = _groupResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(group['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        controller: _bookSearchController,
                        decoration: const InputDecoration(
                          labelText: "Book Title",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _searchBooks,
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _bookResults.isEmpty
                    ? const Center(child: Text('No books found.'))
                    : ListView.builder(
                  itemCount: _bookResults.length,
                  itemBuilder: (context, index) {
                    final book = _bookResults[index];
                    final groupTitle = _groupTitles[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: const Icon(Icons.book),
                        title: Text(book['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Position: ${book['posicao']}'),
                            if (groupTitle != null) Text('Group: $groupTitle'), // Display group title
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(
                                idEntrada: book['id_entrada'],
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
          // Authors Tab
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                                        Expanded(
                      child: TextFormField(
                        controller: _authorSearchController,
                        decoration: const InputDecoration(
                          labelText: "Author Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _searchAuthors,
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _authorResults.isEmpty
                    ? const Center(child: Text('No authors found.'))
                    : ListView.builder(
                      itemCount: _authorResults.length,
                      itemBuilder: (context, index) {
                        final author = _authorResults[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(author['descricao_autor'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditAuthorPage(idAutor: author['id_autor']),
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
        ],
      ),
    );
  }
}