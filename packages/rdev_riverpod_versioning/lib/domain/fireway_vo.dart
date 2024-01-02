import 'package:equatable/equatable.dart';
import 'package:rdev_riverpod_versioning/domain/fireway_model.dart';

class FirewayVO extends Equatable {
  final String? uid;
  final String description;
  final String version;
  final bool success;
  final String script;
  final DateTime installedOn;
  final Duration executionTime;

  FirewayVO({
    this.uid,
    required this.description,
    required this.version,
    required this.success,
    required this.script,
    required this.installedOn,
    required this.executionTime,
  });

  @override
  List<Object?> get props => [
        description,
        version,
        success,
        script,
        installedOn,
        executionTime,
      ];

  factory FirewayVO.fromFirewayModel(FirewayModel model) {
    return FirewayVO(
      uid: model.uid!,
      description: model.description,
      version: model.version,
      success: model.success,
      script: model.script,
      installedOn: model.installedOn,
      executionTime: Duration(milliseconds: model.executionTime.toInt()),
    );
  }

  FirewayModel toFirewayModel() {
    final userModel = FirewayModel(
      uid: uid,
      description: description,
      version: version,
      success: success,
      script: script,
      installedOn: installedOn,
      executionTime: executionTime.inMilliseconds.toInt(),
    );

    return userModel;
  }
}
