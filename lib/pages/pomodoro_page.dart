import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pomodoro_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.nights_stay
                      : Icons.wb_sunny,
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? Colors.yellow
                      : Colors.blueAccent,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<PomodoroProvider>(
        builder: (context, provider, child) {
          final minutes = provider.remainingTime ~/ 60;
          final seconds = provider.remainingTime % 60;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildWorkDurationSelector(context, provider),
                const SizedBox(height: 60),
                _buildTimerDisplay(context, minutes, seconds, provider),
                const SizedBox(height: 20),
                _buildControls(context, provider),
                const SizedBox(height: 20),
                _buildStatusIndicator(context, provider),
                const SizedBox(height: 60),
                _buildModeSwitcher(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkDurationSelector(
      BuildContext context, PomodoroProvider provider) {
    return DropdownButton<int>(
      value: provider.workDuration,
      items: const [
        DropdownMenuItem(value: 60, child: Text('60 minutes')),
        DropdownMenuItem(value: 25, child: Text('25 minutes')),
        DropdownMenuItem(value: 15, child: Text('15 minutes')),
      ],
      onChanged: (int? newValue) {
        if (newValue != null && provider.isWorkTime) {
          provider.setDurations(newValue, provider.breakDuration);
          provider.resetPomodoro();
        }
      },
      isExpanded: true,
      underline: Container(
        height: 2,
        color: kPrimaryColor,
      ),
    );
  }

  Widget _buildTimerDisplay(BuildContext context, int minutes, int seconds,
      PomodoroProvider provider) {
    return Text(
      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      style: Theme.of(context).textTheme.displayMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: provider.isWorkTime
                ? Colors.green
                : Theme.of(context).colorScheme.secondary,
          ),
    );
  }

  Widget _buildControls(BuildContext context, PomodoroProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 50,
          icon: Icon(
            provider.isRunning
                ? Icons.pause_circle_filled
                : Icons.play_circle_fill,
            color: kPrimaryColor,
          ),
          onPressed: () {
            if (provider.isRunning) {
              provider.pausePomodoro();
            } else {
              provider.startPomodoro();
            }
          },
        ),
        const SizedBox(width: 20),
        IconButton(
          iconSize: 50,
          icon: Icon(Icons.stop_circle_outlined,
              color: Theme.of(context).colorScheme.error),
          onPressed: () {
            provider.stopPomodoro();
          },
        ),
        const SizedBox(width: 20),
        IconButton(
          iconSize: 50,
          icon: Icon(Icons.refresh,
              color: Theme.of(context).colorScheme.secondary),
          onPressed: () {
            provider.resetPomodoro();
          },
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(
      BuildContext context, PomodoroProvider provider) {
    return Text(
      provider.isWorkTime ? 'Work Time' : 'Break Time',
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: provider.isWorkTime
                ? Colors.green
                : Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildModeSwitcher(PomodoroProvider provider) {
    return ElevatedButton(
      onPressed: () {
        provider.toggleWorkBreak();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      child: Text(
        provider.isWorkTime ? 'Switch to Break Mode' : 'Switch to Work Mode',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
