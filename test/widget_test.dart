import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subly/core/theme/app_colors.dart';

void main() {
  test('App colors match design spec', () {
    expect(AppColors.primaryPurple, const Color(0xFF7B61FF));
    expect(AppColors.activeGreen, const Color(0xFF34C759));
    expect(AppColors.background, const Color(0xFFFAFAFA));
  });
}
