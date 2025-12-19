/// Мок-данные для аналитики (временно)
/// Позже будут приходить из backend

class MonthlyExpense {
  final String month;
  final double amount;

  const MonthlyExpense({required this.month, required this.amount});
}

class CategoryExpense {
  final String category;
  final double amount;

  const CategoryExpense({required this.category, required this.amount});
}

/// Расходы по месяцам (график)
const List<MonthlyExpense> mockMonthlyExpenses = [
  MonthlyExpense(month: 'Янв', amount: 12000),
  MonthlyExpense(month: 'Фев', amount: 15000),
  MonthlyExpense(month: 'Мар', amount: 9800),
  MonthlyExpense(month: 'Апр', amount: 13400),
  MonthlyExpense(month: 'Май', amount: 16000),
];

/// Расходы по категориям
const List<CategoryExpense> mockCategoryExpenses = [
  CategoryExpense(category: 'Еда', amount: 6200),
  CategoryExpense(category: 'Развлечения', amount: 3400),
  CategoryExpense(category: 'Транспорт', amount: 2100),
  CategoryExpense(category: 'Игры', amount: 1300),
];
