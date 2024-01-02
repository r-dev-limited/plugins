import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rdev_riverpod_versioning/application/fireway_data_service.dart';
import 'package:rdev_riverpod_versioning/domain/fireway_model.dart';

import 'fireway_data_service_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  QuerySnapshot,
  QueryDocumentSnapshot,
  FirewayModel,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirewayDataService', () {
    late FirebaseFirestore firestoreMock;
    late FirewayDataService firewayDataService;

    setUp(() {
      firestoreMock = MockFirebaseFirestore();
      firewayDataService = FirewayDataService(firestoreMock);
    });

    test('getLatestBackendVersion should return FirewayModel', () async {
      final queryMock = MockCollectionReference<Map<String, dynamic>>();
      final snapshotMock = MockQuerySnapshot<Map<String, dynamic>>();
      final docSnapshotMock = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(firestoreMock.collection('fireway')).thenReturn(queryMock);
      when(queryMock.orderBy('installed_on', descending: true))
          .thenReturn(queryMock);
      when(queryMock.limit(1)).thenReturn(queryMock);
      when(queryMock.get()).thenAnswer((_) => Future.value(snapshotMock));
      when(snapshotMock.docs).thenReturn([docSnapshotMock]);
      when(docSnapshotMock.id).thenReturn('value');
      when(docSnapshotMock.data()).thenReturn({
        'uid': 'value',
        'description': 'value',
        'version': 'value',
        'success': true,
        'script': 'value',
        'installedOn': DateTime.now().toIso8601String(),
        'executionTime': 0
      });
      final result = await firewayDataService.getLatestBackendVersion();
      expect(result.description, equals('value'));
    });

    test(
        'getLatestBackendVersion should throw FirewayDataServiceException when Firestore throws an error',
        () async {
      final queryMock = MockCollectionReference<Map<String, dynamic>>();
      when(firestoreMock.collection('fireway')).thenReturn(queryMock);
      when(queryMock.orderBy('installed_on', descending: true))
          .thenReturn(queryMock);
      when(queryMock.limit(1)).thenReturn(queryMock);
      when(queryMock.get()).thenThrow(Exception('Firestore error'));

      expect(() async => await firewayDataService.getLatestBackendVersion(),
          throwsA(isInstanceOf<FirewayDataServiceException>()));
    });

    test(
        'getLatestBackendVersion should throw FirewayDataServiceException when no Fireway version data is found',
        () async {
      final queryMock = MockCollectionReference<Map<String, dynamic>>();
      final snapshotMock = MockQuerySnapshot<Map<String, dynamic>>();
      when(firestoreMock.collection('fireway')).thenReturn(queryMock);
      when(queryMock.orderBy('installed_on', descending: true))
          .thenReturn(queryMock);
      when(queryMock.limit(1)).thenReturn(queryMock);
      when(queryMock.get()).thenAnswer((_) => Future.value(snapshotMock));
      when(snapshotMock.docs).thenReturn([]);

      expect(() async => await firewayDataService.getLatestBackendVersion(),
          throwsA(isInstanceOf<FirewayDataServiceException>()));
    });
  });
}
