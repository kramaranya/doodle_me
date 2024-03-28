import 'package:flutter/material.dart';
import 'list_objects.dart';
import 'package:firebase_core/firebase_core.dart';
import 'drawing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BottomNavigationBarExampleApp());
}

class BottomNavigationBarExampleApp extends StatelessWidget {
  const BottomNavigationBarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BottomNavigationBarExample(),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;

  // Method to choose the widget based on the selected index
  Widget _choosePage(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return DrawingScreen();
      case 2:
        return Text(
          'Index 2: Settings',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        );
      default:
        return Text('Unknown page');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: _choosePage(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted_rounded),
            label: 'Doodles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.brush),
            label: 'Draw',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 126, 210, 255),
        onTap: _onItemTapped,
      ),
    );
  }
}
