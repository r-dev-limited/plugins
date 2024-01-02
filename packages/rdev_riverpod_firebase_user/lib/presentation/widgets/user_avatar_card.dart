import '../../domain/user_vo.dart';
import 'package:flutter/material.dart';
import 'package:rdev_helpers/extensions.dart';
import 'package:rdev_helpers/styles.dart';
import 'package:responsive_framework/responsive_framework.dart';
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
    return ResponsiveRowColumn(
      layout: ResponsiveRowColumnType.ROW,
      children: [
        ResponsiveRowColumnItem(
          child: UserAvatar(
            context: context,
            userName: userVO.name ?? 'User',
          ),
        ),
        ResponsiveRowColumnItem(
          rowFlex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: Insets.small),
            child: ResponsiveRowColumn(
                layout: ResponsiveRowColumnType.COLUMN,
                columnMainAxisAlignment: MainAxisAlignment.start,
                columnCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveRowColumnItem(
                    child: Text(
                      userVO.name?.isNotEmpty == true
                          ? userVO.name!
                          : '<no name>',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: textColor,
                      ),
                    ),
                  ),
                  ResponsiveRowColumnItem(
                    child: Text(
                      userVO.email ?? '',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                      ),
                    ),
                  ),
                ]),
          ),
        )
      ],
    );
  }
}
