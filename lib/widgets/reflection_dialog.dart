import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/reflection.dart';
import '../providers/behavior_tracking_provider.dart';

class ReflectionDialog extends StatefulWidget {
  final String studentId;

  const ReflectionDialog({super.key, required this.studentId});

  @override
  State<ReflectionDialog> createState() => _ReflectionDialogState();
}

class _ReflectionDialogState extends State<ReflectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _completedController = TextEditingController();
  final _challengesController = TextEditingController();
  final _improvementsController = TextEditingController();
  int _productivityRating = 3;

  @override
  void dispose() {
    _completedController.dispose();
    _challengesController.dispose();
    _improvementsController.dispose();
    super.dispose();
  }

  void _saveReflection() {
    if (_formKey.currentState!.validate()) {
      final reflection = Reflection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: widget.studentId,
        date: DateTime.now(),
        completedToday: _completedController.text,
        challenges: _challengesController.text,
        improvements: _improvementsController.text,
        productivityRating: _productivityRating,
      );

      Provider.of<BehaviorTrackingProvider>(
        context,
        listen: false,
      ).addReflection(reflection);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Daily reflection saved!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Daily Reflection',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // What did you finish today?
                TextFormField(
                  controller: _completedController,
                  decoration: const InputDecoration(
                    labelText: 'What did you finish today? *',
                    hintText: 'List your accomplishments...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.check_circle_outline),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please share what you accomplished';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Challenges faced
                TextFormField(
                  controller: _challengesController,
                  decoration: const InputDecoration(
                    labelText: 'What challenges did you face?',
                    hintText: 'Optional',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.warning_amber),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // What can you improve?
                TextFormField(
                  controller: _improvementsController,
                  decoration: const InputDecoration(
                    labelText: 'What can you improve tomorrow?',
                    hintText: 'Optional',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lightbulb_outline),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Productivity Rating
                const Text(
                  'How productive were you today?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    final rating = index + 1;
                    final isSelected = _productivityRating == rating;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _productivityRating = rating;
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$rating',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getRatingLabel(rating),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Info text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Daily reflection improves self-awareness and helps track your progress.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Skip'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _saveReflection,
                      child: const Text('Save Reflection'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Low';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
