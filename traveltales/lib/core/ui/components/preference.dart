import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DestinationPreference extends StatefulWidget {
  final List<String> genres;
  final void Function(String)? onGenreSelected;

  const DestinationPreference({
    super.key,
    this.genres = const [
      "All", "Mountain", "Camping", "Trekking", "Hiking", "Drive", "Romantic"
    ],
    this.onGenreSelected,
  });

  @override
  State<DestinationPreference> createState() => _DestinationPreferenceState();
}

class _DestinationPreferenceState extends State<DestinationPreference> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,

        itemCount: widget.genres.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });

                widget.onGenreSelected?.call(widget.genres[index]);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  border: isSelected
                      ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5)
                      : null,
                ),

                child: Center(
                  child: Text(
                    widget.genres[index],
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
