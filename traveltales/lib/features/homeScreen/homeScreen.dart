import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/core/ui/components/preference.dart';
import 'package:traveltales/core/ui/components/scarchField.dart';
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
            padding: EdgeInsets.only( left:compactDimens.small3),
            child: Image.asset(
              Theme.of(context).brightness ==Brightness.dark
              ?'assets/images/MountainDark.png'
              :'assets/images/Mountain.png',
              height: compactDimens.medium2,
              fit: BoxFit.contain,
            ),
            ),
          actions: [
            IconButton(onPressed: (){},
                icon: Icon(Icons.notifications_none, size: compactDimens.medium1,)
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(SharedRes.strings(context).adventureAwaitsLetsGo,
                    style: headingStyle(),
                  ),
                  Row(
                    children: [
                      Text(SharedRes.strings(context).explore,
                      style: headingStyle(),
                      ),
                      SizedBox(width: compactDimens.small1,),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Image.asset(
                          'assets/images/HomePageImage.png',
                          height: compactDimens.medium2,
                          width: compactDimens.homeScreenImageSize,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ]
                  ),
                  const SizedBox(height: 12,),
                  SearchFilterBar(
                    hintText: SharedRes.strings(context).searchDestination,
                  ),
                  const SizedBox(height: 12,),
                  DestinationPreference(),
                  const SizedBox(height: 12,),
                  ViewAllRow(
                    firstText: SharedRes.strings(context).recommendedForYou,
                  )

                ],
              )
          ),
        ),
      ),
    );
  }
  TextStyle headingStyle(){
    return TextStyle(
      fontSize: 42.sp,
      height: 1.2
    );
  }
}
