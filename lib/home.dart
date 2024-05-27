import 'package:flutter/material.dart';
import 'create.dart';
import 'search.dart';
import 'group_widget.dart';
import 'main.dart'; // Import the file where routeObserver is defined

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with RouteAware {
  int currentPageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the current route has been popped off, and the current route shows up
    setState(() {
      // Refresh the state when returning to this page
    });
  }

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
