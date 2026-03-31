import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/model/genre_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/destinationCard.dart';
import 'package:traveltales/core/ui/components/preference.dart';
import 'package:traveltales/core/ui/components/searchField.dart';
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

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    if (homeProvider.isLoading && !homeProvider.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
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
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications_none,
                size: compactDimens.medium1,
              ),
            ),
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
                child: buildDestinationList(homeProvider.all),
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