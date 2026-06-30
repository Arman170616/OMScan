import 'package:flutter/material.dart';

class AppLanguage extends ChangeNotifier {
  bool _isArabic = true;
  bool get isArabic => _isArabic;
  TextDirection get direction =>
      _isArabic ? TextDirection.rtl : TextDirection.ltr;

  void toggleLanguage() {
    _isArabic = !_isArabic;
    notifyListeners();
  }
}
