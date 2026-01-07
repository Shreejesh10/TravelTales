import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/core/ui/components/preference.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

class ViewAllScreen extends StatelessWidget {
  final String title;

  const ViewAllScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: compactDimens.medium2,
        title: Text(
          title,
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
            DestinationPreference(),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.85, // child aspects ratio helps to adjust card height
                ),

                itemCount: 6,
                itemBuilder: (context, index) {
                  return viewAllCard(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget viewAllCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .brightness == Brightness.light
            ? const Color(0xFFEDF0F7)
            : const Color(0xFF0C3047),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            Positioned.fill(
                child: Image.asset(
                  'assets/images/Bouddha.png',
                  fit: BoxFit.cover
                )
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
                    stops: [0.0,0.3,0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 6.h,
              left: 8.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: compactDimens.small3,color:Color(0xFF95B1CC) ),
                      Text("Kathmandu, Nepal",
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 10.sp,
                            color: Color(0xFF95B1CC)
                        ),)
                    ],
                  ),
                  Text(
                    'Bouddhanath Stupa',
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w500,
                      color: Colors.white
                    ),
                  ),

                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}
