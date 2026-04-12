import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  final TextEditingController goalController =
  TextEditingController();

  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {

    final prefs = await SharedPreferences.getInstance();

    goalController.text =
        (prefs.getInt("goal") ?? 2500).toString();

    darkMode = prefs.getBool("darkMode") ?? false;

    setState(() {});
  }

  Future<void> saveSettings() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      "goal",
      int.parse(goalController.text),
    );

    await prefs.setBool("darkMode", darkMode);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Daily Goal (ml)",
              ),
            ),

            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text("Dark Mode"),
              value: darkMode,
              onChanged: (value) {
                setState(() {
                  darkMode = value;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveSettings,
              child: const Text("Save"),
            )

          ],
        ),
      ),
    );
  }
}