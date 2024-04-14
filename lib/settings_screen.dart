import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Locale) setLocale;
  final Function(ThemeMode) setThemeMode;
  final ThemeMode currentThemeMode;

  const SettingsScreen({
    Key? key,
    required this.setLocale,
    required this.setThemeMode,
    required this.currentThemeMode,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _localThemeMode;

  List<Color> _lightColors = [
    Color.fromARGB(255, 139, 220, 255),
    Color.fromARGB(255, 177, 161, 255),
    Color.fromARGB(255, 159, 255, 249),
    Color.fromARGB(255, 246, 255, 194)
  ];

  List<Color> _darkColors = [
    Color.fromRGBO(22, 90, 102, 1),
    Color.fromRGBO(76, 12, 83, 1),
    Color.fromRGBO(8, 29, 52, 1),
    Color.fromRGBO(80, 27, 107, 1),
  ];

  @override
  void initState() {
    super.initState();
    _localThemeMode = widget.currentThemeMode;
  }

  Future<void> _persistLocale(String localeCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('localeCode', localeCode);
  }

  Future<void> _persistThemeMode(ThemeMode mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'themeMode', mode == ThemeMode.dark ? 'dark' : 'light');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme.of(context).brightness == Brightness.dark
              ? _darkColors
              : _lightColors,
        ),
      ),
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Make the scaffold background transparent
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.settings,
            style:
                TextStyle(fontFamily: 'OpenSans', fontWeight: FontWeight.w600),
          ),
          backgroundColor:
              Colors.transparent, // Make the AppBar background transparent
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            _buildSettingCard(context, _buildLanguageSetting(context)),
            const SizedBox(height: 10),
            _buildSettingCard(context, _buildThemeModeSetting(context)),
            const SizedBox(height: 10),
            _buildSettingCard(context, _buildFeedbackSetting(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSetting(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.feedback,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          title: Text(
            AppLocalizations.of(context)!.sendFeedback,
            style:
                TextStyle(fontFamily: 'OpenSans', fontWeight: FontWeight.w500),
          ),
          onTap: () {
            _sendFeedbackEmail();
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.feedbackDescription,
            style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Future<void> _sendFeedbackEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'kramaranya15@gmail.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Doodle Me Feedback',
      }),
    );

    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.couldNotLaunchEmailApp),
        ),
      );
    }
  }

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Widget _buildSettingCard(BuildContext context, Widget child) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: child,
    );
  }

  Widget _buildLanguageSetting(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.language,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          title: Text(
            AppLocalizations.of(context)!.language,
            style:
                TextStyle(fontFamily: 'OpenSans', fontWeight: FontWeight.w500),
          ),
          trailing: DropdownButton<Locale>(
            borderRadius: BorderRadius.circular(10),
            value: Localizations.localeOf(context),
            onChanged: (Locale? newValue) {
              if (newValue != null) {
                widget.setLocale(newValue);
                _persistLocale(newValue.languageCode);
              }
            },
            items: L10n.all.map<DropdownMenuItem<Locale>>((Locale locale) {
              String lang = L10n.getLanguageName(locale.languageCode);
              return DropdownMenuItem<Locale>(
                value: locale,
                child: Text(lang),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.languageDescription,
            style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeSetting(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.nights_stay,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          title: Text(
            AppLocalizations.of(context)!.nightmode,
            style:
                TextStyle(fontFamily: 'OpenSans', fontWeight: FontWeight.w500),
          ),
          trailing: Switch(
            value: _localThemeMode == ThemeMode.dark,
            activeColor: Colors.white,
            inactiveThumbColor: Colors.black,
            inactiveTrackColor: Colors.white,
            onChanged: (bool value) {
              final mode = value ? ThemeMode.dark : ThemeMode.light;
              setState(() {
                _localThemeMode = mode;
                widget.setThemeMode(_localThemeMode);
              });
              _persistThemeMode(_localThemeMode);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.themeDescription,
            style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
