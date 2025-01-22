import 'package:flutter/material.dart';
import 'package:kidsplay/src/core/global.dart';

class ScreenUtils {
  static BuildContext get _context => Global.navKey.currentContext!;

  static double x(double value) => value * 4;

  static double get statusBarHeight => MediaQuery.of(_context).padding.top;

  static double get width => MediaQuery.of(_context).size.width;
  static double get height => MediaQuery.of(_context).size.height;

  static Size get size => MediaQuery.of(_context).size;

  static bool get isPortrait =>
      MediaQuery.of(_context).orientation == Orientation.portrait;

  static double get appBarHeight => AppBar().preferredSize.height;

  static EdgeInsets get screenPadding => MediaQuery.of(_context).padding;
  static EdgeInsets get viewPadding => MediaQuery.of(_context).viewPadding;
}
