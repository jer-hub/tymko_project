import 'package:flutter/material.dart';
import 'dart:async';

class PomodoroTimerScreen extends StatefulWidget {
  final String? taskId;
  final String? taskTitle;

  const PomodoroTimerScreen({super.key, this.taskId, this.taskTitle});

  @override
  State<PomodoroTimerScreen> createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends State<PomodoroTimerScreen> {
  static const int workDuration = 25 * 60; // 25 minutes
  static const int shortBreakDuration = 5 * 60; // 5 minutes
  static const int longBreakDuration = 15 * 60; // 15 minutes

  int _remainingSeconds = workDuration;
  int _completedPomodoros = 0;
  bool _isRunning = false;
  bool _isWorkSession = true;
  Timer? _timer;
  DateTime? _sessionStartTime;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_sessionStartTime == null) {
      _sessionStartTime = DateTime.now();
    }

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _onTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _remainingSeconds = _isWorkSession ? workDuration : shortBreakDuration;
      _sessionStartTime = null;
    });
    _timer?.cancel();
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;

      if (_isWorkSession) {
        _completedPomodoros++;
        // Switch to break
        _isWorkSession = false;
        _remainingSeconds = (_completedPomodoros % 4 == 0)
            ? longBreakDuration
            : shortBreakDuration;
      } else {
        // Switch back to work
        _isWorkSession = true;
        _remainingSeconds = workDuration;
      }
      _sessionStartTime = null;
    });

    // Show completion notification
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isWorkSession ? 'Break Complete!' : 'Pomodoro Complete!'),
        content: Text(
          _isWorkSession
              ? 'Time to focus! Ready for another session?'
              : 'Great work! Time for a ${(_completedPomodoros % 4 == 0) ? "long" : "short"} break.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _startTimer();
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _isWorkSession
        ? 1 - (_remainingSeconds / workDuration)
        : 1 -
              (_remainingSeconds /
                  ((_completedPomodoros % 4 == 0)
                      ? longBreakDuration
                      : shortBreakDuration));

    return Scaffold(
      appBar: AppBar(title: const Text('Pomodoro Timer')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.taskTitle != null) ...[
                Text(
                  widget.taskTitle!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],

              // Session Type
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _isWorkSession
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isWorkSession ? 'FOCUS SESSION' : 'BREAK TIME',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _isWorkSession
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSecondaryContainer,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Timer Circle
              SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isWorkSession
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_completedPomodoros} pomodoros completed',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isRunning) ...[
                    FilledButton.icon(
                      onPressed: _startTimer,
                      icon: const Icon(Icons.play_arrow, size: 28),
                      label: const Text('Start'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ] else ...[
                    FilledButton.icon(
                      onPressed: _pauseTimer,
                      icon: const Icon(Icons.pause, size: 28),
                      label: const Text('Pause'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Pomodoro Technique Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pomodoro Technique',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.timer, '25 min focus sessions'),
                      _buildInfoRow(Icons.coffee, '5 min short breaks'),
                      _buildInfoRow(
                        Icons.self_improvement,
                        '15 min long break after 4',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Research shows this technique improves focus and reduces mental fatigue.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
