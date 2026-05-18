import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const none = <BoxShadow>[];

  static const subtle = [
    BoxShadow(color: Color(0x0A2D2926), blurRadius: 20, offset: Offset(0, 4)),
  ];

  static const ambient = [
    BoxShadow(color: Color(0x142D2926), blurRadius: 30, offset: Offset(0, 8)),
  ];

  static const elevated = [
    BoxShadow(color: Color(0x142D2926), blurRadius: 40, offset: Offset(0, 12)),
  ];
}
