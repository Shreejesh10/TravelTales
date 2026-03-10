import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/destinationCard.dart';
import 'package:traveltales/core/ui/components/preference.dart';
import 'package:traveltales/core/ui/components/searchField.dart';
import 'package:traveltales/core/ui/components/viewAllRow.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Destination>> recommendedFuture;
  late Future<List<Destination>> allDestinationsFuture;

  Destination? destination;

  @override
  void initState() {
    super.initState();
    recommendedFuture = getRecommendedDestinations();
    allDestinationsFuture = getAllDestinations();
  }

  String getDestinationImage(Map<String, dynamic> destination) {
    final extraInfo = destination['extra_info'] as Map<String, dynamic>?;

    if (extraInfo != null) {
      final frontImages = extraInfo['front_image_path'];
      if (frontImages is List && frontImages.isNotEmpty) {
        final firstImage = frontImages.first?.toString() ?? '';
        if (firstImage.isNotEmpty) {
          return '$API_URL$firstImage';
        }
      }

      final photos = extraInfo['photos'];
      if (photos is List && photos.isNotEmpty) {
        final firstPhoto = photos.first?.toString() ?? '';
        if (firstPhoto.isNotEmpty) {
          return '$API_URL$firstPhoto';
        }
      }
    }

    return '';
  }

  String getDestinationTitle(Map<String, dynamic> destination) {
    return destination['place_name']?.toString() ?? 'Unknown Destination';
  }

  String getDestinationLocation(Map<String, dynamic> destination) {
    return destination['location']?.toString() ?? 'Unknown Location';
  }

  Widget buildDestinationList(Future<List<Destination>> futureList) {
    return FutureBuilder<List<Destination>>(
      future: futureList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          log("Destination fetch error: ${snapshot.error}");
          return const Center(
            child: Text("Failed to load destinations"),
          );
        }

        final destinations = snapshot.data ?? [];

        if (destinations.isEmpty) {
          return const Center(
            child: Text("No destinations found"),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: destinations.length,
          itemBuilder: (context, index) {
            final destination = destinations[index];
            final image =
            destination.extraInfo?.frontImagePath.isNotEmpty == true
                ? destination.extraInfo!.frontImagePath.first
                : destination.extraInfo?.photos.isNotEmpty == true
                ? destination.extraInfo!.photos.first
                : "";

            log("IMAGE URL: $image");

            return DestinationCard(
              imagePath: "$API_URL$image",
              title: destination.placeName,
              location: destination.location,
              isNetworkImage: image.isNotEmpty,
              destinationId: destination.id,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_none, size: compactDimens.medium1),
            ),
          ],
        ),
        body: ListView(
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
            DestinationPreference(),
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
              child: buildDestinationList(recommendedFuture),
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
              child: buildDestinationList(allDestinationsFuture),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle headingStyle() {
    return TextStyle(fontSize: 42.sp, height: 1.2);
  }
}