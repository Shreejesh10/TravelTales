import 'package:intl/intl.dart';
import 'package:traveltales/api/api.dart';
import 'package:http_parser/http_parser.dart';

class AppFormatters {
  AppFormatters._();

  static String formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("MMMM d, yyyy").format(date);
  }

  static String formatFullDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("EEEE, MMMM d, yyyy").format(date);
  }

  static String formatTime(String? time) {
    if (time == null || time.isEmpty) return "-";

    try {
      final parsedTime = DateFormat("HH:mm:ss.SSSSSS").parse(time);
      return DateFormat("hh:mm a").format(parsedTime);
    } catch (e) {
      try {
        final parsedTime = DateFormat("HH:mm:ss").parse(time);
        return DateFormat("hh:mm a").format(parsedTime);
      } catch (e) {
        return time;
      }
    }
  }

  static String formatPrice(num? price) {
    if (price == null) return "Rs 0";
    return "Rs ${price.toStringAsFixed(0)}";
  }

  static String formatDuration(DateTime? from, DateTime? to) {
    if (from == null || to == null) return "-";
    final days = to.difference(from).inDays + 1;
    if (days <= 0) return "1 Day";
    return "$days ${days == 1 ? 'Day' : 'Days'}";
  }

  static String addedText(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt).inDays;

    if (difference <= 0) return "Added today";
    if (difference == 1) return "Added 1 day ago";
    return "Added $difference days ago";
  }
  static String buildProfileImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";

    if (path.startsWith("http://") || path.startsWith("https://")) {
      return path;
    }

    return "$API_URL$path";
  }

}
MediaType getMediaType(String filename) {
  final lower = filename.toLowerCase();

  if (lower.endsWith('.png')) {
    return MediaType('image', 'png');
  } else if (lower.endsWith('.webp')) {
    return MediaType('image', 'webp');
  } else if (lower.endsWith('.heic')) {
    return MediaType('image', 'heic');
  } else if (lower.endsWith('.heif')) {
    return MediaType('image', 'heif');
  } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
    return MediaType('image', 'jpeg');
  }

  return MediaType('application', 'octet-stream');
}

