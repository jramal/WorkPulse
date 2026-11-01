import 'package:drift/drift.dart';

import '../data/database.dart';

/// Break-type CRUD (CRS FR-1.6/FR-1.7).
class BreakTypeRepository {
  BreakTypeRepository(this._db);

  final AppDatabase _db;

  Stream<List<BreakType>> watchActive() {
    return (_db.select(_db.breakTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .watch();
  }

  Stream<List<BreakType>> watchAll() {
    return (_db.select(_db.breakTypes)..orderBy([
          (t) => OrderingTerm.asc(t.createdAt),
          (t) => OrderingTerm.asc(t.id),
        ]))
        .watch();
  }

  Future<BreakType?> find(int id) {
    return (_db.select(
      _db.breakTypes,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<bool> isNameTaken(String name, {int? exceptId}) async {
    final all = await _db.select(_db.breakTypes).get();
    return all.any(
      (t) =>
          t.id != exceptId && t.name.toLowerCase() == name.trim().toLowerCase(),
    );
  }

  Future<int> add(BreakTypesCompanion values) {
    return _db.into(_db.breakTypes).insert(values);
  }

  Future<void> update(int id, BreakTypesCompanion values) {
    return (_db.update(
      _db.breakTypes,
    )..where((t) => t.id.equals(id))).write(values);
  }

  /// Removes the type outright if nothing refers to it. A type used by past
  /// activity is archived instead, so history keeps its label (NFR-6).
  /// Returns true if it was archived rather than deleted.
  Future<bool> delete(int id) {
    return _db.transaction(() async {
      final used =
          await (_db.select(_db.activities)
                ..where((a) => a.breakTypeId.equals(id))
                ..limit(1))
              .getSingleOrNull();
      if (used != null) {
        await update(id, const BreakTypesCompanion(isActive: Value(false)));
        return true;
      }
      await (_db.delete(_db.breakTypes)..where((t) => t.id.equals(id))).go();
      return false;
    });
  }

  Future<void> restore(int id) {
    return update(id, const BreakTypesCompanion(isActive: Value(true)));
  }
}
