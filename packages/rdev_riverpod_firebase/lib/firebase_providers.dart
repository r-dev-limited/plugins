import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Primitive Providers
final fbAppProvider = Provider<FirebaseApp>((ref) => Firebase.app());

final fbAppRegionProvider = Provider<String>((ref) => 'us-central1');

final fbAuthProvider = Provider<FirebaseAuth>(
    (ref) => FirebaseAuth.instanceFor(app: ref.watch(fbAppProvider)));

final fbStorageProvider = Provider<FirebaseStorage>(
    (ref) => FirebaseStorage.instanceFor(app: ref.watch(fbAppProvider)));

final fbFirestoreProvider = Provider<FirebaseFirestore>(
    (ref) => FirebaseFirestore.instanceFor(app: ref.watch(fbAppProvider)));

final fbFunctionsProvider =
    Provider<FirebaseFunctions>((ref) => FirebaseFunctions.instanceFor(
          app: ref.watch(fbAppProvider),
          region: ref.watch(fbAppRegionProvider),
        ));

final fbAnalyticsProvider = Provider<FirebaseAnalytics>(
    (ref) => FirebaseAnalytics.instanceFor(app: ref.watch(fbAppProvider)));

// final fbDynamicLinksProvider = Provider<FirebaseDynamicLinks>(
//     (ref) => FirebaseDynamicLinks.instanceFor(app: ref.watch(fbAppProvider)));

final fbMessagingProvider =
    Provider<FirebaseMessaging>((ref) => FirebaseMessaging.instance);
