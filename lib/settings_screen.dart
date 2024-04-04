import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'l10n/l10n.dart';

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
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          _buildLanguageSetting(context),
          const SizedBox(height: 10),
          _buildThemeModeSetting(context),
        ],
      ),
    );
  }

  Widget _buildLanguageSetting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.language, color: Colors.blue),
          title: Text(AppLocalizations.of(context)!.language),
          trailing: DropdownButton<Locale>(
            value: Localizations.localeOf(context),
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
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            AppLocalizations.of(context)!.languageDescription,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeSetting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.nights_stay, color: Colors.blue),
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
            inactiveThumbColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : null,
            inactiveTrackColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white30
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            AppLocalizations.of(context)!.themeDescription,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}
