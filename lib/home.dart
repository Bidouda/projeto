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
  final PageController _pageController = PageController();

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
            _pageController.jumpToPage(index);
          });
        },
        selectedIndex: currentPageIndex,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        children: [
          _createPage(() => GruposListView(category: 1)), // Current
          _createPage(() => GruposListView(category: 2)), // Paused
          _createPage(() => GruposListView(category: 3)), // Completed
          _createPage(() => GruposListView(category: 4)), // Dropped
          _createPage(() => GruposListView(category: 5)), // Planning
        ],
      ),
    );
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
