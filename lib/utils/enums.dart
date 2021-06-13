import 'dart:ui';

import 'constants.dart';

enum Language {
  systemDefault,
  english,
  traditionalChinese,
  simplifiedChinese,
  japanese,
}

const Map<Language, String> languageNameMap = {
  Language.systemDefault: 'systemDefaultLanguage',
  Language.english: 'English',
  Language.traditionalChinese: '繁體中文',
  Language.simplifiedChinese: '简体中文',
  Language.japanese: '日本語',
};

const Map<Language, Locale> languageLocaleMap = {
  Language.english: const Locale('en'),
  Language.traditionalChinese: Constants.traditionalChineseLocale,
  Language.simplifiedChinese: Constants.simplifiedChineseLocale,
  Language.japanese: const Locale('ja'),
};
