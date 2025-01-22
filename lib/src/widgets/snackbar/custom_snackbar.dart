import 'package:flutter/material.dart';
import 'package:kidsplay/src/core/screen_utils.dart';

class CustomSnackbar {
  static OverlayEntry? _overlayEntry;
  static bool _isSnackBarVisible = false;
  static String? _currentMessage;

  static void showSnackBar(BuildContext context, String message,
      {Color color = Colors.blueAccent}) {
    // If the same message is already being shown, return
    if (_isSnackBarVisible && _currentMessage == message) return;

    // Close the existing Snackbar if a new message is shown
    _hideCurrentSnackBar();

    _isSnackBarVisible = true;
    _currentMessage = message;

    // Create an overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: ScreenUtils.isPortrait
            ? ScreenUtils.statusBarHeight * 3
            : ScreenUtils.statusBarHeight * 1.5,
        left: 20.0,
        right: 20.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    // Insert the overlay entry into the overlay
    Overlay.of(context).insert(_overlayEntry!);

    // Automatically hide the Snackbar after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      _hideCurrentSnackBar();
    });
  }

  static void _hideCurrentSnackBar() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isSnackBarVisible = false;
      _currentMessage = null;
    }
  }
}
