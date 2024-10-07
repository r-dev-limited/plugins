import 'dart:math';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class Utils {
  static String generateRandomString(int len) {
    final r = Random();
    return String.fromCharCodes(
        List.generate(len, (index) => r.nextInt(33) + 89));
  }

  static void moveElementLeft(List input, dynamic element) {
    final currentIndex = input.indexOf(element);
    if (currentIndex - 1 >= 0) {
      input.removeAt(currentIndex);
      input.insert(currentIndex - 1, element);
    }
  }

  static void moveElementRight(List input, dynamic element) {
    final currentIndex = input.indexOf(element);
    if (currentIndex + 1 < input.length) {
      input.removeAt(currentIndex);
      input.insert(currentIndex + 1, element);
    }
  }

  static Map<String, String> splitQueryString(
    String query,
  ) {
    return query.split("&").fold({}, (map, element) {
      final index = element.indexOf("=");
      if (index == -1) {
        if (element != "") {
          map[element] = "";
        }
      } else if (index != 0) {
        final key = element.substring(0, index);
        final value = element.substring(index + 1);
        map[key] = value;
      }
      return map;
    });
  }

  static String generateLimitString(String term) {
    final strFrontCode = term.substring(0, term.length - 1);
    final strEndCode = term.characters.last;
    final limit =
        strFrontCode + String.fromCharCode(strEndCode.codeUnitAt(0) + 1);
    return limit;
  }

// Maybe some service?
  static void launchUrl(TargetPlatform platform, String url) async {
    final Uri uri = Uri.parse(url);
    if (await url_launcher.canLaunchUrl(uri)) {
      if (platform == TargetPlatform.android) {
        await url_launcher.launchUrl(uri);
      } else {
        await url_launcher.launchUrl(
          uri,
          mode: url_launcher.LaunchMode.externalApplication,
        );
      }
    } else {
      debugPrint("can't launch $url");
    }
  }

  static Map<String, String> generateOwnerPathFromArray(
      List<String> ownerPath) {
    final List<List<String>> pairs = [];
    // Users/userid/Entries/entryId (6 /2 = 3) 0,1,2
    // 0/1 2/3 4/5
    for (var i = 0; i < ownerPath.length / 2; i += 1) {
      final List<String> pair = [];
      pair.add(ownerPath[i * 2]);
      if ((i * 2) + 1 < ownerPath.length) {
        pair.add(ownerPath[i * 2 + 1]);
      }
      pairs.add(pair);
    }

    final Map<String, String> result = {};
    String prevKey = '';
    pairs.forEachIndexed((index, pair) {
      result[prevKey + pair[0]] = pair.length == 1 ? '' : pair[1];
      prevKey = '${pair[0]}>';
    });
    return result;
  }

  static bool isMobileNative() => !kIsWeb;
  //&& (Platform.isAndroid || Platform.isIOS);

  /// Returns a string representation of the duration in the format
  static String durationToMinutes(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds - (minutes * 60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonTitle,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(buttonTitle ?? "Ok"),
          ),
        ],
      ),
    );
  }

  static showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String? positiveButtonTitle,
    String? negativeButtonTitle,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(negativeButtonTitle ?? "No"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(positiveButtonTitle ?? "Yes"),
          ),
        ],
      ),
    );
  }
}
