import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'utils/enums.dart';

class SettingsDialog extends StatefulWidget {
  SettingsDialog({this.language, this.onChanged});

  final Language language;
  final Function(int) onChanged;

  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  Language _language;

  @override
  void initState() {
    super.initState();
    _language = widget.language ?? Language.systemDefault;
    if (widget.language == null) {
      widget.onChanged?.call(_language.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Center(
        child: Text(
          'settings'.tr(),
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      children: [
        ListTile(
          title: Text('language'.tr()),
          trailing: DropdownButton<int>(
            value: _language.index,
            items: [
              for (Language lang in Language.values)
                DropdownMenuItem<int>(
                  child: Text(
                    lang == Language.systemDefault
                        ? languageNameMap[lang].tr()
                        : languageNameMap[lang],
                  ),
                  value: lang.index,
                ),
            ],
            onChanged: (value) {
              setState(() {
                _language = Language.values[value];
              });

              widget.onChanged?.call(value);
            },
          ),
        )
      ],
    );
  }
}