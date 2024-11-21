class TextInputDebouncer {
  TextInputDebouncer._();

  static String _keywordStop = "";

  static Future<void> onChange({
    required String keyword,
    Duration duration = const Duration(milliseconds: 300),
    required void Function() callBack,
  }) async {
    _keywordStop = keyword;
    await Future<void>.delayed(duration);
    if (_keywordStop == keyword) if (keyword.isNotEmpty) callBack();
  }
}
