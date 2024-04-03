import 'package:doodle_me/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _localThemeMode = widget.currentThemeMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.language,
                  color: const Color.fromARGB(255, 99, 185, 255)),
              title: Text(AppLocalizations.of(context)!.language),
              trailing: DropdownButton<Locale>(
                value: Localizations.localeOf(context),
                underline: Container(),
                onChanged: (Locale? newValue) {
                  if (newValue != null) {
                    widget.setLocale(newValue);
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
            Divider(),
            ListTile(
              leading: Icon(Icons.nights_stay,
                  color: const Color.fromARGB(255, 99, 185, 255)),
              title: Text(AppLocalizations.of(context)!.nightmode),
              trailing: Switch(
                value: _localThemeMode == ThemeMode.dark,
                onChanged: (bool value) {
                  setState(() {
                    _localThemeMode = value ? ThemeMode.dark : ThemeMode.light;
                  });
                  widget.setThemeMode(_localThemeMode);
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.white24,
                inactiveThumbColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : null,
                inactiveTrackColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white30
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
