class MonthlyExpenseData {
  final int year;
  final int month;
  final double total;

  const MonthlyExpenseData({
    required this.year,
    required this.month,
    required this.total,
  });
}

class CategoryExpenseData {
  final String categoryId;
  final double total;

  const CategoryExpenseData({required this.categoryId, required this.total});
}
