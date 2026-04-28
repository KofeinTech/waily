import 'package:injectable/injectable.dart';

import '../../domain/entities/hydration_entry.dart';
import '../../domain/repositories/hydration_repository.dart';
import '../datasources/hydration_datasource.dart';
import '../mappers/hydration_mappers.dart';

@LazySingleton(as: HydrationRepository)
class HydrationRepositoryImpl implements HydrationRepository {
  HydrationRepositoryImpl(this._ds);

  final HydrationDatasource _ds;

  @override
  Future<HydrationEntry> add(int amountMl) async {
    final now = DateTime.now();
    final id = await _ds.insert(amountMl: amountMl, createdAt: now);
    return HydrationEntry(id: id, amountMl: amountMl, createdAt: now);
  }

  @override
  Future<HydrationEntry> update(HydrationEntry entry) async {
    await _ds.updateById(
      entry.id,
      amountMl: entry.amountMl,
      createdAt: entry.createdAt,
    );
    final row = await _ds.getById(entry.id);
    if (row == null) {
      throw StateError('HydrationEntry ${entry.id} disappeared after update');
    }
    return row.toEntity();
  }

  @override
  Future<HydrationEntry?> getById(int id) async =>
      (await _ds.getById(id))?.toEntity();

  @override
  Future<List<HydrationEntry>> getAll() async {
    final rows = await _ds.getAllOrderedByCreatedAtDesc();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<void> delete(int id) => _ds.deleteById(id);

  @override
  Future<int> sumToday() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    return _ds.sumSince(startOfToday);
  }
}
