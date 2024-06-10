import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'control.dart';
import 'create.dart';
import 'search.dart';
import 'group_widget.dart';
import 'import.dart';
import 'main.dart'; // Import the file where routeObserver is defined
import 'stats.dart'; // New import for Stats page
import 'releases.dart'; // New import for Releases page
import 'package:file_picker/file_picker.dart';
import 'dart:io';

Future<void> requestStoragePermission() async {
  PermissionStatus status = await Permission.manageExternalStorage.request();
  if (!status.isGranted) {
    throw Exception("Storage permission not granted");
  }
}

Future<void> _exportDatabase(BuildContext context) async {
  try {
    Control control = Control();
    await control.startDatabase(); // Make sure the database is opened

    // Call the exportToSQL function from the Control class
    await control.exportToSQL();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Database exported to SQL file.'),
        duration: Duration(seconds: 3),
      ),
    );
  } catch (e) {
    print("Error exporting database: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error exporting database.'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmark"),
        automaticallyImplyLeading: false, // Hides the default leading icon
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.menu),
            ),
          ),
        ],
      ),
      endDrawer: CustomDrawer(), // Use the CustomDrawer widget
      bottomNavigationBar: NavigationBar(
        destinations: const [
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
          _createPage(() => const GruposListView(category: 1)), // Current
          _createPage(() => const GruposListView(category: 2)), // Paused
          _createPage(() => const GruposListView(category: 3)), // Completed
          _createPage(() => const GruposListView(category: 4)), // Dropped
          _createPage(() => const GruposListView(category: 5)), // Planning
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

// CustomDrawer Widget for better drawer design
class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black, // Background color for the header
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Options', // Changed "Menu" to "Options"
                style: TextStyle(
                  color: Colors.white, // Changed font color
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.search, color: Colors.black), // Changed icon color to black
            title: Text('Search'),
            onTap: () {
              Navigator.pop(context);
              _openPage(context, const Search());
            },
          ),
          ListTile(
            leading: Icon(Icons.add, color: Colors.black), // Changed icon color to black
            title: Text('Create'),
            onTap: () {
              Navigator.pop(context);
              _openPage(context, const Create());
            },
          ),
          Divider(
            thickness: 1,
            color: Colors.grey[300],
          ),
          ListTile(
            leading: Icon(Icons.import_export, color: Colors.black), // Changed icon color to black
            title: Text('Import'), // Changed text to "Import"
            onTap: () {
              Navigator.pop(context);
              _openPage(context, const ImportExportPage()); // Redirect to ImportExportPage
            },
          ),
          ListTile(
            leading: Icon(Icons.file_download, color: Colors.black), // Changed icon color to black and added Export icon
            title: Text('Export'), // Changed text to "Export"
            onTap: () async {
              Navigator.pop(context);
              await requestStoragePermission(); // Request permission before navigating
              await _exportDatabase(context); // Call the export function
            },
          ),
          ListTile(
            leading: Icon(Icons.restore, color: Colors.black), // Changed icon color to black
            title: Text('Reset'), // Moved from above
            onTap: () {
              // Implement reset functionality
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirm Reset'),
                  content: Text('Are you sure you want to reset all data? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Reset logic here
                        Control().clearDatabases();
                        Navigator.pop(context);
                      },
                      child: Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}