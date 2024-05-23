import "package:flutter/material.dart";
import "create.dart";
import "search.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    int currentPageIndex = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text("Bookmark"),
        actions: [
          IconButton(onPressed: () {_openPage(context, Search());}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {_openPage(context, Create());}, icon: Icon(Icons.add))
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
          });
        },
        selectedIndex: currentPageIndex,
      ),
    );
  }

  _openPage(ctx, page) {
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (BuildContext context){
        return page;
      }),
    );
  }
}
