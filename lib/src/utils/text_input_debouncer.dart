class TextInputDebouncer {
  TextInputDebouncer._();

  static String _keywordsStop = '';

  static Future<void> onChange({
    required String keywords,
    Duration duration = const Duration(milliseconds: 300),
    required void Function() callBack,
    void Function()? onEmptyKeywords,
    void Function()? onMiss,
  }) async {
    _keywordsStop = keywords;
    await Future<void>.delayed(duration);
    if (_keywordsStop == keywords) {
      if (keywords.isNotEmpty) {
        callBack();
      } else {
        onEmptyKeywords?.call();
      }
    } else {
      onMiss?.call();
    }
  }
}
