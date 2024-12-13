import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pomodoro_timer_model.dart';

class PomodoroTimer extends StatelessWidget {
  final Function(bool) onSessionComplete;

  PomodoroTimer({required this.onSessionComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pomodoro Timer"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Consumer<PomodoroTimerModel>(builder: (context, timer, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Timer state title (Focus/Break)
                  Text(
                    timer.isBreak ? "Break Time" : "Focus Time",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: timer.isBreak ? Colors.greenAccent : Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Timer countdown
                  Text(
                    timer.formatTime(timer.remainingTime),
                    style: TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Control buttons (Start/Pause and Reset)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed:
                        timer.isRunning ? timer.stopTimer : timer.startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          timer.isRunning ? "Pause" : "Start",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: timer.resetTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade400,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Reset",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  // Adjust Timer Durations title
                  Text(
                    "Adjust Timer Durations",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 20),
                  // Duration adjusters (Focus, Short Break, Long Break)
                  DurationAdjuster(
                    label: "Focus Duration",
                    duration: timer.focusDuration,
                    onChanged: (newDuration) {
                      timer.setFocusDuration(newDuration);
                    },
                  ),
                  SizedBox(height: 10),
                  DurationAdjuster(
                    label: "Short Break Duration",
                    duration: timer.shortBreakDuration,
                    onChanged: (newDuration) {
                      timer.setShortBreakDuration(newDuration);
                    },
                  ),
                  SizedBox(height: 10),
                  DurationAdjuster(
                    label: "Long Break Duration",
                    duration: timer.longBreakDuration,
                    onChanged: (newDuration) {
                      timer.setLongBreakDuration(newDuration);
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class DurationAdjuster extends StatelessWidget {
  final String label;
  final int duration;
  final ValueChanged<int> onChanged;

  DurationAdjuster(
      {required this.label, required this.duration, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade400, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.remove, color: Colors.blue.shade600),
              onPressed: () {
                if (duration > 60) {
                  onChanged(duration - 60);
                }
              },
            ),
            Text(
              '${duration ~/ 60} min',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add, color: Colors.blue.shade600),
              onPressed: () {
                onChanged(duration + 60);
              },
            ),
          ],
        ),
      ),
    );
  }
}
