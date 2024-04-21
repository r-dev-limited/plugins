// Mocks generated by Mockito 5.4.4 from annotations
// in rdev_riverpod_firebase_auth/test/application/auth_data_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;

import 'package:cloud_functions/cloud_functions.dart' as _i6;
import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart'
    as _i5;
import 'package:firebase_auth/firebase_auth.dart' as _i4;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart'
    as _i3;
import 'package:firebase_core/firebase_core.dart' as _i2;
import 'package:google_sign_in/google_sign_in.dart' as _i9;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart'
    as _i10;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i8;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeFirebaseApp_0 extends _i1.SmartFake implements _i2.FirebaseApp {
  _FakeFirebaseApp_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeActionCodeInfo_1 extends _i1.SmartFake
    implements _i3.ActionCodeInfo {
  _FakeActionCodeInfo_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUserCredential_2 extends _i1.SmartFake
    implements _i4.UserCredential {
  _FakeUserCredential_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeConfirmationResult_3 extends _i1.SmartFake
    implements _i4.ConfirmationResult {
  _FakeConfirmationResult_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFirebaseFunctionsPlatform_4 extends _i1.SmartFake
    implements _i5.FirebaseFunctionsPlatform {
  _FakeFirebaseFunctionsPlatform_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeHttpsCallable_5 extends _i1.SmartFake implements _i6.HttpsCallable {
  _FakeHttpsCallable_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUserMetadata_6 extends _i1.SmartFake implements _i3.UserMetadata {
  _FakeUserMetadata_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeMultiFactor_7 extends _i1.SmartFake implements _i4.MultiFactor {
  _FakeMultiFactor_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeIdTokenResult_8 extends _i1.SmartFake implements _i3.IdTokenResult {
  _FakeIdTokenResult_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUser_9 extends _i1.SmartFake implements _i4.User {
  _FakeUser_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [FirebaseAuth].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseAuth extends _i1.Mock implements _i4.FirebaseAuth {
  MockFirebaseAuth() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.FirebaseApp get app => (super.noSuchMethod(
        Invocation.getter(#app),
        returnValue: _FakeFirebaseApp_0(
          this,
          Invocation.getter(#app),
        ),
      ) as _i2.FirebaseApp);

  @override
  set app(_i2.FirebaseApp? _app) => super.noSuchMethod(
        Invocation.setter(
          #app,
          _app,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set tenantId(String? tenantId) => super.noSuchMethod(
        Invocation.setter(
          #tenantId,
          tenantId,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set customAuthDomain(String? customAuthDomain) => super.noSuchMethod(
        Invocation.setter(
          #customAuthDomain,
          customAuthDomain,
        ),
        returnValueForMissingStub: null,
      );

  @override
  Map<dynamic, dynamic> get pluginConstants => (super.noSuchMethod(
        Invocation.getter(#pluginConstants),
        returnValue: <dynamic, dynamic>{},
      ) as Map<dynamic, dynamic>);

  @override
  _i7.Future<void> useEmulator(String? origin) => (super.noSuchMethod(
        Invocation.method(
          #useEmulator,
          [origin],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> useAuthEmulator(
    String? host,
    int? port, {
    bool? automaticHostMapping = true,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #useAuthEmulator,
          [
            host,
            port,
          ],
          {#automaticHostMapping: automaticHostMapping},
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> applyActionCode(String? code) => (super.noSuchMethod(
        Invocation.method(
          #applyActionCode,
          [code],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<_i3.ActionCodeInfo> checkActionCode(String? code) =>
      (super.noSuchMethod(
        Invocation.method(
          #checkActionCode,
          [code],
        ),
        returnValue: _i7.Future<_i3.ActionCodeInfo>.value(_FakeActionCodeInfo_1(
          this,
          Invocation.method(
            #checkActionCode,
            [code],
          ),
        )),
      ) as _i7.Future<_i3.ActionCodeInfo>);

  @override
  _i7.Future<void> confirmPasswordReset({
    required String? code,
    required String? newPassword,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #confirmPasswordReset,
          [],
          {
            #code: code,
            #newPassword: newPassword,
          },
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<_i4.UserCredential> createUserWithEmailAndPassword({
    required String? email,
    required String? password,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #createUserWithEmailAndPassword,
          [],
          {
            #email: email,
            #password: password,
          },
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #createUserWithEmailAndPassword,
            [],
            {
              #email: email,
              #password: password,
            },
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  _i7.Future<List<String>> fetchSignInMethodsForEmail(String? email) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchSignInMethodsForEmail,
          [email],
        ),
        returnValue: _i7.Future<List<String>>.value(<String>[]),
      ) as _i7.Future<List<String>>);

  @override
  _i7.Future<_i4.UserCredential> getRedirectResult() => (super.noSuchMethod(
        Invocation.method(
          #getRedirectResult,
          [],
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #getRedirectResult,
            [],
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  bool isSignInWithEmailLink(String? emailLink) => (super.noSuchMethod(
        Invocation.method(
          #isSignInWithEmailLink,
          [emailLink],
        ),
        returnValue: false,
      ) as bool);

  @override
  _i7.Stream<_i4.User?> authStateChanges() => (super.noSuchMethod(
        Invocation.method(
          #authStateChanges,
          [],
        ),
        returnValue: _i7.Stream<_i4.User?>.empty(),
      ) as _i7.Stream<_i4.User?>);

  @override
  _i7.Stream<_i4.User?> idTokenChanges() => (super.noSuchMethod(
        Invocation.method(
          #idTokenChanges,
          [],
        ),
        returnValue: _i7.Stream<_i4.User?>.empty(),
      ) as _i7.Stream<_i4.User?>);

  @override
  _i7.Stream<_i4.User?> userChanges() => (super.noSuchMethod(
        Invocation.method(
          #userChanges,
          [],
        ),
        returnValue: _i7.Stream<_i4.User?>.empty(),
      ) as _i7.Stream<_i4.User?>);

  @override
  _i7.Future<void> sendPasswordResetEmail({
    required String? email,
    _i3.ActionCodeSettings? actionCodeSettings,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #sendPasswordResetEmail,
          [],
          {
            #email: email,
            #actionCodeSettings: actionCodeSettings,
          },
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> sendSignInLinkToEmail({
    required String? email,
    required _i3.ActionCodeSettings? actionCodeSettings,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #sendSignInLinkToEmail,
          [],
          {
            #email: email,
            #actionCodeSettings: actionCodeSettings,
          },
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> setLanguageCode(String? languageCode) => (super.noSuchMethod(
        Invocation.method(
          #setLanguageCode,
          [languageCode],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> setSettings({
    bool? appVerificationDisabledForTesting = false,
    String? userAccessGroup,
    String? phoneNumber,
    String? smsCode,
    bool? forceRecaptchaFlow,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setSettings,
          [],
          {
            #appVerificationDisabledForTesting:
                appVerificationDisabledForTesting,
            #userAccessGroup: userAccessGroup,
            #phoneNumber: phoneNumber,
            #smsCode: smsCode,
            #forceRecaptchaFlow: forceRecaptchaFlow,
          },
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> setPersistence(_i3.Persistence? persistence) =>
      (super.noSuchMethod(
        Invocation.method(
          #setPersistence,
          [persistence],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<_i4.UserCredential> signInAnonymously() => (super.noSuchMethod(
        Invocation.method(
          #signInAnonymously,
          [],
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #signInAnonymously,
            [],
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  _i7.Future<_i4.UserCredential> signInWithCredential(
          _i3.AuthCredential? credential) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInWithCredential,
          [credential],
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #signInWithCredential,
            [credential],
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  _i7.Future<_i4.UserCredential> signInWithCustomToken(String? token) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInWithCustomToken,
          [token],
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #signInWithCustomToken,
            [token],
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  _i7.Future<_i4.UserCredential> signInWithEmailAndPassword({
    required String? email,
    required String? password,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInWithEmailAndPassword,
          [],
          {
            #email: email,
            #password: password,
          },
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #signInWithEmailAndPassword,
            [],
            {
              #email: email,
              #password: password,
            },
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  _i7.Future<_i4.UserCredential> signInWithEmailLink({
    required String? email,
    required String? emailLink,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInWithEmailLink,
          [],
          {
            #email: email,
            #emailLink: emailLink,
          },
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #signInWithEmailLink,
            [],
            {
              #email: email,
              #emailLink: emailLink,
            },
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  _i7.Future<_i4.UserCredential> signInWithAuthProvider(
          _i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInWithAuthProvider,
          [provider],
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #signInWithAuthProvider,
            [provider],
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  _i7.Future<_i4.UserCredential> signInWithProvider(
          _i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInWithProvider,
          [provider],
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #signInWithProvider,
            [provider],
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  _i7.Future<_i4.ConfirmationResult> signInWithPhoneNumber(
    String? phoneNumber, [
    _i4.RecaptchaVerifier? verifier,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInWithPhoneNumber,
          [
            phoneNumber,
            verifier,
          ],
        ),
        returnValue:
            _i7.Future<_i4.ConfirmationResult>.value(_FakeConfirmationResult_3(
          this,
          Invocation.method(
            #signInWithPhoneNumber,
            [
              phoneNumber,
              verifier,
            ],
          ),
        )),
      ) as _i7.Future<_i4.ConfirmationResult>);

  @override
  _i7.Future<_i4.UserCredential> signInWithPopup(_i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInWithPopup,
          [provider],
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #signInWithPopup,
            [provider],
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  _i7.Future<void> signInWithRedirect(_i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInWithRedirect,
          [provider],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> signOut() => (super.noSuchMethod(
        Invocation.method(
          #signOut,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<String> verifyPasswordResetCode(String? code) =>
      (super.noSuchMethod(
        Invocation.method(
          #verifyPasswordResetCode,
          [code],
        ),
        returnValue: _i7.Future<String>.value(_i8.dummyValue<String>(
          this,
          Invocation.method(
            #verifyPasswordResetCode,
            [code],
          ),
        )),
      ) as _i7.Future<String>);

  @override
  _i7.Future<void> verifyPhoneNumber({
    String? phoneNumber,
    _i3.PhoneMultiFactorInfo? multiFactorInfo,
    required _i3.PhoneVerificationCompleted? verificationCompleted,
    required _i3.PhoneVerificationFailed? verificationFailed,
    required _i3.PhoneCodeSent? codeSent,
    required _i3.PhoneCodeAutoRetrievalTimeout? codeAutoRetrievalTimeout,
    String? autoRetrievedSmsCodeForTesting,
    Duration? timeout = const Duration(seconds: 30),
    int? forceResendingToken,
    _i3.MultiFactorSession? multiFactorSession,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #verifyPhoneNumber,
          [],
          {
            #phoneNumber: phoneNumber,
            #multiFactorInfo: multiFactorInfo,
            #verificationCompleted: verificationCompleted,
            #verificationFailed: verificationFailed,
            #codeSent: codeSent,
            #codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
            #autoRetrievedSmsCodeForTesting: autoRetrievedSmsCodeForTesting,
            #timeout: timeout,
            #forceResendingToken: forceResendingToken,
            #multiFactorSession: multiFactorSession,
          },
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> revokeTokenWithAuthorizationCode(
          String? authorizationCode) =>
      (super.noSuchMethod(
        Invocation.method(
          #revokeTokenWithAuthorizationCode,
          [authorizationCode],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);
}

/// A class which mocks [FirebaseFunctions].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseFunctions extends _i1.Mock implements _i6.FirebaseFunctions {
  MockFirebaseFunctions() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.FirebaseApp get app => (super.noSuchMethod(
        Invocation.getter(#app),
        returnValue: _FakeFirebaseApp_0(
          this,
          Invocation.getter(#app),
        ),
      ) as _i2.FirebaseApp);

  @override
  _i5.FirebaseFunctionsPlatform get delegate => (super.noSuchMethod(
        Invocation.getter(#delegate),
        returnValue: _FakeFirebaseFunctionsPlatform_4(
          this,
          Invocation.getter(#delegate),
        ),
      ) as _i5.FirebaseFunctionsPlatform);

  @override
  Map<dynamic, dynamic> get pluginConstants => (super.noSuchMethod(
        Invocation.getter(#pluginConstants),
        returnValue: <dynamic, dynamic>{},
      ) as Map<dynamic, dynamic>);

  @override
  _i6.HttpsCallable httpsCallable(
    String? name, {
    _i5.HttpsCallableOptions? options,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #httpsCallable,
          [name],
          {#options: options},
        ),
        returnValue: _FakeHttpsCallable_5(
          this,
          Invocation.method(
            #httpsCallable,
            [name],
            {#options: options},
          ),
        ),
      ) as _i6.HttpsCallable);

  @override
  _i6.HttpsCallable httpsCallableFromUrl(
    String? url, {
    _i5.HttpsCallableOptions? options,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #httpsCallableFromUrl,
          [url],
          {#options: options},
        ),
        returnValue: _FakeHttpsCallable_5(
          this,
          Invocation.method(
            #httpsCallableFromUrl,
            [url],
            {#options: options},
          ),
        ),
      ) as _i6.HttpsCallable);

  @override
  _i6.HttpsCallable httpsCallableFromUri(
    Uri? uri, {
    _i5.HttpsCallableOptions? options,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #httpsCallableFromUri,
          [uri],
          {#options: options},
        ),
        returnValue: _FakeHttpsCallable_5(
          this,
          Invocation.method(
            #httpsCallableFromUri,
            [uri],
            {#options: options},
          ),
        ),
      ) as _i6.HttpsCallable);

  @override
  void useFunctionsEmulator(
    String? host,
    int? port, {
    bool? automaticHostMapping = true,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #useFunctionsEmulator,
          [
            host,
            port,
          ],
          {#automaticHostMapping: automaticHostMapping},
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [GoogleSignIn].
///
/// See the documentation for Mockito's code generation for more information.
class MockGoogleSignIn extends _i1.Mock implements _i9.GoogleSignIn {
  MockGoogleSignIn() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i10.SignInOption get signInOption => (super.noSuchMethod(
        Invocation.getter(#signInOption),
        returnValue: _i10.SignInOption.standard,
      ) as _i10.SignInOption);

  @override
  List<String> get scopes => (super.noSuchMethod(
        Invocation.getter(#scopes),
        returnValue: <String>[],
      ) as List<String>);

  @override
  bool get forceCodeForRefreshToken => (super.noSuchMethod(
        Invocation.getter(#forceCodeForRefreshToken),
        returnValue: false,
      ) as bool);

  @override
  _i7.Stream<_i9.GoogleSignInAccount?> get onCurrentUserChanged =>
      (super.noSuchMethod(
        Invocation.getter(#onCurrentUserChanged),
        returnValue: _i7.Stream<_i9.GoogleSignInAccount?>.empty(),
      ) as _i7.Stream<_i9.GoogleSignInAccount?>);

  @override
  _i7.Future<_i9.GoogleSignInAccount?> signInSilently({
    bool? suppressErrors = true,
    bool? reAuthenticate = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInSilently,
          [],
          {
            #suppressErrors: suppressErrors,
            #reAuthenticate: reAuthenticate,
          },
        ),
        returnValue: _i7.Future<_i9.GoogleSignInAccount?>.value(),
      ) as _i7.Future<_i9.GoogleSignInAccount?>);

  @override
  _i7.Future<bool> isSignedIn() => (super.noSuchMethod(
        Invocation.method(
          #isSignedIn,
          [],
        ),
        returnValue: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);

  @override
  _i7.Future<_i9.GoogleSignInAccount?> signIn() => (super.noSuchMethod(
        Invocation.method(
          #signIn,
          [],
        ),
        returnValue: _i7.Future<_i9.GoogleSignInAccount?>.value(),
      ) as _i7.Future<_i9.GoogleSignInAccount?>);

  @override
  _i7.Future<_i9.GoogleSignInAccount?> signOut() => (super.noSuchMethod(
        Invocation.method(
          #signOut,
          [],
        ),
        returnValue: _i7.Future<_i9.GoogleSignInAccount?>.value(),
      ) as _i7.Future<_i9.GoogleSignInAccount?>);

  @override
  _i7.Future<_i9.GoogleSignInAccount?> disconnect() => (super.noSuchMethod(
        Invocation.method(
          #disconnect,
          [],
        ),
        returnValue: _i7.Future<_i9.GoogleSignInAccount?>.value(),
      ) as _i7.Future<_i9.GoogleSignInAccount?>);

  @override
  _i7.Future<bool> requestScopes(List<String>? scopes) => (super.noSuchMethod(
        Invocation.method(
          #requestScopes,
          [scopes],
        ),
        returnValue: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);

  @override
  _i7.Future<bool> canAccessScopes(
    List<String>? scopes, {
    String? accessToken,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #canAccessScopes,
          [scopes],
          {#accessToken: accessToken},
        ),
        returnValue: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);
}

/// A class which mocks [User].
///
/// See the documentation for Mockito's code generation for more information.
class MockUser extends _i1.Mock implements _i4.User {
  MockUser() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get emailVerified => (super.noSuchMethod(
        Invocation.getter(#emailVerified),
        returnValue: false,
      ) as bool);

  @override
  bool get isAnonymous => (super.noSuchMethod(
        Invocation.getter(#isAnonymous),
        returnValue: false,
      ) as bool);

  @override
  _i3.UserMetadata get metadata => (super.noSuchMethod(
        Invocation.getter(#metadata),
        returnValue: _FakeUserMetadata_6(
          this,
          Invocation.getter(#metadata),
        ),
      ) as _i3.UserMetadata);

  @override
  List<_i3.UserInfo> get providerData => (super.noSuchMethod(
        Invocation.getter(#providerData),
        returnValue: <_i3.UserInfo>[],
      ) as List<_i3.UserInfo>);

  @override
  String get uid => (super.noSuchMethod(
        Invocation.getter(#uid),
        returnValue: _i8.dummyValue<String>(
          this,
          Invocation.getter(#uid),
        ),
      ) as String);

  @override
  _i4.MultiFactor get multiFactor => (super.noSuchMethod(
        Invocation.getter(#multiFactor),
        returnValue: _FakeMultiFactor_7(
          this,
          Invocation.getter(#multiFactor),
        ),
      ) as _i4.MultiFactor);

  @override
  _i7.Future<void> delete() => (super.noSuchMethod(
        Invocation.method(
          #delete,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<String?> getIdToken([bool? forceRefresh = false]) =>
      (super.noSuchMethod(
        Invocation.method(
          #getIdToken,
          [forceRefresh],
        ),
        returnValue: _i7.Future<String?>.value(),
      ) as _i7.Future<String?>);

  @override
  _i7.Future<_i3.IdTokenResult> getIdTokenResult(
          [bool? forceRefresh = false]) =>
      (super.noSuchMethod(
        Invocation.method(
          #getIdTokenResult,
          [forceRefresh],
        ),
        returnValue: _i7.Future<_i3.IdTokenResult>.value(_FakeIdTokenResult_8(
          this,
          Invocation.method(
            #getIdTokenResult,
            [forceRefresh],
          ),
        )),
      ) as _i7.Future<_i3.IdTokenResult>);

  @override
  _i7.Future<_i4.UserCredential> linkWithCredential(
          _i3.AuthCredential? credential) =>
      (super.noSuchMethod(
        Invocation.method(
          #linkWithCredential,
          [credential],
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #linkWithCredential,
            [credential],
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  _i7.Future<_i4.UserCredential> linkWithProvider(_i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #linkWithProvider,
          [provider],
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #linkWithProvider,
            [provider],
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  _i7.Future<_i4.UserCredential> reauthenticateWithProvider(
          _i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #reauthenticateWithProvider,
          [provider],
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #reauthenticateWithProvider,
            [provider],
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  _i7.Future<_i4.UserCredential> reauthenticateWithPopup(
          _i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #reauthenticateWithPopup,
          [provider],
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #reauthenticateWithPopup,
            [provider],
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  _i7.Future<void> reauthenticateWithRedirect(_i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #reauthenticateWithRedirect,
          [provider],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<_i4.UserCredential> linkWithPopup(_i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #linkWithPopup,
          [provider],
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #linkWithPopup,
            [provider],
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  _i7.Future<void> linkWithRedirect(_i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #linkWithRedirect,
          [provider],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<_i4.ConfirmationResult> linkWithPhoneNumber(
    String? phoneNumber, [
    _i4.RecaptchaVerifier? verifier,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #linkWithPhoneNumber,
          [
            phoneNumber,
            verifier,
          ],
        ),
        returnValue:
            _i7.Future<_i4.ConfirmationResult>.value(_FakeConfirmationResult_3(
          this,
          Invocation.method(
            #linkWithPhoneNumber,
            [
              phoneNumber,
              verifier,
            ],
          ),
        )),
      ) as _i7.Future<_i4.ConfirmationResult>);

  @override
  _i7.Future<_i4.UserCredential> reauthenticateWithCredential(
          _i3.AuthCredential? credential) =>
      (super.noSuchMethod(
        Invocation.method(
          #reauthenticateWithCredential,
          [credential],
        ),
        returnValue: _i7.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #reauthenticateWithCredential,
            [credential],
          ),
        )),
      ) as _i7.Future<_i4.UserCredential>);

  @override
  _i7.Future<void> reload() => (super.noSuchMethod(
        Invocation.method(
          #reload,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> sendEmailVerification(
          [_i3.ActionCodeSettings? actionCodeSettings]) =>
      (super.noSuchMethod(
        Invocation.method(
          #sendEmailVerification,
          [actionCodeSettings],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<_i4.User> unlink(String? providerId) => (super.noSuchMethod(
        Invocation.method(
          #unlink,
          [providerId],
        ),
        returnValue: _i7.Future<_i4.User>.value(_FakeUser_9(
          this,
          Invocation.method(
            #unlink,
            [providerId],
          ),
        )),
      ) as _i7.Future<_i4.User>);

  @override
  _i7.Future<void> updateEmail(String? newEmail) => (super.noSuchMethod(
        Invocation.method(
          #updateEmail,
          [newEmail],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> updatePassword(String? newPassword) => (super.noSuchMethod(
        Invocation.method(
          #updatePassword,
          [newPassword],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> updatePhoneNumber(
          _i3.PhoneAuthCredential? phoneCredential) =>
      (super.noSuchMethod(
        Invocation.method(
          #updatePhoneNumber,
          [phoneCredential],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> updateDisplayName(String? displayName) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateDisplayName,
          [displayName],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> updatePhotoURL(String? photoURL) => (super.noSuchMethod(
        Invocation.method(
          #updatePhotoURL,
          [photoURL],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateProfile,
          [],
          {
            #displayName: displayName,
            #photoURL: photoURL,
          },
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> verifyBeforeUpdateEmail(
    String? newEmail, [
    _i3.ActionCodeSettings? actionCodeSettings,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #verifyBeforeUpdateEmail,
          [
            newEmail,
            actionCodeSettings,
          ],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);
}

/// A class which mocks [UserCredential].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserCredential extends _i1.Mock implements _i4.UserCredential {
  MockUserCredential() {
    _i1.throwOnMissingStub(this);
  }
}
