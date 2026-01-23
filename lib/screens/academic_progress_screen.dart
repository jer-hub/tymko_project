import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/behavior_tracking_provider.dart';
import '../models/academic_performance.dart';

class AcademicProgressScreen extends StatelessWidget {
  final String studentId;
  final String studentName;

  const AcademicProgressScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$studentName\'s Academic Progress'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<BehaviorTrackingProvider>(
        builder: (context, provider, child) {
          final report = provider.getAcademicProgressReport(studentId);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  '📊 Performance Correlations',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'How behavior impacts academic outcomes',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Study Duration vs Completion
                _buildCorrelationCard(
                  context,
                  report['studyVsCompletion'] as PerformanceCorrelation,
                  Icons.schedule,
                  Colors.blue,
                ),
                const SizedBox(height: 16),

                // Consistency vs Punctuality
                _buildCorrelationCard(
                  context,
                  report['consistencyVsPunctuality'] as PerformanceCorrelation,
                  Icons.calendar_today,
                  Colors.green,
                ),
                const SizedBox(height: 16),

                // Cramming vs Stability
                _buildCorrelationCard(
                  context,
                  report['crammingVsStability'] as PerformanceCorrelation,
                  Icons.trending_down,
                  Colors.orange,
                ),
                const SizedBox(height: 24),

                // Recommendation Impact
                _buildRecommendationImpact(
                  context,
                  report['recommendationImpact'] as Map<String, dynamic>,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCorrelationCard(
    BuildContext context,
    PerformanceCorrelation correlation,
    IconData icon,
    Color color,
  ) {
    final isPositive = correlation.isPositive;
    final strengthColor = _getStrengthColor(correlation.strength);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        correlation.metric,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: strengthColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${correlation.strength} ${isPositive ? '📈' : '📉'}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: strengthColor,
                              ),
                            ),
                          ),
                          Text(
                            'r = ${correlation.correlationCoefficient.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Finding:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    correlation.interpretation,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, size: 20, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Action:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          correlation.recommendation,
                          style: TextStyle(fontSize: 13, color: color),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationImpact(
    BuildContext context,
    Map<String, dynamic> impact,
  ) {
    if (impact['hasEnoughData'] == false) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.timeline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                impact['message'],
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final improvements = impact['improvements'] as Map<String, dynamic>;
    final before = impact['before'] as Map<String, double>;
    final after = impact['after'] as Map<String, double>;
    final overallImprovement = impact['overallImprovement'] as double;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_graph,
                    color: Colors.purple,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recommendation Impact',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        impact['interpretation'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Overall improvement indicator
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: overallImprovement > 0
                      ? [Colors.green.shade50, Colors.green.shade100]
                      : [Colors.orange.shade50, Colors.orange.shade100],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    overallImprovement > 0
                        ? Icons.trending_up
                        : Icons.trending_flat,
                    color: overallImprovement > 0
                        ? Colors.green
                        : Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Text(
                        '${overallImprovement > 0 ? '+' : ''}${overallImprovement.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: overallImprovement > 0
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                      Text(
                        'Overall Change',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Individual metrics
            _buildMetricComparison(
              'Task Completion',
              before['completionRate']!,
              after['completionRate']!,
              improvements['completion'] as double,
              Icons.check_circle,
            ),
            const Divider(height: 24),
            _buildMetricComparison(
              'Punctuality',
              before['punctualityRate']!,
              after['punctualityRate']!,
              improvements['punctuality'] as double,
              Icons.schedule,
            ),
            const Divider(height: 24),
            _buildMetricComparison(
              'Consistency',
              before['consistency']!,
              after['consistency']!,
              improvements['consistency'] as double,
              Icons.calendar_today,
            ),
            const Divider(height: 24),
            _buildMetricComparison(
              'Cramming Reduction',
              before['crammingRate']!,
              after['crammingRate']!,
              improvements['crammingReduction'] as double,
              Icons.trending_down,
              inverse: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricComparison(
    String label,
    double beforeValue,
    double afterValue,
    double change,
    IconData icon, {
    bool inverse = false,
  }) {
    final isImprovement = inverse ? change > 0 : change > 0;
    final changeColor = isImprovement ? Colors.green : Colors.grey;

    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Text(
                  '${beforeValue.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Icon(Icons.arrow_forward, size: 16),
                Text(
                  '${afterValue.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                color: changeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStrengthColor(String strength) {
    switch (strength) {
      case 'Strong':
        return Colors.green;
      case 'Moderate':
        return Colors.orange;
      case 'Weak':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
