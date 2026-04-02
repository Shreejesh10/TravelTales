import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class AppFlushbar {
  AppFlushbar._();

  static Future<void> success(BuildContext context, String message) {
    return _show(
      context,
      message: message,
      backgroundColor: const Color(0xFF16A34A),
      icon: Icons.check_circle_outline,
    );
  }

  static Future<void> info(BuildContext context, String message) {
    return _show(
      context,
      message: message,
      backgroundColor: const Color(0xFF29A2F3),
      icon: Icons.info_outline,
    );
  }

  static Future<void> error(
    BuildContext context,
    String message, {
    String? fallbackMessage,
  }) {
    return _show(
      context,
      message: _sanitizeMessage(message, fallbackMessage: fallbackMessage),
      backgroundColor: const Color(0xFFDC2626).withOpacity(0.9),
      icon: Icons.error_outline,
    );
  }

  static Future<void> errorFrom(
    BuildContext context,
    Object err, {
    required String fallbackMessage,
  }) {
    return error(
      context,
      error.toString(),
      fallbackMessage: fallbackMessage,
    );
  }

  static String _sanitizeMessage(
    String message, {
    String? fallbackMessage,
  }) {
    final trimmed = message
        .replaceFirst('Exception: ', '')
        .replaceFirst('Failed: ', '')
        .trim();

    final lower = trimmed.toLowerCase();
    final looksTechnical =
        lower.contains('traceback') ||
        lower.contains('http') ||
        lower.contains('sql') ||
        lower.contains('detail') ||
        lower.contains('{') ||
        lower.contains('[') ||
        lower.contains('typeerror') ||
        lower.contains('valueerror') ||
        lower.contains('socket') ||
        lower.contains('connection');

    if (trimmed.isEmpty || looksTechnical) {
      return fallbackMessage ?? 'Something went wrong. Please try again.';
    }

    return fallbackMessage ?? trimmed;
  }

  static Future<void> _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(14),
      backgroundColor: backgroundColor,
      icon: Icon(icon, color: Colors.white),
    ).show(context);
  }
}
