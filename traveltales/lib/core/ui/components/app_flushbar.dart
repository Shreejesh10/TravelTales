import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

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
      err.toString(),
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

    final extracted = _extractReadableMessage(trimmed);
    if (extracted != null && extracted.isNotEmpty) {
      return extracted;
    }

    final lower = trimmed.toLowerCase();
    final looksTechnical =
        lower.contains('traceback') ||
        lower.contains('http') ||
        lower.contains('sql') ||
        lower.contains('typeerror') ||
        lower.contains('valueerror') ||
        lower.contains('socket') ||
        lower.contains('connection');

    if (trimmed.isEmpty || looksTechnical) {
      return fallbackMessage ?? 'Something went wrong. Please try again.';
    }

    return trimmed;
  }

  static String? _extractReadableMessage(String message) {
    final jsonStart = message.indexOf('{');
    if (jsonStart >= 0) {
      final prefix = message.substring(0, jsonStart).trim();
      final jsonPart = message.substring(jsonStart).trim();
      try {
        final decoded = jsonDecode(jsonPart);
        if (decoded is Map<String, dynamic>) {
          final detail = decoded['detail']?.toString().trim();
          if (detail != null && detail.isNotEmpty) {
            return detail;
          }

          final messageValue = decoded['message']?.toString().trim();
          if (messageValue != null && messageValue.isNotEmpty) {
            return messageValue;
          }
        }
      } catch (_) {
        if (prefix.isNotEmpty) {
          return prefix;
        }
      }
    }

    return null;
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
