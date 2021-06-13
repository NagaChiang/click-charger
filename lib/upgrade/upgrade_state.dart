import 'package:json_annotation/json_annotation.dart';

part 'upgrade_state.g.dart';

@JsonSerializable()
class UpgradeState {
  UpgradeState({this.level = 0});

  int level = 0;

  factory UpgradeState.fromJson(Map<String, dynamic> json) =>
      _$UpgradeStateFromJson(json);

  Map<String, dynamic> toJson() => _$UpgradeStateToJson(this);
}
