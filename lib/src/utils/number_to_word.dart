import 'dart:math';

class NumberToWord {
  NumberToWord._();

  static String _langEN(double number) {
    if (number == 0) return 'zero';

    String words = '';

    for (int i = _powersOfTenEN.length - 1; i >= 0; i--) {
      num divisor = pow(10, 3 * i);
      int quotient = number ~/ divisor;
      number %= divisor as int;
      if (quotient > 0) {
        int hundreds = quotient ~/ 100;
        int remainder = quotient % 100;
        if (hundreds > 0) words += '${_onesEN[hundreds]} hundred ';
        if (remainder > 0) {
          if (remainder < 20) {
            words += '${_onesEN[remainder]} ';
          } else {
            int tensDigit = remainder ~/ 10;
            int onesDigit = remainder % 10;
            words += '${_tensEN[tensDigit]} ';
            if (onesDigit > 0) words += '${_onesEN[onesDigit]} ';
          }
        }
        words += '${_powersOfTenEN[i]} ';
      }
    }

    return words.trim();
  }

  static String _langID(double number) {
    if (number == 0) return 'nol';

    String words = '';

    for (int i = _powersOfTenID.length - 1; i >= 0; i--) {
      num divisor = pow(10, 3 * i);
      int quotient = number ~/ divisor;
      number %= divisor as int;
      if (quotient > 0) {
        int hundreds = quotient ~/ 100;
        int remainder = quotient % 100;
        if (hundreds > 0) {
          words += _onesID[hundreds] == 'satu' ? 'seratus ' : '${_onesID[hundreds]} ratus ';
        }
        if (remainder > 0) {
          if (remainder < 20) {
            words += '${_onesID[remainder]} ';
          } else {
            int tensDigit = remainder ~/ 10;
            int onesDigit = remainder % 10;
            words += '${_tensID[tensDigit]} ';
            if (onesDigit > 0) words += '${_onesID[onesDigit]} ';
          }
        }
        if (words == 'satu ') {
          if (_powersOfTenID[i] == 'ribu') {
            words = 'seribu ';
          } else {
            words += '${_powersOfTenID[i]} ';
          }
        } else {
          words += '${_powersOfTenID[i]} ';
        }
      }
    }

    return words.trim();
  }

  static String convert({required double number, required String lang}) {
    String sentence;

    if (lang == 'id') {
      sentence = _langID(number);
    } else {
      sentence = _langEN(number);
    }
    List<String> words = sentence.split(' ');
    for (int i = 0; i < words.length; i++) {
      String firstLetter = words[i].substring(0, 1);
      String restOfWord = words[i].substring(1);
      words[i] = '${firstLetter.toUpperCase()}${restOfWord.toLowerCase()}';
    }
    return words.join(' ');
  }

  static const _onesEN = [
    '',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
    'eleven',
    'twelve',
    'thirteen',
    'fourteen',
    'fifteen',
    'sixteen',
    'seventeen',
    'eighteen',
    'nineteen',
  ];

  static const _onesID = [
    '',
    'satu',
    'dua',
    'tiga',
    'empat',
    'lima',
    'enam',
    'tujuh',
    'delapan',
    'sembilan',
    'sepuluh',
    'sebelas',
    'dua belas',
    'tiga belas',
    'empat belas',
    'lima belas',
    'enam belas',
    'tujuh belas',
    'delapan belas',
    'sembilan belas',
  ];

  static const _tensEN = ['', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'];

  static const _tensID = [
    '',
    '',
    'dua puluh',
    'tiga puluh',
    'empat puluh',
    'lima puluh',
    'enam puluh',
    'tujuh puluh',
    'delapan puluh',
    'sembilan puluh',
  ];

  static const _powersOfTenEN = ['', 'thousand', 'million', 'billion', 'trillion'];

  static const _powersOfTenID = ['', 'ribu', 'juta', 'miliar', 'triliun'];
}
