import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/behavior_tracking_provider.dart';

class PatternWarningBanner extends StatelessWidget {
  final String studentId;

  const PatternWarningBanner({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Consumer<BehaviorTrackingProvider>(
      builder: (context, provider, child) {
        final warnings = provider.detectEarlyWarnings(studentId);

        if (warnings['requiresIntervention'] != true) {
          return const SizedBox.shrink();
        }

        final warningList = warnings['warnings'] as List<String>;
        final severity = warnings['severity'] as String;

        Color backgroundColor;
        Color textColor;
        IconData icon;

        switch (severity) {
          case 'high':
            backgroundColor = Colors.red.shade100;
            textColor = Colors.red.shade900;
            icon = Icons.warning_amber_rounded;
            break;
          case 'medium':
            backgroundColor = Colors.orange.shade100;
            textColor = Colors.orange.shade900;
            icon = Icons.info_outline;
            break;
          default:
            backgroundColor = Colors.blue.shade100;
            textColor = Colors.blue.shade900;
            icon = Icons.lightbulb_outline;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: textColor.withOpacity(0.3), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: textColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      severity == 'high'
                          ? 'Attention Needed'
                          : 'Pattern Detected',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline, color: textColor),
                    onPressed: () => _showDetailsDialog(context, provider),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...warningList.map(
                (warning) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: textColor)),
                      Expanded(
                        child: Text(
                          warning,
                          style: TextStyle(color: textColor, fontSize: 13),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Suggestions:',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              ...provider
                  .getAdaptiveSuggestions(studentId)
                  .take(2)
                  .map(
                    (suggestion) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        suggestion,
                        style: TextStyle(color: textColor, fontSize: 13),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  void _showDetailsDialog(
    BuildContext context,
    BehaviorTrackingProvider provider,
  ) {
    final patterns = provider.analyzePatterns(studentId);
    final completionPatterns = provider.getCompletionTimePatterns(studentId);
    final suggestedSchedule = provider.getSuggestedSchedule(studentId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Detailed Analysis'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSection('Current Patterns', [
                'Consistency: ${patterns['consistency']}',
                'Procrastination: ${patterns['procrastination']}',
                'Productivity: ${patterns['productivity']}',
                'Avg Tasks/Day: ${patterns['avgTasksPerDay']}',
              ]),
              const SizedBox(height: 16),
              _buildSection('Completion Behavior', [
                'Pattern: ${_formatPattern(completionPatterns['pattern'])}',
                'On-time: ${completionPatterns['completedOnTime']} tasks',
                'Late: ${completionPatterns['completedLate']} tasks',
                'Rate: ${completionPatterns['procrastinationRate']}%',
              ]),
              const SizedBox(height: 16),
              _buildSection('Recommendation', [
                completionPatterns['recommendation'],
              ]),
              const SizedBox(height: 16),
              Text(
                'Suggested Study Schedule',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              ...suggestedSchedule.map(
                (slot) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(slot['activity']),
                    subtitle: Text(
                      '${slot['time']} • ${slot['duration']}${slot['reason'] != null ? '\n${slot['reason']}' : ''}',
                    ),
                    dense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 2),
            child: Text('• $item', style: const TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }

  String _formatPattern(String pattern) {
    switch (pattern) {
      case 'early_completer':
        return 'Early Completer ✅';
      case 'chronic_procrastinator':
        return 'Chronic Procrastinator ⚠️';
      case 'mixed':
        return 'Mixed Pattern';
      default:
        return 'Analyzing...';
    }
  }
}
