import 'package:drift/drift.dart';

import '../data/database.dart';

class TaskRepository {
  TaskRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$TasksTable, Task> get _ordered {
    return _db.select(_db.tasks)..orderBy([
      (t) => OrderingTerm.asc(t.isDone),
      (t) => OrderingTerm(expression: t.dueAt, nulls: NullsOrder.last),
      (t) => OrderingTerm.desc(t.id),
    ]);
  }

  /// Unfinished first, then soonest due, then newest.
  Stream<List<Task>> watchAll() => _ordered.watch();

  Future<List<Task>> getAll() => _ordered.get();

  Future<Task> find(int id) {
    return (_db.select(_db.tasks)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<int> add(TasksCompanion values) {
    return _db.into(_db.tasks).insert(values);
  }

  Future<void> update(int id, TasksCompanion values) {
    return (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(values);
  }

  Future<void> delete(int id) {
    return (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
  }
}
