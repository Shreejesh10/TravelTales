import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/destinationAPI.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/searchField.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';

import '../../core/model/destination_model.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Destination> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  Future<void> _searchDestinations(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await searchDestination(trimmedQuery);

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: _hideKeyboard,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        _hideKeyboard();
                        if (mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: SearchFilterBar(
                        controller: _searchController,
                        onChanged: (text) {
                          _searchDestinations(text);
                        },
                        onFilterTap: () {},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 16),
                    child: _buildBody(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Text(
          "Search destinations",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey,
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          "No destinations found",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final destination = _searchResults[index];

        final imagePath =
        destination.extraInfo?.frontImagePath.isNotEmpty == true
            ? destination.extraInfo!.frontImagePath.first
            : destination.extraInfo?.photos.isNotEmpty == true
            ? destination.extraInfo!.photos.first
            : "";

        final fullImageUrl =
        imagePath.isNotEmpty && imagePath.startsWith("http")
            ? imagePath
            : "$API_URL$imagePath";

        final bestTime =
            destination.extraInfo?.bestTimeToVisit ?? "Best season unavailable";

        final difficulty =
            destination.extraInfo?.difficultyLevel ?? "Unknown";

        return _bookedEventCard(
          imageUrl: fullImageUrl,
          title: destination.placeName,
          statusText: destination.location,
          organizerText: bestTime,
          difficultyText: difficulty,
          onTap: () {
            Navigator.pushNamed(
              context,
              RouteName.destinationDetailScreen,
              arguments: destination.destinationId,
            );
          },
        );
      },
    );
  }

  Widget _bookedEventCard({
    required String imageUrl,
    required String title,
    required String statusText,
    required String organizerText,
    required String difficultyText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.containerBoxColor
              : AppColors.darkContainerBoxColor,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                height: 54.w,
                width: 54.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    height: 54.w,
                    width: 54.w,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported_outlined),
                  );
                },
              )
                  : Container(
                height: 54.w,
                width: 54.w,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_outlined),
              ),
            ),
            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  _infoRow(
                    Icons.location_on_outlined,
                    statusText,
                    AppColors.getIconColors(context),
                  ),
                  SizedBox(height: 4.h),
                  _infoRow(
                    Icons.calendar_month,
                    organizerText,
                    AppColors.getIconColors(context),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.difficultyBgColor(difficultyText),
                borderRadius: BorderRadius.circular(99.r),
              ),
              child: Text(
                difficultyText,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.difficultyColor(difficultyText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: iconColor),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}