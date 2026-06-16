// Файл: lib/common/widgets/month_picker_dialog.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../providers/selected_month_provider.dart';
import '../utils/app_theme.dart';

class MonthPickerDialog extends StatefulWidget {
  const MonthPickerDialog({
    super.key,
    required this.initialDate,
    required this.onSelected,
  });

  final DateTime initialDate;
  final ValueChanged<DateTime> onSelected;

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
    final colors = AppTheme.colorsOf(context);
    final strings = AppStrings.of(context);
    final months = List.generate(
      12,
      (i) => getMonthName(
        DateTime(2024, i + 1),
        short: true,
        languageCode: strings.isRu ? 'ru' : 'en',
      ),
    );

    return AlertDialog(
      title: Text(strings.isRu ? 'Выберите месяц' : 'Choose month'),
      backgroundColor: colors.surface,
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                        color: isSelected ? colors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? colors.primary : colors.border,
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
          child: Text(strings.cancel),
        ),
        TextButton(
          onPressed: () {
            widget.onSelected(DateTime(_selectedYear, _selectedMonth, 1));
            Navigator.pop(context);
          },
          child: Text(strings.isRu ? 'Выбрать' : 'Select'),
        ),
      ],
    );
  }
}
