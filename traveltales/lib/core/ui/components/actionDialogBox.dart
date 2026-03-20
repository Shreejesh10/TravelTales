import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppActionDialog extends StatelessWidget {
  final String title;
  final List<Widget> contentWidget;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const AppActionDialog({
    super.key,
    required this.title,
    required this.contentWidget,
    required this.onConfirm,
    this.confirmText = "Confirm",
    this.cancelText = "Cancel",
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: contentWidget,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            cancelText,
            style: TextStyle(
              fontWeight: FontWeight.w500,

            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
            isDestructive ? Colors.red : cs.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}
Future<void> showAppActionDialog({
  required BuildContext context,
  required String title,
  required VoidCallback onConfirm,
  required List<Widget> contentWidget,
  String confirmText = "Confirm",
  String cancelText = "Cancel",
  bool isDestructive = false,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => AppActionDialog(
      title: title,
      contentWidget: contentWidget,
      onConfirm: onConfirm,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: isDestructive,
    ),
  );
}