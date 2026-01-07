import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                Text(SharedRes.strings(context).explore, style: headingStyle()),
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
              hintText: SharedRes.strings(context).searchDestination,
            ),

            const SizedBox(height: 12),
            DestinationPreference(),

            Divider( thickness: 1.5),

            ViewAllRow(
              firstText: SharedRes.strings(context).recommendedForYou,
              onPressed: (){
                Navigator.pushNamed(
                    context,
                    RouteName.viewAllScreen,
                    arguments: SharedRes.strings(context).recommendedForYou
                );
              },

            ),

            SizedBox(
              height: 220.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  DestinationCard(
                    imagePath: 'assets/images/Bouddha.png',
                    title: 'Bouddhanath Stupa',
                    location: 'Kathmandu, Nepal',
                  ),
                  DestinationCard(
                    imagePath: 'assets/images/Annapurna.png',
                    title: 'Annapurna Base Camp',
                    location: 'Annapurna, Nepal',
                  ),
                  DestinationCard(
                    imagePath: 'assets/images/Pathivara.png',
                    title: 'Pathivara Temple',
                    location: 'Mechi, Nepal',
                  ),
                ],
              ),
            ),

            ViewAllRow(
              firstText: SharedRes.strings(context).bestPlaceToVisit,
              onPressed: (){
                Navigator.pushNamed(
                    context,
                    RouteName.viewAllScreen,
                  arguments: SharedRes.strings(context).bestPlaceToVisit
                );
              },
            ),

            SizedBox(
              height: 220.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  DestinationCard(
                    imagePath: 'assets/images/Bouddha.png',
                    title: 'Bouddhanath Stupa',
                    location: 'Kathmandu, Nepal',
                  ),
                  DestinationCard(
                    imagePath: 'assets/images/Annapurna.png',
                    title: 'Annapurna Base Camp',
                    location: 'Annapurna, Nepal',
                  ),
                  DestinationCard(
                    imagePath: 'assets/images/Pathivara.png',
                    title: 'Pathivara Temple',
                    location: 'Mechi, Nepal',
                  ),
                ],
              ),
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
