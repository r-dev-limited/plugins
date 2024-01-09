import '../../domain/user_vo.dart';
import 'package:flutter/material.dart';
import 'package:rdev_helpers/extensions.dart';
import 'package:rdev_helpers/styles.dart';
import 'user_avatar.dart';

class UserAvatarCard extends StatelessWidget {
  final UserVO userVO;
  final Color? textColor;

  const UserAvatarCard({
    super.key,
    required this.userVO,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(
          context: context,
          userName: userVO.name ?? 'User',
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: Insets.small),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userVO.name?.isNotEmpty == true
                        ? userVO.name!
                        : '<no name>',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: textColor,
                    ),
                  ),
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
