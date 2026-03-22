import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../providers/selected_month_provider.dart';

/// Диалог быстрого выбора месяца и года
class MonthPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onSelected;

  const MonthPickerDialog({
    super.key,
    required this.initialDate,
    required this.onSelected,
  });

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final months = List.generate(
      12,
      (i) => getMonthName(DateTime(2024, i + 1)),
    );

    return AlertDialog(
      title: const Text('Выберите месяц'),
      backgroundColor: AppTheme.backgroundColor,
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Выбор года
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _selectedYear--),
                ),
                Text(
                  '$_selectedYear',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _selectedYear++),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Сетка месяцев
            SizedBox(
              height: 250,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = _selectedMonth == month;
                  return GestureDetector(
                    onTap: () {
                      widget.onSelected(DateTime(_selectedYear, month, 1));
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          months[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            widget.onSelected(DateTime(_selectedYear, _selectedMonth, 1));
            Navigator.pop(context);
          },
          child: const Text('Выбрать'),
        ),
      ],
    );
  }
}
