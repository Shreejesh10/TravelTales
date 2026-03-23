import 'package:flutter/foundation.dart' show kIsWeb;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = kIsWeb || screenWidth >= 700;

    final double dialogMaxWidth = isWideScreen ? 460 : double.infinity;
    final double borderRadius = isWideScreen ? 12 : 12.r;
    final double titleFontSize = isWideScreen ? 18 : 18.sp;
    final double actionRadius = isWideScreen ? 10 : 10.r;
    final EdgeInsets contentPadding = EdgeInsets.symmetric(
      horizontal: isWideScreen ? 24 : 20.w,
      vertical: isWideScreen ? 8 : 8.h,
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWideScreen ? 24 : 16,
        vertical: 24,
      ),
      title: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogMaxWidth,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogMaxWidth,
          maxHeight: isWideScreen ? 420 : 380,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: contentPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contentWidget,
            ),
          ),
        ),
      ),
      actionsPadding: EdgeInsets.fromLTRB(
        isWideScreen ? 16 : 12,
        0,
        isWideScreen ? 16 : 12,
        isWideScreen ? 12 : 8,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            cancelText,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: isWideScreen ? 14 : 14.sp,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? Colors.red : cs.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(actionRadius),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? 18 : 18.w,
              vertical: isWideScreen ? 12 : 12.h,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(
            confirmText,
            style: TextStyle(
              fontSize: isWideScreen ? 14 : 14.sp,
            ),
          ),
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

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class AppActionDialog extends StatelessWidget {
//   final String title;
//   final List<Widget> contentWidget;
//   final String confirmText;
//   final String cancelText;
//   final VoidCallback onConfirm;
//   final bool isDestructive;
//
//   const AppActionDialog({
//     super.key,
//     required this.title,
//     required this.contentWidget,
//     required this.onConfirm,
//     this.confirmText = "Confirm",
//     this.cancelText = "Cancel",
//     this.isDestructive = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//
//     return AlertDialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//           fontSize: 18.sp,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: contentWidget,
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text(
//             cancelText,
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//
//             ),
//           ),
//         ),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor:
//             isDestructive ? Colors.red : cs.primary,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//             onConfirm();
//           },
//           child: Text(confirmText),
//         ),
//       ],
//     );
//   }
// }
// Future<void> showAppActionDialog({
//   required BuildContext context,
//   required String title,
//   required VoidCallback onConfirm,
//   required List<Widget> contentWidget,
//   String confirmText = "Confirm",
//   String cancelText = "Cancel",
//   bool isDestructive = false,
// }) {
//   return showDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (_) => AppActionDialog(
//       title: title,
//       contentWidget: contentWidget,
//       onConfirm: onConfirm,
//       confirmText: confirmText,
//       cancelText: cancelText,
//       isDestructive: isDestructive,
//     ),
//   );
// }