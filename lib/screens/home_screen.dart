import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:flutter/material.dart';
import '../widgets/bottle_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Future<void> loadSavedData() async {

    final prefs = await SharedPreferences.getInstance();

    int savedConsumed = prefs.getInt('consumed') ?? 0;
    int savedGoal = prefs.getInt('goal') ?? 2000;

    setState(() {
      consumed = savedConsumed;
      goal = savedGoal;
    });

  }

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  int consumed = 0;
  int goal = 2000;

  void addWater(int amount) async {

    final prefs = await SharedPreferences.getInstance();

    setState(() {
      consumed += amount;

      if (consumed > goal) {
        consumed = goal;
      }
    });

    await prefs.setInt('consumed', consumed);

  }

  void resetWater() {
    setState(() {
      consumed = 0;
    });
  }

  @override
  Widget build(BuildContext context) {

    double progress = consumed / goal;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Water Tracker"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: OrientationBuilder(
          builder: (context, orientation) {

            if (orientation == Orientation.portrait) {
              return portraitLayout(progress);
            } else {
              return landscapeLayout(progress);
            }

          },
        ),
      ),
    );
  }

  Widget portraitLayout(double progress) {

    return Column(
      children: [

        Expanded(
          child: BottleWidget(
            progress: progress,
            consumed: consumed,
            goal: goal,
          ),
        ),

        const SizedBox(height: 20),

        progressBar(progress),

        const SizedBox(height: 20),

        remainingCard(),

        const SizedBox(height: 20),

        intakeButtons(),
      ],
    );
  }

  Widget landscapeLayout(double progress) {

    return Row(
      children: [

        Expanded(
          child: BottleWidget(
            progress: progress,
            consumed: consumed,
            goal: goal,
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              progressBar(progress),

              const SizedBox(height: 20),

              remainingCard(),

              const SizedBox(height: 20),

              intakeButtons(),
            ],
          ),
        )
      ],
    );
  }

  Widget progressBar(double progress) {

    return Column(
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            const Text("Daily Progress"),

            Text("${(progress * 100).toInt()}%"),

          ],
        ),

        const SizedBox(height: 10),

        LinearProgressIndicator(
          value: progress,
          minHeight: 12,
        ),

      ],
    );
  }

  Widget remainingCard() {

    int remaining = goal - consumed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [

          const Text("Remaining"),

          Text(
            "$remaining ml",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          )

        ],
      ),
    );
  }

  Widget intakeButtons() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [

        ElevatedButton(
          onPressed: () => addWater(250),
          child: const Text("+250ml"),
        ),

        ElevatedButton(
          onPressed: () => addWater(500),
          child: const Text("+500ml"),
        ),

        ElevatedButton(
          onPressed: () => addWater(1000),
          child: const Text("+1L"),
        ),

        ElevatedButton(
          onPressed: resetWater,
          child: const Text("Reset"),
        ),

      ],
    );
  }

}