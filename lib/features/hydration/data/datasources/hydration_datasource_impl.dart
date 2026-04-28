import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../core/data/gateway/app_gateway.dart';
import 'hydration_datasource.dart';

@Injectable(as: HydrationDatasource)
class HydrationDatasourceImpl extends AppGateway
    implements HydrationDatasource {
  HydrationDatasourceImpl(super.talker, this._db);

  final AppDatabase _db;

  @override
  Future<int> insert({
    required int amountMl,
    required DateTime createdAt,
  }) =>
      safeCall(() => _db.into(_db.hydrations).insert(
            HydrationsCompanion.insert(
              amountMl: amountMl, createdAt: createdAt,
            ),
          ));

  @override
  Future<void> updateById(
    int id, {
    required int amountMl,
    required DateTime createdAt,
  }) =>
      voidSafeCall(() async {
        await (_db.update(_db.hydrations)..where((t) => t.id.equals(id)))
            .write(HydrationsCompanion(
          amountMl: Value(amountMl),
          createdAt: Value(createdAt),
        ));
      });

  @override
  Future<HydrationsData?> getById(int id) => safeCall(
        () => (_db.select(_db.hydrations)..where((t) => t.id.equals(id)))
            .getSingleOrNull(),
      );

  @override
  Future<List<HydrationsData>> getAllOrderedByCreatedAtDesc() => safeCall(
        () => (_db.select(_db.hydrations)
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get(),
      );

  @override
  Future<void> deleteById(int id) => voidSafeCall(() async {
        await (_db.delete(_db.hydrations)..where((t) => t.id.equals(id))).go();
      });

  @override
  Future<int> sumSince(DateTime since) => safeCall(() async {
        final sumExpr = _db.hydrations.amountMl.sum();
        final query = _db.selectOnly(_db.hydrations)
          ..addColumns([sumExpr])
          ..where(_db.hydrations.createdAt.isBiggerOrEqualValue(since));
        final row = await query.getSingle();
        return row.read(sumExpr) ?? 0;
      });
}
