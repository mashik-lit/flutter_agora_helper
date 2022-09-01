import 'package:flutter/material.dart';

import 'colors.dart' as colors;

class TextStyles {
  static const TextStyle body2 = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
  );
}

extension TextStyleExt on TextStyle {
  TextStyle red() => copyWith(color: colors.red);
}
