import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/features/core/data/gateway/app_gateway.dart';

import '../../mocks.mocks.dart';

class _Gateway extends AppGateway {
  _Gateway(super.talker);

  Future<int> doIt(Future<int> Function() op) => safeCall<int>(op);
  Future<void> doVoid(Future<void> Function() op) => voidSafeCall(op);
}

void main() {
  late MockTalker talker;
  late _Gateway gateway;

  setUp(() {
    talker = MockTalker();
    gateway = _Gateway(talker);
  });

  test('safeCall returns the operation result on success', () async {
    final result = await gateway.doIt(() async => 42);
    expect(result, 42);
    verifyNever(talker.handle(any, any, any));
  });

  test('safeCall logs DioException via Talker and rethrows', () async {
    final dioError = DioException(
      requestOptions: RequestOptions(path: '/x'),
      message: 'boom',
    );

    await expectLater(
      gateway.doIt(() async => throw dioError),
      throwsA(isA<DioException>()),
    );
    verify(talker.handle(dioError, any, any)).called(1);
  });

  test('safeCall logs other Exception via Talker and rethrows', () async {
    final exception = Exception('plain');

    await expectLater(
      gateway.doIt(() async => throw exception),
      throwsA(isA<Exception>()),
    );
    verify(talker.handle(exception, any, any)).called(1);
  });

  test('voidSafeCall completes when operation completes', () async {
    var ran = false;
    await gateway.doVoid(() async {
      ran = true;
    });
    expect(ran, isTrue);
  });
}
