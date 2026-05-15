import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/core/database/database_provider.dart';
import 'package:hissab_dz/features/projects/data/repositories/project_repository.dart';
import 'package:hissab_dz/features/projects/domain/entities/expense_type.dart';
import 'package:hissab_dz/features/projects/domain/entities/project.dart';
import 'package:hissab_dz/features/projects/domain/entities/project_expense.dart';

import 'package:hissab_dz/features/projects/domain/entities/project_photo.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProjectRepository(db);
});

final projectsListProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).watchProjects();
});

final projectDetailsProvider = FutureProvider.family<Project?, int>((
  ref,
  projectId,
) {
  return ref.watch(projectRepositoryProvider).getProjectById(projectId);
});

final projectExpensesProvider =
    StreamProvider.family<List<ProjectExpense>, int>((ref, projectId) {
      return ref
          .watch(projectRepositoryProvider)
          .watchExpensesForProject(projectId);
    });

final projectPhotosProvider =
    StreamProvider.family<List<ProjectPhoto>, int>((ref, projectId) {
  return ref.watch(projectRepositoryProvider).watchPhotosForProject(projectId);
});

final expensesListProvider = StreamProvider<List<ProjectExpense>>((ref) {
  return ref.watch(projectRepositoryProvider).watchExpenses();
});

final expenseTypesProvider = StreamProvider<List<ExpenseType>>((ref) {
  return ref.watch(projectRepositoryProvider).watchExpenseTypes();
});
