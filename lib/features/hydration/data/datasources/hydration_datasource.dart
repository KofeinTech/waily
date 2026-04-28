import '../../../../core/database/app_database.dart';

abstract class HydrationDatasource {
  Future<int> insert({required int amountMl, required DateTime createdAt});

  Future<void> updateById(
    int id, {
    required int amountMl,
    required DateTime createdAt,
  });

  Future<HydrationsData?> getById(int id);

  Future<List<HydrationsData>> getAllOrderedByCreatedAtDesc();

  Future<void> deleteById(int id);

  /// SUM of amount_ml for createdAt >= [since].
  Future<int> sumSince(DateTime since);
}
