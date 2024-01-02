import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_riverpod_versioning/application/fireway_data_service.dart';
import 'package:rdev_riverpod_versioning/application/fireway_service.dart';
import 'package:rdev_riverpod_versioning/domain/fireway_model.dart';
import 'package:rdev_riverpod_versioning/domain/fireway_vo.dart';

import 'fireway_service_test.mocks.dart';

@GenerateMocks([
  FirewayDataService,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirewayService', () {
    late FirewayService firewayService;
    late MockFirewayDataService mockFirewayDataService;

    setUp(() {
      mockFirewayDataService = MockFirewayDataService();
      firewayService = FirewayService(mockFirewayDataService);
    });

    test('getLatestBackendVersion should return FirewayVO', () async {
      final expectedModel = FirewayModel(
          uid: 'uid',
          version: 'version',
          description: 'description',
          success: true,
          script: 'script',
          installedOn: DateTime.now(),
          executionTime: 0);
      final expectedVO = FirewayVO.fromFirewayModel(expectedModel);
      when(mockFirewayDataService.getLatestBackendVersion())
          .thenAnswer((_) => Future.value(expectedModel));

      final result = await firewayService.getLatestBackendVersion();
      expect(result, equals(expectedVO));
      verify(mockFirewayDataService.getLatestBackendVersion()).called(1);
    });

    test(
        'getLatestBackendVersion should throw FirewayServiceException when FirewayDataService throws RdevException',
        () async {
      final expectedException = RdevException(message: 'Test exception');
      when(mockFirewayDataService.getLatestBackendVersion())
          .thenThrow(expectedException);

      expect(() async => await firewayService.getLatestBackendVersion(),
          throwsA(isInstanceOf<FirewayServiceException>()));
      verify(mockFirewayDataService.getLatestBackendVersion()).called(1);
    });

    test(
        'getLatestBackendVersion should throw FirewayServiceException when FirewayDataService throws non-RdevException',
        () async {
      final expectedException = Exception('Test exception');
      when(mockFirewayDataService.getLatestBackendVersion())
          .thenThrow(expectedException);

      expect(() async => await firewayService.getLatestBackendVersion(),
          throwsA(isInstanceOf<FirewayServiceException>()));
      verify(mockFirewayDataService.getLatestBackendVersion()).called(1);
    });
  });
}
