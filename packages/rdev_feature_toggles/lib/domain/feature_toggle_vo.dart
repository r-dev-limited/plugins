import 'package:equatable/equatable.dart';

class FeatureToggleVO extends Equatable {
  final String uid;
  final Map<String, String>? parent;
  final List<FeatureToggleEntryVO>? toggles;

  const FeatureToggleVO({this.toggles, required this.uid, this.parent});

  @override
  List<Object?> get props => [toggles, uid, parent];

  FeatureToggleVO copyWith({
    String? uid,
    Map<String, String>? parent,
    List<FeatureToggleEntryVO>? toggles,
  }) {
    return FeatureToggleVO(
      uid: uid ?? this.uid,
      toggles: toggles ?? this.toggles,
      parent: parent ?? this.parent,
    );
  }

  factory FeatureToggleVO.fromMap(Map<String, dynamic> map) {
    return FeatureToggleVO(
      uid: map['uid'],
      parent: map['parent'],
      toggles: List<FeatureToggleEntryVO>.from(
        map['toggles'].map(
          (e) => FeatureToggleEntryVO.fromMap(e),
        ),
      ),
    );
  }

  toJSON() {
    return {
      'uid': uid,
      'parent': parent,
      'toggles': toggles?.map((e) => e.toJson()).toList(),
    };
  }
}

class FeatureToggleEntryVO extends Equatable {
  final bool value;
  final String name;

  const FeatureToggleEntryVO({
    required this.value,
    required this.name,
  });

  @override
  List<Object?> get props => [value, name];

  factory FeatureToggleEntryVO.fromMap(Map<String, dynamic> map) {
    return FeatureToggleEntryVO(
      value: map['value'],
      name: map['name'],
    );
  }

  toJson() {
    return {
      'value': value,
      'name': name,
    };
  }
}
