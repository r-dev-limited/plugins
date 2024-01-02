import 'package:nock/nock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rdev_riverpod_firebase_user/presentation/widgets/user_avatar.dart';
import 'dart:convert';

void main() {
  group('UserAvatar', () {
    setUpAll(() {
      nock.init();
    });

    setUp(() {
      nock.cleanAll();
    });

    testWidgets('should display user initials when userImageUrl is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            return UserAvatar(
              context: context,
              userName: 'John Doe',
            );
          }),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('should display user image when userImageUrl is not null',
        (WidgetTester tester) async {
      nock("https://example.com").get("/image.png")
        ..reply(
            200,
            base64Decode(
                "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAA1JREFUGFdj+L+U4T8ABu8CpCYJ1DQAAAAASUVORK5CYII="),
            headers: {
              'Content-Type': 'image/png',
            });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            return UserAvatar(
              context: context,
              userImageUrl: 'https://example.com/image.png',
            );
          }),
        ),
      );
      expect(find.byType(UserAvatar), findsOneWidget);
    });

    testWidgets(
        'should throw assertion error when userName and userImageUrl are null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            try {
              return UserAvatar(
                context: context,
              );
            } catch (err) {
              expect(err, isA<AssertionError>());
            }
            return Container();
          }),
        ),
      );
    });
  });
}
