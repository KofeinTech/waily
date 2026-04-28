import '../entities/hydration_entry.dart';

abstract class HydrationRepository {
  Future<HydrationEntry> add(int amountMl);
  Future<HydrationEntry> update(HydrationEntry entry);
  Future<HydrationEntry?> getById(int id);
  Future<List<HydrationEntry>> getAll();
  Future<void> delete(int id);

  /// Total ml drunk today (local start-of-day). Demonstrates aggregation.
  Future<int> sumToday();
}
