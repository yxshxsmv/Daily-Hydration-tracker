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

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      home: FutureBuilder(

        future: goalExists(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.data == true) {
            return HomeScreen();
          }

          return GoalScreen();

        },

      ),

    );

  }

}