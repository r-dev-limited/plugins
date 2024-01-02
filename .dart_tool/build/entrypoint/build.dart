// ignore_for_file: directives_ordering
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:build_runner_core/build_runner_core.dart' as _i1;
import 'package:build_resolvers/builder.dart' as _i2;
import 'dart:isolate' as _i3;
import 'package:build_runner/build_runner.dart' as _i4;
import 'dart:io' as _i5;

final _builders = <_i1.BuilderApplication>[
  _i1.apply(
    r'build_resolvers:transitive_digests',
    [_i2.transitiveDigestsBuilder],
    _i1.toAllPackages(),
    isOptional: true,
    hideOutput: true,
    appliesBuilders: const [r'build_resolvers:transitive_digest_cleanup'],
  ),
  _i1.applyPostProcess(
    r'build_resolvers:transitive_digest_cleanup',
    _i2.transitiveDigestCleanup,
  ),
];
void main(
  List<String> args, [
  _i3.SendPort? sendPort,
]) async {
  var result = await _i4.run(
    args,
    _builders,
  );
  sendPort?.send(result);
  _i5.exitCode = result;
}
