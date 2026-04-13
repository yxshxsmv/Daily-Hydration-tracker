import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/bottle_widget.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int consumed = 0;
  int goal = 2000;

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedConsumed = prefs.getInt('consumed') ?? 0;
    final savedGoal = prefs.getInt('goal') ?? 2000;

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

  Future<void> addWater(int amount) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      consumed += amount;
      if (consumed > goal) {
        consumed = goal;
      }
    });

    await prefs.setInt('consumed', consumed);
  }

  Future<void> resetWater() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      consumed = 0;
    });
    await prefs.setInt('consumed', consumed);
  }

  @override
  Widget build(BuildContext context) {
    final progress = goal == 0 ? 0.0 : (consumed / goal).clamp(0.0, 1.0);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hydration Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.10),
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.secondary.withOpacity(0.08),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: isPortrait
                ? _portraitLayout(context, progress)
                : _landscapeLayout(context, progress),
          ),
        ),
      ),
    );
  }

  Widget _portraitLayout(BuildContext context, double progress) {
    return Column(
      children: [
        _heroHeader(context, progress),
        const SizedBox(height: 18),
        Expanded(
          child: BottleWidget(
            progress: progress,
            consumed: consumed,
            goal: goal,
          ),
        ),
        const SizedBox(height: 20),
        _statsRow(context),
        const SizedBox(height: 18),
        _progressCard(context, progress),
        const SizedBox(height: 18),
        _intakeButtons(),
      ],
    );
  }

  Widget _landscapeLayout(BuildContext context, double progress) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _heroHeader(context, progress),
              const SizedBox(height: 18),
              Expanded(
                child: BottleWidget(
                  progress: progress,
                  consumed: consumed,
                  goal: goal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              _statsRow(context),
              const SizedBox(height: 18),
              _progressCard(context, progress),
              const SizedBox(height: 18),
              _intakeButtons(isVertical: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _heroHeader(BuildContext context, double progress) {
    final theme = Theme.of(context);
    final remaining = (goal - consumed).clamp(0, goal);
    final percentage = (progress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.24),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  percentage >= 100 ? 'Goal completed' : 'Keep sipping',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.84),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  percentage >= 100
                      ? 'You reached your hydration target for today.'
                      : '$remaining ml left to hit your daily goal.',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.16),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            child: Center(
              child: Text(
                '$percentage%',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            context,
            title: 'Consumed',
            value: '$consumed ml',
            icon: Icons.local_drink_rounded,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _statCard(
            context,
            title: 'Goal',
            value: '$goal ml',
            icon: Icons.track_changes_rounded,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCard(BuildContext context, double progress) {
    final theme = Theme.of(context);
    final remaining = (goal - consumed).clamp(0, goal);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Today\'s progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            remaining == 0
                ? 'You are fully hydrated for today.'
                : '$remaining ml remaining before you hit the goal.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _intakeButtons({bool isVertical = false}) {
    final buttons = [
      _actionButton(
        label: '+250 ml',
        icon: Icons.water_drop_outlined,
        onTap: () => addWater(250),
      ),
      _actionButton(
        label: '+500 ml',
        icon: Icons.local_drink_outlined,
        onTap: () => addWater(500),
      ),
      _actionButton(
        label: '+1 L',
        icon: Icons.opacity_rounded,
        onTap: () => addWater(1000),
      ),
      _actionButton(
        label: 'Reset',
        icon: Icons.restart_alt_rounded,
        onTap: resetWater,
        isReset: true,
      ),
    ];

    if (isVertical) {
      return Column(
        children: [
          for (final button in buttons) ...[
            button,
            const SizedBox(height: 12),
          ],
        ]..removeLast(),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: buttons
          .map(
            (button) => SizedBox(
              width: 160,
              child: button,
            ),
          )
          .toList(),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isReset = false,
  }) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: isReset
            ? Colors.red.withOpacity(0.10)
            : Theme.of(context).colorScheme.primary.withOpacity(0.10),
        foregroundColor:
            isReset ? Colors.red.shade700 : Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}
