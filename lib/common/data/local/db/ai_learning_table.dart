import 'package:drift/drift.dart';

class AiLearning extends Table {
  /// ключевое слово ("грин грин", "пятёрочка")
  TextColumn get keyword => text()();

  /// категория
  TextColumn get categoryId => text()();

  /// сколько раз использовалось (будет полезно позже)
  IntColumn get usageCount => integer().withDefault(const Constant(1))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
