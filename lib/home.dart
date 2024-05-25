import 'package:flutter/material.dart';
import 'create.dart';
import 'search.dart';
import 'group_widget.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bookmark"),
        actions: [
          IconButton(
            onPressed: () {
              _openPage(context, Search());
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              _openPage(context, Create());
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {}); // Refresh the page by calling setState
        },
        child: Icon(Icons.refresh),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(icon: Icon(Icons.book), label: 'Current'),
          NavigationDestination(icon: Icon(Icons.pause), label: 'Paused'),
          NavigationDestination(icon: Icon(Icons.done), label: 'Completed'),
          NavigationDestination(icon: Icon(Icons.cancel), label: 'Dropped'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Planning'),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
      ),
      body: _getPage(currentPageIndex),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return _createPage(() => GruposListView(category: 1)); // Current
      case 1:
        return _createPage(() => GruposListView(category: 2)); // Paused
      case 2:
        return _createPage(() => GruposListView(category: 3)); // Completed
      case 3:
        return _createPage(() => GruposListView(category: 4)); // Dropped
      case 4:
        return _createPage(() => GruposListView(category: 5)); // Planning
      default:
        return Container(); // Fallback for unknown indices
    }
  }

  Widget _createPage(Widget Function() pageBuilder) {
    return KeyedSubtree(
      key: UniqueKey(),
      child: pageBuilder(),
    );
  }

  void _openPage(BuildContext ctx, Widget page) {
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (BuildContext context) {
        return page;
      }),
    );
  }
}
