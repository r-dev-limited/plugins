import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:talker/talker.dart';

final appTalkerProvider = Provider<Talker>((ref) {
  return Talker();
});
