import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:rdev_riverpod_firebase_auth/data/auth_repository.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';

import '../application/user_messaging_service.dart';
import '../domain/user_messaging_model.dart';

final fbMessagingTokenRefreshProvider = StreamProvider<String>((ref) {
  final messagingInstance = ref.watch(fbMessagingProvider);

  return messagingInstance.onTokenRefresh;
});

final currentFbMessagingTokenProvider = StateProvider<String?>((ref) {
  final messagingInstance =
      ref.watch(fbMessagingTokenRefreshProvider.select((value) => value));

  return messagingInstance.value;
});

@immutable
class UserMessagingRepositoryState extends Equatable {
  final String? currentToken;
  final Map<String, FCMToken>? attachedFCMTokens;
  final NotificationSettings? notificationSettings;

  const UserMessagingRepositoryState({
    this.currentToken,
    this.notificationSettings,
    this.attachedFCMTokens,
  });

  /// Creates a new instance of the state with updated values.
  UserMessagingRepositoryState copyWith({
    String? currentToken,
    NotificationSettings? notificationSettings,
    Map<String, FCMToken>? attachedFCMTokens,
  }) {
    return UserMessagingRepositoryState(
      currentToken: currentToken ?? this.currentToken,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      attachedFCMTokens: attachedFCMTokens ?? this.attachedFCMTokens,
    );
  }

  @override
  List<Object?> get props => [
        currentToken,
        notificationSettings,
        attachedFCMTokens,
      ];
}

class UserMessagingRepository
    extends AsyncNotifier<UserMessagingRepositoryState> {
  final log = Logger('UserMessagingRepository');
  late UserMessagingService _userMessagingService;

  String? _currentUserId;
  @override
  FutureOr<UserMessagingRepositoryState> build() async {
    _userMessagingService = ref.watch(UserMessagingService.provider);
    _currentUserId = await ref.watch(
        AuthRepository.provider.selectAsync((data) => data.authUser?.uid));

    ///
    Map<String, FCMToken>? fcmTokens;
    if (_currentUserId is String) {
      final messagingModel =
          await _userMessagingService.getMessaging(_currentUserId!);
      fcmTokens = messagingModel.fcmTokens;
    }

    ref.listen(currentFbMessagingTokenProvider, (previous, next) async {
      if (_currentUserId is String && next is String) {
        await updateUserFCMToken(next);
      }
    });

    try {
      final settings = await ref.read(fbMessagingProvider).requestPermission(
          alert: true,
          badge: true,
          provisional: true,
          sound: true,
          announcement: true);

      debugPrint('User granted permission: ${settings.authorizationStatus}');
      const vapidKey = const String.fromEnvironment('VAPID_KEY');
      final currentToken =
          await ref.read(fbMessagingProvider).getToken(vapidKey: vapidKey);

      if (currentToken is String && _currentUserId is String) {
        ref.read(currentFbMessagingTokenProvider.notifier).state = currentToken;
      }

      return UserMessagingRepositoryState(
        attachedFCMTokens: fcmTokens,
        currentToken: currentToken,
        notificationSettings: settings,
      );
    } catch (err) {
      /// This might fail, and we should leave it to the user to fix it.
      debugPrint(err.toString());
      UserMessagingRepositoryState(
        attachedFCMTokens: fcmTokens,
        currentToken: null,
        notificationSettings: null,
      );
    }
    return UserMessagingRepositoryState();
  }

  Future<void> updateUserFCMToken(String token) async {
    if (_currentUserId is String) {
      try {
        /// Check for same token
        final tokens = state.value?.attachedFCMTokens?.values
                .map((e) => e.token)
                .toList() ??
            [];
        if (tokens.contains(token)) {
          return;
        }

        final fcmToken = FCMToken(
          token: token,

          /// Add platform check
          type: FCMTokenType.Ios,
          createdAt: DateTime.now().millisecondsSinceEpoch.toDouble(),
        );
        await this
            ._userMessagingService
            .updateUserFCMToken(_currentUserId!, fcmToken);
      } catch (err) {
        /// Restore data
        throw err;
      }
    } else {
      log.warning('updateUserFCMToken() - _currentUserId is not a String');
    }
  }

  Future<void> removeUserFCMToken(String token) async {
    if (_currentUserId is String) {
      try {
        await this
            ._userMessagingService
            .removeUserFCMToken(_currentUserId!, token);
      } catch (err) {
        /// Restore data
        throw err;
      }
    } else {
      log.warning('removeUserFCMToken() - _currentUserId is not a String');
    }
  }

  Future<void> logout() async {
    final lastToken = ref.read(currentFbMessagingTokenProvider);
    if (lastToken is String) {
      try {
        await removeUserFCMToken(lastToken);
      } catch (err) {
        log.warning(err);
      }
    }
  }

  static AsyncNotifierProvider<UserMessagingRepository,
          UserMessagingRepositoryState> provider =
      AsyncNotifierProvider<UserMessagingRepository,
          UserMessagingRepositoryState>(() {
    return UserMessagingRepository();
  });
}
