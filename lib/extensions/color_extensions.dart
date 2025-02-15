import 'package:flutter/widgets.dart';

extension XColor on Color {
  String get hexString {
    return '#${value.toRadixString(16).substring(2)}';
  }
}
