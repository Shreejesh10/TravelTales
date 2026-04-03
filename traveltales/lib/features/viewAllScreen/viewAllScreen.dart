import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/model/genre_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/preference.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';
import 'package:traveltales/api/destinationAPI.dart';
import 'package:traveltales/features/homeScreen/home_provider.dart';

class ViewAllScreen extends StatefulWidget {
  final String title;

  const ViewAllScreen({super.key, required this.title});

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  late Future<List<Destination>> destinationsFuture;
  late Future<List<Genre>> genresFuture;
  bool _hasInitialized = false;
  Map<String, int> genreIndexMap = {};

  String selectedGenre = "All";

  @override
  void initState() {
    super.initState();
    genresFuture = fetchAllGenres();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasInitialized) return;

    destinationsFuture = _getDestinationsByTitle();
    _hasInitialized = true;
  }

  Future<List<Destination>> _getDestinationsByTitle() {
    final strings = SharedRes.strings(context);

    if (widget.title == strings.recommendedForYou) {
      return getRecommendedDestinations();
    }

    return getAllDestinations().then((destinations) {
      if (widget.title == strings.quickGateway) {
        return destinations.where(isQuickGetawayDestination).toList();
      }

      if (widget.title == strings.bestPlaceToVisit) {
        return destinations
            .where((destination) => !isQuickGetawayDestination(destination))
            .toList();
      }

      return destinations;
    });
  }

  bool matchesGenre(Destination destination, String selectedGenre) {
    if (selectedGenre == "All") return true;

    final genreKey = selectedGenre.trim().toLowerCase();
    final genreIndex = genreIndexMap[genreKey];

    if (genreIndex == null) return false;

    final vector = destination.extraInfo?.genreVector ?? [];

    if (genreIndex >= vector.length) return false;

    final score = (vector[genreIndex] as num).toDouble();

    return score > 0.5;
  }

  Widget buildGenreFilter() {
    return FutureBuilder<List<Genre>>(
      future: genresFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 36.h,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 36.h,
            child: const Center(child: Text("Failed to load genres")),
          );
        }

        final genres = snapshot.data ?? [];

        genreIndexMap = {
          for (int i = 0; i < genres.length; i++) genres[i].name.trim().toLowerCase(): i,
        };

        final genreNames = [
          "All",
          ...genres.map((g) => g.name).where((name) => name.trim().isNotEmpty),
        ];

        return DestinationPreference(
          genres: genreNames,
          selectedGenre: selectedGenre,
          onGenreSelected: (genre) {
            setState(() {
              selectedGenre = genre;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: compactDimens.medium2,
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, size: compactDimens.medium1),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: compactDimens.small3,
          right: compactDimens.small3,
          bottom: compactDimens.middle1,
        ),
        child: Column(
          children: [
            buildGenreFilter(),
            SizedBox(height: 12.h),
            Expanded(
              child: FutureBuilder<List<Destination>>(
                future: destinationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    log("ViewAllScreen fetch error: ${snapshot.error}");
                    return const Center(
                      child: Text("Failed to load destinations"),
                    );
                  }

                  final destinations = snapshot.data ?? [];

                  final filteredDestinations = destinations
                      .where((destination) => matchesGenre(destination, selectedGenre))
                      .toList();

                  if (filteredDestinations.isEmpty) {
                    return Center(
                      child: Text("No $selectedGenre destinations found"),
                    );
                  }

                  return GridView.builder(
                    itemCount: filteredDestinations.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      final destination = filteredDestinations[index];
                      return viewAllCard(context, destination);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget viewAllCard(BuildContext context, Destination destination) {
    final image = destination.extraInfo.frontImagePath.isNotEmpty
        ? destination.extraInfo.frontImagePath.first
        : destination.extraInfo.photos.isNotEmpty
        ? destination.extraInfo.photos.first
        : '';

    final fullImagePath = image.isNotEmpty
        ? '$API_URL$image'
        : 'assets/images/Bouddha.png';

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
