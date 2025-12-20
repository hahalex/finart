import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/categories_repository_provider.dart';
import '../data/default_categories.dart';
import 'main_navigation.dart';

/// Виджет инициализации приложения
class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: _initCategories(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return const MainNavigation();
      },
    );
  }

  /// Инициализация стандартных категорий
  Future<void> _initCategories(WidgetRef ref) async {
    final repo = ref.read(categoriesRepositoryProvider);

    final hasCategories = await repo.hasCategories();
    if (!hasCategories) {
      for (final category in defaultCategories) {
        await repo.insertCategory(category);
      }
    }
  }
}
