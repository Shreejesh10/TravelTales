import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: Icon(Icons.settings, size: compactDimens.medium1),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
        children: [
          _profile(
            imagePath: 'assets/images/HomePageImage.png',
            userName:'Test User',
            email: 'test123@gmail.com'
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _profileCard(
                title: 'Friends',
                value: '15',
              ),
              _profileCard(
                title: 'Events Booked',
                value: '10',
              ),
              _profileCard(
                title: 'Pending',
                value: '10',
              ),

            ],
          ),
          SizedBox(height: 16.h),
          Container(
            height: 200,
            padding: EdgeInsets.all( 8.w),
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.containerBoxColor
                  : AppColors.darkContainerBoxColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Booked Events"),
                SizedBox(height: 8.h),
                bookedEvent()
              ],
            )
          ),



        ],
      ),

    );
  }

  Widget _profile({required String imagePath, required String userName, required String email}){
    return Align(
      child: Column(
        children: [
          SizedBox(height: 16.h),
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(height: 8.h),
          Text(
            userName,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            email,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),

    );
  }

  Widget _profileCard({ required String title, required String value}){
    return InkWell(
      onTap: (){} ,
      child: Container(

        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color:Theme.of(context).brightness == Brightness.light
              ?  AppColors.containerBoxColor
              :  AppColors.darkContainerBoxColor,
        ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w500),),
              Text(value, style: TextStyle(color: Colors.grey, fontSize: 20.sp,overflow: TextOverflow.ellipsis),)
            ]
      ),
      ),
    );
  }
  Widget bookedEvent(){
    return InkWell(
      onTap: (){},
      child: Container(
        padding: EdgeInsets.all(4.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child:Row(
          children: [
            ClipRect(
              child: Image.asset(
                'assets/images/Bouddha.png',
                height: 50.h,
                width: 50.w,
                fit: BoxFit.cover,
              ),
            )
          ]
        )
      )
    );
  }
  // Widget settingItemRow(BuildContext context) {
  //   return Container(
  //     padding: EdgeInsets.all(4.sp),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12.r),
  //     ),
  //     child: InkWell(
  //       borderRadius: BorderRadius.circular(12.r),
  //       onTap: () {},
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(
  //           horizontal: compactDimens.medium1,
  //           vertical: compactDimens.small2,
  //         ),
  //         child: Column(
  //           children: [
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: Text(
  //                     "Setting",
  //                     style: TextStyle(
  //                       fontSize: 14.sp,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                 ),
  //                 Icon(
  //                   Icons.chevron_right,
  //                   size: 20.sp,
  //                   color: Colors.grey,
  //                 ),
  //               ],
  //             ),
  //             Divider()
  //           ],
  //         ),
  //
  //       ),
  //     ),
  //   );
  // }
}




