import "package:flutter/material.dart";
import "create.dart";
import "search.dart";

class Home extends StatefulWidget {
  const Home({super.key});

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
      body: <Widget>[
        //Current
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Current',
              ),
            ),
          ),
        ),

        //Paused
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Paused',
              ),
            ),
          ),
        ),

        //Completed
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Completed',
              ),
            ),
          ),
        ),

        //Dropped
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Dropped',
              ),
            ),
          ),
        ),

        //Planning
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Planning',
              ),
            ),
          ),
        ),
      ][currentPageIndex],
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
