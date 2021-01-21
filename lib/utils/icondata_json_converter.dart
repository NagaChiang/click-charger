import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

class IconDataJsonConverter implements JsonConverter<IconData, String> {
  static const Map<String, IconData> _stringToIconData = {
    'pan_tool': Icons.pan_tool,
    'pest_control_rodent': Icons.pest_control_rodent,
    'brightness_5': Icons.brightness_5,
  };

  const IconDataJsonConverter();

  @override
  IconData fromJson(String json) {
    if (_stringToIconData.containsKey(json)) {
      return _stringToIconData[json];
    }

    assert(false, '$json not found in map.');

    return null;
  }

  @override
  String toJson(IconData object) {
    for (MapEntry<String, IconData> entry in _stringToIconData.entries) {
      if (entry.value == object) {
        return entry.key;
      }
    }

    assert(false, '$object not found in map.');

    return '';
  }
}
