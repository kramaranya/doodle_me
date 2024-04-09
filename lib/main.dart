import 'package:doodle_me/firebase_options.dart';
import 'package:doodle_me/history_screen.dart';
import 'package:doodle_me/list_objects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'l10n/l10n.dart';
import 'settings_screen.dart';
import 'drawing_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:flutter/animation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(home: IntroScreen(), debugShowCheckedModeBanner: false));
}

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
      () => Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => BottomNavigationBarApp(),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/doodle_logo_front.webp',
                  width: 200,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Text(
                'kramaranya',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'OpenSans',
                    fontWeight: FontWeight.w500,
                    color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavigationBarApp extends StatefulWidget {
  @override
  _BottomNavigationBarAppState createState() => _BottomNavigationBarAppState();
}

class _BottomNavigationBarAppState extends State<BottomNavigationBarApp> {
  Locale _currentLocale = Locale('en');
  ThemeMode _currentThemeMode = ThemeMode.light;
  // Define a globalKey for navigation

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
      debugShowCheckedModeBanner: false,
      supportedLocales: L10n.all,
      locale: _currentLocale,
      themeMode: _currentThemeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData.light().copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      darkTheme: ThemeData.dark().copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
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

class _BottomNavigationBarExampleState extends State<BottomNavigationBarExample>
    with TickerProviderStateMixin {
  int _selectedIndex = 1;
  List<Widget> _widgetOptions = [];
  late AnimationController _shakeController0;
  late AnimationController _shakeController1;
  late AnimationController _shakeController2;
  late AnimationController _shakeController3;

  @override
  void initState() {
    super.initState();
    _shakeController0 = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _shakeController1 = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _shakeController2 = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _shakeController3 = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
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
      HistoryScreen(),
      SettingsScreen(
        setLocale: widget.setLocale,
        setThemeMode: widget.setThemeMode,
        currentThemeMode: widget.currentThemeMode,
      ),
    ];
  }

  @override
  void dispose() {
    _shakeController0.dispose();
    _shakeController1.dispose();
    _shakeController2.dispose();
    _shakeController3.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      _shakeController0
        ..reset()
        ..forward();
    }
    if (index == 1) {
      _shakeController1
        ..reset()
        ..forward();
    }
    if (index == 2) {
      _shakeController2
        ..reset()
        ..forward();
    }
    if (index == 3) {
      _shakeController3
        ..reset()
        ..forward();
    }
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
            icon: AnimatedBuilder(
              animation: _shakeController0,
              builder: (context, child) {
                return Transform.translate(
                  offset:
                      Offset(0.0, 10 * (0.5 - _shakeController0.value).abs()),
                  child: _selectedIndex == 0
                      ? Icon(Icons.home)
                      : Icon(Icons.home_outlined),
                );
              },
            ),
            label: AppLocalizations.of(context)!.doodle,
          ),
          BottomNavigationBarItem(
            icon: AnimatedBuilder(
              animation: _shakeController1,
              builder: (context, child) {
                return Transform.translate(
                  offset:
                      Offset(0.0, 10 * (0.5 - _shakeController1.value).abs()),
                  child: _selectedIndex == 1
                      ? Icon(Icons.draw)
                      : Icon(Icons.draw_outlined),
                );
              },
            ),
            label: AppLocalizations.of(context)!.draw,
          ),
          BottomNavigationBarItem(
            icon: AnimatedBuilder(
              animation: _shakeController2,
              builder: (context, child) {
                return Transform.translate(
                  offset:
                      Offset(0.0, 10 * (0.5 - _shakeController2.value).abs()),
                  child: _selectedIndex == 2
                      ? Icon(Icons.history)
                      : Icon(Icons.history_outlined),
                );
              },
            ),
            label: AppLocalizations.of(context)!.history,
          ),
          BottomNavigationBarItem(
            icon: AnimatedBuilder(
              animation: _shakeController3,
              builder: (context, child) {
                return Transform.translate(
                  offset:
                      Offset(0.0, 10 * (0.5 - _shakeController3.value).abs()),
                  child: _selectedIndex == 3
                      ? Icon(Icons.settings)
                      : Icon(Icons.settings_outlined),
                );
              },
            ),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
        fixedColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
      ),
    );
  }
}
