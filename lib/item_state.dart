import 'package:json_annotation/json_annotation.dart';

part 'item_state.g.dart';

@JsonSerializable()
class ItemState {
  ItemState({this.amount = 0});

  int amount = 0;

  factory ItemState.fromJson(Map<String, dynamic> json) =>
      _$ItemStateFromJson(json);

  Map<String, dynamic> toJson() => _$ItemStateToJson(this);
}
