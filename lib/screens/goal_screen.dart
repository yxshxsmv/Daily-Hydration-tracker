import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class GoalScreen extends StatelessWidget {

  void saveGoal(BuildContext context, int goal) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('goal', goal);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  void showCustomDialog(BuildContext context) {

    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {

        return AlertDialog(
          title: Text("Enter custom goal (ml)"),

          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
          ),

          actions: [

            TextButton(
              onPressed: () {

                int goal = int.tryParse(controller.text) ?? 2000;

                saveGoal(context, goal);

              },
              child: Text("Save"),
            )

          ],
        );

      },
    );
  }

  Widget goalButton(
      BuildContext context,
      String label,
      int value
      ) {

    return ElevatedButton(

      onPressed: () => saveGoal(context, value),

      child: Text(label),

    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Select Daily Goal"),
      ),

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            goalButton(context, "2000 ml", 2000),

            goalButton(context, "2500 ml", 2500),

            goalButton(context, "3000 ml", 3000),

            SizedBox(height: 20),

            ElevatedButton(

              onPressed: () =>
                  showCustomDialog(context),

              child: Text("Custom Goal"),

            ),

          ],

        ),

      ),

    );

  }

}