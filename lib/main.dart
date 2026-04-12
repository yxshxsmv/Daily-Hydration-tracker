import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/goal_screen.dart';

void main() {

  runApp(MyApp());

}

class MyApp extends StatelessWidget {

  Future<bool> goalExists() async {

    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey('goal');

  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final prefs = snapshot.data!;
        bool darkMode = prefs.getBool("darkMode") ?? false;

        return MaterialApp(

          debugShowCheckedModeBanner: false,

          theme: ThemeData.light(),

          darkTheme: ThemeData.dark(),

          themeMode:
          darkMode ? ThemeMode.dark : ThemeMode.light,

          home: FutureBuilder(
            future: goalExists(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.data == true) {
                return const HomeScreen();
              }

              return GoalScreen();

            },
          ),
        );
      },
    );

  }

}