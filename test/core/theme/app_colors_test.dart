import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/core/theme/app_colors.dart';

void main() {
  test('AppColors has expected background value', () {
    expect(AppColors.background, const Color(0xFF111125));
  });

  test('AppColors has expected primary value', () {
    expect(AppColors.primary, const Color(0xFFBFC4ED));
  });
}
