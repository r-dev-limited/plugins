import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rdev_riverpod_firebase_auth/application/auth_data_service.dart';

///
import 'auth_data_service_test.mocks.dart';

// Generate mocks for dependencies
@GenerateMocks([
  FirebaseAuth,
  FirebaseFunctions,
  GoogleSignIn,
  User,
  UserCredential,
])
void main() {
  // Call TestWidgetsFlutterBinding.ensureInitialized() at the beginning of main()
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthDataService', () {
    late AuthDataService authDataService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseFunctions mockFirebaseFunctions;
    late MockGoogleSignIn mockGoogleSignIn;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockFirebaseFunctions = MockFirebaseFunctions();
      mockGoogleSignIn = MockGoogleSignIn();

      authDataService = AuthDataService(
        mockFirebaseAuth,
        mockFirebaseFunctions,
        mockGoogleSignIn,
      );
    });

    group('signInAnonymously', () {
      test('should sign in anonymously and return user credential', () async {
        // Arrange
        final expectedCredential = MockUserCredential();
        when(mockFirebaseAuth.signInAnonymously())
            .thenAnswer((_) => Future.value(expectedCredential));

        // Act
        final result = await authDataService.signInAnonymously();

        // Assert
        expect(result, equals(expectedCredential));
        verify(mockFirebaseAuth.signInAnonymously()).called(1);
      });

      test('should throw AuthDataServiceException when sign in fails',
          () async {
        // Arrange
        when(mockFirebaseAuth.signInAnonymously())
            .thenThrow(AuthDataServiceException());

        // Act
        try {
          await authDataService.signInAnonymously();
        } catch (e) {
          expect(e, isA<AuthDataServiceException>());
        }

        verify(mockFirebaseAuth.signInAnonymously()).called(1);
      });
    });

    // Write similar test cases for other functions in AuthDataService
  });
}
