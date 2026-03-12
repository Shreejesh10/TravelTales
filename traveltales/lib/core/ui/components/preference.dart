import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DestinationPreference extends StatelessWidget {
  final List<String> genres;
  final String selectedGenre;
  final void Function(String)? onGenreSelected;

  const DestinationPreference({
    super.key,
    required this.genres,
    required this.selectedGenre,
    this.onGenreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = genre == selectedGenre;

          return Padding(
            padding: EdgeInsets.only(right: 6.w),
            child: GestureDetector(
              onTap: () => onGenreSelected?.call(genre),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade400,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    genre,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
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