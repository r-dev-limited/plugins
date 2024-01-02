import 'package:flutter/material.dart';
import 'package:rdev_helpers/extensions.dart';

class UserAvatar extends CircleAvatar {
  final String? userName;
  final String? userImageUrl;
  final TextStyle? textStyle;

  UserAvatar({
    super.key,
    required BuildContext context,
    Color? backgroundColor,
    Color? foregroundColor,
    double? radius,
    this.textStyle,
    this.userImageUrl,
    this.userName,
  })  : assert(userName?.isNotEmpty == true || userImageUrl != null),
        super(
          radius: radius,
          backgroundColor:
              backgroundColor ?? Theme.of(context).colorScheme.primary,
          backgroundImage:
              userImageUrl == null ? null : NetworkImage(userImageUrl),
          child: userImageUrl == null
              ? Text(
                  userName!.toInitials(),
                  style: textStyle ??
                      Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: foregroundColor ?? Colors.white,
                            fontSize: radius != null ? radius * 0.75 : null,
                          ),
                )
              : null,
        );
}
