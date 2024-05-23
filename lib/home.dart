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
    return Scaffold(
      appBar: AppBar(
        title: Text("Bookmark"),
        actions: [
          IconButton(onPressed: () {_openPage(context, Search());}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {_openPage(context, Create());}, icon: Icon(Icons.add))
        ],
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
