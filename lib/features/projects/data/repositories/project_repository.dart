import 'package:drift/drift.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/features/projects/domain/entities/expense_type.dart'
    as entity;
import 'package:hissab_dz/features/projects/domain/entities/project.dart'
    as entity;
import 'package:hissab_dz/features/projects/domain/entities/project_expense.dart'
    as entity;
import 'package:hissab_dz/features/projects/domain/entities/project_photo.dart';
import 'package:hissab_dz/features/projects/domain/entities/project_status.dart';

class ProjectRepository {
  final AppDatabase _db;

  ProjectRepository(this._db);

  Stream<List<entity.Project>> watchProjects() {
    return _db.select(_db.projects).watch().asyncMap((rows) async {
      final projects = <entity.Project>[];
      for (final row in rows) {
        projects.add(await _mapProjectWithTotals(row));
      }
      return projects;
    });
  }

  Future<entity.Project?> getProjectById(int id) async {
    final row = await (_db.select(
      _db.projects,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _mapProjectWithTotals(row);
  }

  Future<int> createProject(entity.Project project) {
    return _db.into(_db.projects).insert(
          ProjectsCompanion.insert(
            clientId: Value(project.clientId),
            name: project.name,
            siteAddress: Value(project.siteAddress),
            status: Value(projectStatusCode(project.status)),
            description: Value(project.description),
            startDate: Value(project.startDate),
            endDate: Value(project.endDate),
          ),
        );
  }

  Future<void> updateProject(entity.Project project) {
    return (_db.update(
      _db.projects,
    )..where((t) => t.id.equals(project.id!))).write(
      ProjectsCompanion(
        name: Value(project.name),
        clientId: Value(project.clientId),
        siteAddress: Value(project.siteAddress),
        status: Value(projectStatusCode(project.status)),
        description: Value(project.description),
        startDate: Value(project.startDate),
        endDate: Value(project.endDate),
      ),
    );
  }

  Future<void> deleteProject(int id) {
    return (_db.delete(_db.projects)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<entity.ProjectExpense>> watchExpensesForProject(int projectId) {
    final query = _db.select(_db.projectExpenses).join([
      leftOuterJoin(
        _db.expenseTypes,
        _db.expenseTypes.id.equalsExp(_db.projectExpenses.expenseTypeId),
      ),
    ])..where(_db.projectExpenses.projectId.equals(projectId));

    return query.watch().map((rows) {
      return rows.map((row) {
        final expense = row.readTable(_db.projectExpenses);
        final type = row.readTableOrNull(_db.expenseTypes);
        return entity.ProjectExpense(
          id: expense.id,
          projectId: expense.projectId,
          expenseTypeId: expense.expenseTypeId,
          label: expense.label,
          amount: expense.amount,
          date: expense.date,
          supplier: expense.supplier,
          paymentMethod: expense.paymentMethod,
          receiptPath: expense.receiptPath,
          notes: expense.notes,
          expenseTypeName: type?.name,
        );
      }).toList();
    });
  }

  Stream<List<entity.ProjectExpense>> watchExpenses() {
    final query = _db.select(_db.projectExpenses).join([
      leftOuterJoin(
        _db.expenseTypes,
        _db.expenseTypes.id.equalsExp(_db.projectExpenses.expenseTypeId),
      ),
      leftOuterJoin(
        _db.projects,
        _db.projects.id.equalsExp(_db.projectExpenses.projectId),
      ),
    ])..orderBy([OrderingTerm.desc(_db.projectExpenses.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final expense = row.readTable(_db.projectExpenses);
        final type = row.readTableOrNull(_db.expenseTypes);
        final project = row.readTableOrNull(_db.projects);
        return entity.ProjectExpense(
          id: expense.id,
          projectId: expense.projectId,
          expenseTypeId: expense.expenseTypeId,
          label: expense.label,
          amount: expense.amount,
          date: expense.date,
          supplier: expense.supplier,
          paymentMethod: expense.paymentMethod,
          receiptPath: expense.receiptPath,
          notes: expense.notes,
          expenseTypeName: type?.name,
          projectName: project?.name,
        );
      }).toList();
    });
  }

  Future<int> addExpense(entity.ProjectExpense expense) {
    return _db.into(_db.projectExpenses).insert(
          ProjectExpensesCompanion.insert(
            projectId: Value(expense.projectId),
            expenseTypeId: Value(expense.expenseTypeId),
            label: expense.label,
            amount: expense.amount,
            date: Value(expense.date),
            supplier: Value(expense.supplier),
            paymentMethod: Value(expense.paymentMethod),
            receiptPath: Value(expense.receiptPath),
            notes: Value(expense.notes),
          ),
        );
  }

  Future<void> deleteExpense(int id) {
    return (_db.delete(
      _db.projectExpenses,
    )..where((t) => t.id.equals(id))).go();
  }

  Stream<List<entity.ExpenseType>> watchExpenseTypes() {
    return _db.select(_db.expenseTypes).watch().map(
          (rows) => rows
              .map(
                (row) => entity.ExpenseType(
                  id: row.id,
                  name: row.name,
                  createdAt: row.createdAt,
                ),
              )
              .toList(),
        );
  }

  Future<int> addExpenseType(String name) {
    return _db
        .into(_db.expenseTypes)
        .insert(ExpenseTypesCompanion.insert(name: name));
  }

  Future<void> deleteExpenseType(int id) {
    return (_db.delete(_db.expenseTypes)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<ProjectPhoto>> watchPhotosForProject(int projectId) {
    return (_db.select(_db.projectPhotos)
          ..where((t) => t.projectId.equals(projectId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows
            .map((row) => ProjectPhoto(
                  id: row.id,
                  projectId: row.projectId,
                  imagePath: row.imagePath,
                  category: row.category,
                  comment: row.comment,
                  createdAt: row.createdAt,
                ))
            .toList());
  }

  Future<int> addProjectPhoto(ProjectPhoto photo) {
    return _db.into(_db.projectPhotos).insert(
          ProjectPhotosCompanion.insert(
            projectId: photo.projectId,
            imagePath: photo.imagePath,
            category: photo.category,
            comment: Value(photo.comment),
            createdAt: Value(photo.createdAt),
          ),
        );
  }

  Future<void> deleteProjectPhoto(int id) {
    return (_db.delete(_db.projectPhotos)..where((t) => t.id.equals(id))).go();
  }

  Future<entity.Project> _mapProjectWithTotals(ProjectData row) async {
    final invoiceRows = await (_db.select(
      _db.invoices,
    )..where((t) => t.projectId.equals(row.id))).get();
    final expenseRows = await (_db.select(
      _db.projectExpenses,
    )..where((t) => t.projectId.equals(row.id))).get();
    return entity.Project(
      id: row.id,
      clientId: row.clientId,
      name: row.name,
      siteAddress: row.siteAddress,
      status: projectStatusFromCode(row.status),
      clientName: row.clientId == null
          ? null
          : (await (_db.select(
              _db.clients,
            )..where((t) => t.id.equals(row.clientId!))).getSingleOrNull())
                ?.name,
      description: row.description,
      startDate: row.startDate,
      endDate: row.endDate,
      createdAt: row.createdAt,
      invoiceTotal: invoiceRows.fold(
        0.0,
        (sum, invoice) => sum + invoice.total,
      ),
      expenseTotal: expenseRows.fold(
        0.0,
        (sum, expense) => sum + expense.amount,
      ),
    );
  }
}
