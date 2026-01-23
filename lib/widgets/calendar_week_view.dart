import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarWeekView extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final VoidCallback? onExpandCalendar;

  const CalendarWeekView({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.onExpandCalendar,
  });

  List<DateTime> _getWeekDates() {
    final weekStart = selectedDate.subtract(
      Duration(days: selectedDate.weekday % 7),
    );
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Column(
        children: [
          // Month/Year header with navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    final previousWeek = selectedDate.subtract(
                      const Duration(days: 7),
                    );
                    onDateSelected(previousWeek);
                  },
                  tooltip: 'Previous Week',
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onExpandCalendar,
                    child: Text(
                      DateFormat('MMMM yyyy').format(selectedDate),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (onExpandCalendar != null)
                  IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: onExpandCalendar,
                    tooltip: 'Full Calendar',
                  ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final nextWeek = selectedDate.add(const Duration(days: 7));
                    onDateSelected(nextWeek);
                  },
                  tooltip: 'Next Week',
                ),
              ],
            ),
          ),
          // Week view
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: weekDates.map((date) {
              final isSelected =
                  date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final isToday =
                  date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  width: 48,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat(
                          'EEE',
                        ).format(date).substring(0, 3).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isToday && !isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          DateFormat('d').format(date),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
