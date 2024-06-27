import '../../domain/user_vo.dart';
import 'package:flutter/material.dart';
import 'package:rdev_helpers/extensions.dart';
import 'package:rdev_helpers/styles.dart';
import 'user_avatar.dart';

class UserAvatarCard extends StatelessWidget {
  final UserVO userVO;
  final bool isAnonymous;
  final Color? textColor;
  final String? anonymousTitle;
  final String? missingName;

  const UserAvatarCard({
    super.key,
    required this.userVO,
    required this.isAnonymous,
    this.textColor,
    this.anonymousTitle,
    this.missingName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!isAnonymous)
          UserAvatar(
            context: context,
            userName: userVO.name ?? '?',
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: Insets.small),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isAnonymous)
                    Text(
                      anonymousTitle ?? 'Guest Account',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: textColor,
                      ),
                    ),
                  if (!isAnonymous)
                    Text(
                      userVO.name?.isNotEmpty == true
                          ? userVO.name!
                          : missingName ?? '<Display Name>',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: textColor,
                      ),
                    ),
                  if (!isAnonymous)
                    Text(
                      userVO.email ?? '',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                      ),
                    ),
                ]),
          ),
        )
      ],
    );
  }
}
