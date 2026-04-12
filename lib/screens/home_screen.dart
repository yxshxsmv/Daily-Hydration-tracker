import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../widgets/bottle_widget.dart';
import 'settings_screen.dart';

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
        title: const Text(
          "Hydration Tracker",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {

              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );

              if (updated == true) {
                loadSavedData();
              }

            },
          ),
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

        const SizedBox(height: 28),

        progressBar(progress),

        const SizedBox(height: 28),

        remainingCard(),

        const SizedBox(height: 28),

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            const Text(
              "Daily Progress",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),

        const SizedBox(height: 12),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 14,
            backgroundColor: Colors.grey.shade200,
            color: Colors.blue.shade400,
          ),
        ),

      ],
    );
  }

  Widget remainingCard() {

    int remaining = goal - consumed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Remaining",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "$remaining ml",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          )

        ],
      ),
    );
  }

  Widget intakeButtons() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        intakeButton("+250ml", () => addWater(250)),
        intakeButton("+500ml", () => addWater(500)),
        intakeButton("+1L", () => addWater(1000)),
        intakeButton("Reset", resetWater, isReset: true),

      ],
    );
  }

  Widget intakeButton(
      String label,
      VoidCallback onTap,
      {bool isReset = false}
      ) {

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 55,
            decoration: BoxDecoration(
              color: isReset
                  ? Colors.red.shade100
                  : Colors.blue.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isReset
                      ? Colors.red.shade700
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}