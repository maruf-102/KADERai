import 'package:flutter/material.dart';
import 'dart:async';

// Singleton class to manage Pomodoro Timer state
class PomodoroTimerState {
  static final PomodoroTimerState _instance = PomodoroTimerState._internal();

  factory PomodoroTimerState() {
    return _instance;
  }

  PomodoroTimerState._internal();

  int workDuration = 25 * 60; // 25 minutes in seconds
  int currentDuration = 25 * 60;
  bool isRunning = false;
  Timer? timer;

  // Start the timer and update UI every second
  void startTimer(Function updateUI) {
    if (isRunning) return;

    isRunning = true;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (currentDuration > 0) {
        currentDuration--;
      } else {
        stopTimer();
      }
      updateUI();
    });
  }

  // Stop the timer
  void stopTimer() {
    isRunning = false;
    timer?.cancel();
  }

  // Reset the timer to its original work duration
  void resetTimer() {
    currentDuration = workDuration;
    isRunning = false;
    timer?.cancel();
  }
}

class PomodoroTimer extends StatefulWidget {
  @override
  _PomodoroTimerState createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  final PomodoroTimerState timerState = PomodoroTimerState(); // Use the singleton instance

  @override
  void initState() {
    super.initState();
  }

  // Function to update the UI
  void updateUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int minutes = timerState.currentDuration ~/ 60;
    int seconds = timerState.currentDuration % 60;

    return Scaffold(
      backgroundColor: Color(0xFF70BDF2), // Background color matching your theme
      appBar: AppBar(
        backgroundColor: Color(0xFF70BDF2),
        title: Text("Pomodoro Timer"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$minutes:${seconds.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 128, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: timerState.isRunning
                      ? () {
                    setState(() {
                      timerState.stopTimer();
                    });
                  }
                      : () {
                    setState(() {
                      timerState.startTimer(updateUI);
                    });
                  },
                  child: Text(timerState.isRunning ? 'Stop' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue, // Button color
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      timerState.resetTimer();
                    });
                  },
                  child: Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue, // Button color
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// void main() {
//   runApp(MaterialApp(
//     home: PomodoroTimer(),
//   ));
// }
