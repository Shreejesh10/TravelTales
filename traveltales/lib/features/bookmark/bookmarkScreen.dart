import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/bookmarkAPI.dart';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<Destination> bookmarks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final data = await getBookmarks();

      final parsed = data
          .map<Destination>((json) => Destination.fromJson(json))
          .toList();

      setState(() {
        bookmarks = parsed;
        isLoading = false;
      });
    } catch (e) {
      print("Bookmark load error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bookmarks")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookmarks.isEmpty
          ? const Center(child: Text("No bookmarks yet"))
          : GridView.builder(
        padding: EdgeInsets.all(12.w),
        itemCount: bookmarks.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final destination = bookmarks[index];
          return viewAllCard(context, destination);
        },
      ),
    );
  }

  Widget viewAllCard(BuildContext context, Destination destination) {
    final image = destination.extraInfo.frontImagePath.isNotEmpty
        ? destination.extraInfo.frontImagePath.first
        : destination.extraInfo.photos.isNotEmpty
        ? destination.extraInfo.photos.first
        : '';

    final fullImagePath =
    image.isNotEmpty ? '$API_URL$image' : 'assets/images/Bouddha.png';

    final isNetworkImage = image.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          RouteName.destinationDetailScreen,
          arguments: destination.destinationId,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getContainerBoxColor(context),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            children: [
              Positioned.fill(
                child: isNetworkImage
                    ? Image.network(
                  fullImagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/Bouddha.png',
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Image.asset(
                  'assets/images/Bouddha.png',
                  fit: BoxFit.cover,
                ),
              ),

              /// Gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 55.h,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black45,
                        Colors.black54,
                        Colors.black54,
                      ],
                      stops: [0.0, 0.3, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              /// Text
              Positioned(
                bottom: 6.h,
                left: 8.w,
                right: 8.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: compactDimens.small3,
                          color: const Color(0xFF95B1CC),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            destination.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFF95B1CC),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      destination.placeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}