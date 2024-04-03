import 'package:doodle_me/list_objects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'l10n/l10n.dart';
import 'settings_screen.dart';
import 'drawing_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(BottomNavigationBarApp());
}

class BottomNavigationBarApp extends StatefulWidget {
  @override
  _BottomNavigationBarAppState createState() => _BottomNavigationBarAppState();
}

class _BottomNavigationBarAppState extends State<BottomNavigationBarApp> {
  Locale _currentLocale = Locale('en');
  ThemeMode _currentThemeMode = ThemeMode.light;

  void setLocale(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });
  }

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _currentThemeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BottomNavigationBarExample(
        setLocale: setLocale,
        setThemeMode: setThemeMode,
        currentThemeMode: _currentThemeMode,
      ),
      supportedLocales: L10n.all,
      locale: _currentLocale,
      themeMode: _currentThemeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  final Function(Locale) setLocale;
  final Function(ThemeMode) setThemeMode;
  final ThemeMode currentThemeMode;

  BottomNavigationBarExample({
    Key? key,
    required this.setLocale,
    required this.setThemeMode,
    required this.currentThemeMode,
  }) : super(key: key);

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      HomePage(),
      Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) {
              return DrawingScreen();
            },
          );
        },
      ),
      SettingsScreen(
        setLocale: widget.setLocale,
        setThemeMode: widget.setThemeMode,
        currentThemeMode: widget.currentThemeMode,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppLocalizations.of(context)!.doodle,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.brush),
            label: AppLocalizations.of(context)!.draw,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
