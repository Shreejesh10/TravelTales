import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/notification/notificationService.dart';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/model/genre_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/destinationCard.dart';
import 'package:traveltales/core/ui/components/preference.dart';
import 'package:traveltales/core/ui/components/searchField.dart';
import 'package:traveltales/core/ui/components/shimmerView.dart';
import 'package:traveltales/core/ui/components/viewAllRow.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';
import 'package:traveltales/api/destinationAPI.dart';
import 'package:traveltales/features/homeScreen/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  String selectedGenre = "All";
  Map<String, int> genreIndexMap = {};

  @override
  void initState() {
    super.initState();

    Future.microtask((){
      context.read<HomeProvider>().loadHomeData();
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

  Widget buildGenreFilter(HomeProvider homeProvider) {
    final genres = homeProvider.genres;

    if (genres.isEmpty) {
      return SizedBox(
        height: 36.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    genreIndexMap = {
      for (int i = 0; i < genres.length; i++)
        genres[i].name.trim().toLowerCase(): i,
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
  }

  Widget buildDestinationList(List<Destination> destinations) {
    final filtered = destinations
        .where((d) => matchesGenre(d, selectedGenre))
        .toList();

    if (filtered.isEmpty) {
      return Center(child: Text("No $selectedGenre destinations found"));
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final destination = filtered[index];

        final image =
        destination.extraInfo?.frontImagePath.isNotEmpty == true
            ? destination.extraInfo!.frontImagePath.first
            : destination.extraInfo?.photos.isNotEmpty == true
            ? destination.extraInfo!.photos.first
            : "";

        return DestinationCard(
          imagePath: "$API_URL$image",
          title: destination.placeName,
          location: destination.location,
          isNetworkImage: image.isNotEmpty,
          destinationId: destination.destinationId,
        );
      },
    );
  }

  Widget _buildInitialLoadingShimmer() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
      children: [
        SizedBox(height: 12.h),
        ShimmerView(width: 220.w, height: 34.h, radius: 14),
        SizedBox(height: 10.h),
        Row(
          children: [
            ShimmerView(width: 160.w, height: 34.h, radius: 14),
            SizedBox(width: compactDimens.small1),
            ShimmerView(
              width: compactDimens.homeScreenImageSize,
              height: compactDimens.medium2,
              radius: 16,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ShimmerView(width: double.infinity, height: 48.h, radius: 24),
        SizedBox(height: 16.h),
        SizedBox(
          height: 36.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (_, __) =>
                ShimmerView(width: 84.w, height: 36.h, radius: 999),
          ),
        ),
        SizedBox(height: 16.h),
        ShimmerView(width: double.infinity, height: 2.h, radius: 2),
        SizedBox(height: 16.h),
        _buildSectionShimmer(),
        SizedBox(height: 16.h),
        _buildSectionShimmer(),
        SizedBox(height: 16.h),
        _buildSectionShimmer(),
      ],
    );
  }

  Widget _buildSectionShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerView(width: 150.w, height: 18.h, radius: 8),
            ShimmerView(width: 54.w, height: 16.h, radius: 8),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 220.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (_, __) {
              return Container(
                width: 170.w,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerView(
                      width: double.infinity,
                      height: 140.h,
                      radius: 16,
                    ),
                    SizedBox(height: 12.h),
                    ShimmerView(width: 110.w, height: 14.h, radius: 8),
                    SizedBox(height: 8.h),
                    ShimmerView(width: 80.w, height: 12.h, radius: 8),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationService.instance.unreadCountNotifier,
      builder: (context, unreadCount, _) {
        return IconButton(
          onPressed: () {
            Navigator.pushNamed(context, RouteName.notificationScreen);
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none,
                size: compactDimens.medium1,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).appBarTheme.backgroundColor ??
                            Theme.of(context).scaffoldBackgroundColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    if (homeProvider.isLoading && !homeProvider.hasLoaded) {
      return _buildInitialLoadingShimmer();
    } //for initial API Loading
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leadingWidth: compactDimens.extraLarge,
          leading: Padding(
            padding: EdgeInsets.only(left: compactDimens.small3),
            child: Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/images/MountainDark.png'
                  : 'assets/images/Mountain.png',
              height: compactDimens.medium2,
              fit: BoxFit.contain,
            ),
          ),
          actions: [
            _buildNotificationButton(),
          ],
        ),
        body: RefreshIndicator(
          onRefresh:() => context.read<HomeProvider>().refresh() ,
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
            children: [
              Text(
                SharedRes.strings(context).adventureAwaitsLetsGo,
                style: headingStyle(),
              ),
              Row(
                children: [
                  Text(
                    SharedRes.strings(context).explore,
                    style: headingStyle(),
                  ),
                  SizedBox(width: compactDimens.small1),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.asset(
                      'assets/images/HomePageImage.png',
                      height: compactDimens.medium2,
                      width: compactDimens.homeScreenImageSize,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SearchFilterBar(
                onTap: () => Navigator.pushNamed(context, RouteName.searchScreen),
                hintText: SharedRes.strings(context).searchDestination,
                isFilter: false,
              ),
              const SizedBox(height: 12),
              buildGenreFilter(homeProvider),
              const Divider(thickness: 1.5),
              ViewAllRow(
                firstText: SharedRes.strings(context).recommendedForYou,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteName.viewAllScreen,
                    arguments: SharedRes.strings(context).recommendedForYou,
                  );
                },
              ),
              SizedBox(
                height: 220.h,
                child: buildDestinationList(homeProvider.recommended),
              ),
              ViewAllRow(
                firstText: SharedRes.strings(context).bestPlaceToVisit,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteName.viewAllScreen,
                    arguments: SharedRes.strings(context).bestPlaceToVisit,
                  );
                },
              ),
              SizedBox(
                height: 220.h,
                child: buildDestinationList(homeProvider.bestPlacesToVisit),
              ),
              ViewAllRow(
                firstText: SharedRes.strings(context).quickGateway,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteName.viewAllScreen,
                    arguments: SharedRes.strings(context).quickGateway,
                  );
                },
              ),
              SizedBox(
                height: 220.h,
                child: buildDestinationList(homeProvider.quickGetaways),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle headingStyle() {
    return TextStyle(
      fontSize: 42.sp,
      height: 1.2,
    );
  }
}
