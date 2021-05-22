import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'utils/utils.dart';
import 'utils/enums.dart';

class SettingsDialog extends StatefulWidget {
  SettingsDialog({this.language, this.onChanged, this.version});

  final Language language;
  final Function(int) onChanged;
  final String version;

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
    final bool isPlayGamesLinked =
        !FirebaseAuth.instance.currentUser.isAnonymous;

    return SimpleDialog(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 12.0,
      ),
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
        ),
        ListTile(
          title: Text('googlePlayGamesSetting.title'.tr()),
          trailing: Text(
            isPlayGamesLinked
                ? 'googlePlayGamesSetting.linked'.tr()
                : 'googlePlayGamesSetting.unlinked'.tr(),
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: isPlayGamesLinked ? Colors.green : Colors.red,
                ),
          ),
          onTap: isPlayGamesLinked
              ? null
              : () {
                  Utils.showLoadingOverlay(
                    context,
                    showProgressIndicator: false,
                  );

                  Utils.linkWithGooglePlayGames().then((_) {
                    Navigator.of(context).pop();
                    setState(() {});
                  });
                },
        ),
        if (widget.version != null)
          Center(
            child: Text(
              'v${widget.version}',
              style: Theme.of(context).textTheme.caption,
            ),
          ),
      ],
    );
  }
}
