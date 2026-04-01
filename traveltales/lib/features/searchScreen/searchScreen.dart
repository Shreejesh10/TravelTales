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
  static const List<String> _difficultyOptions = [
    "Easy",
    "Medium",
    "Hard",
  ];

  List<Destination> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _selectedDifficulty;

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

  List<Destination> get _filteredResults {
    return _searchResults.where((destination) {
      final difficulty = destination.extraInfo.difficultyLevel.trim();

      final matchesDifficulty =
          _selectedDifficulty == null ||
          difficulty.toLowerCase() == _selectedDifficulty!.toLowerCase();

      return matchesDifficulty;
    }).toList();
  }

  Future<void> _openFilterSheet() async {
    String? tempDifficulty = _selectedDifficulty;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 4.h,
                        width: 42.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      "Filter Destinations",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      "Difficulty",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _difficultyOptions.map((option) {
                        return ChoiceChip(
                          label: Text(option),
                          backgroundColor: AppColors.getContainerBoxColor(context),
                          selected: tempDifficulty == option,
                          onSelected: (_) {
                            setModalState(() {
                              tempDifficulty =
                                  tempDifficulty == option ? null : option;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 22.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempDifficulty = null;
                              });
                            },
                            child: const Text("Clear"),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedDifficulty = tempDifficulty;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text("Apply"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _activeFilterChip({
    required String label,
    required VoidCallback onRemoved,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.getContainerBoxColor(context),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onRemoved,
            child: const Icon(Icons.close, size: 16),
          ),
        ],
      ),
    );
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
                        onFilterTap: _openFilterSheet,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                if (_selectedDifficulty != null)
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, bottom: 12.h),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedDifficulty != null)
                            Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: _activeFilterChip(
                                label: "Difficulty: $_selectedDifficulty",
                                onRemoved: () {
                                  setState(() {
                                    _selectedDifficulty = null;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

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
    final filteredResults = _filteredResults;

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

    if (filteredResults.isEmpty) {
      return Center(
        child: Text(
          "No destinations match these filters",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: filteredResults.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final destination = filteredResults[index];

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
