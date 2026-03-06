import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/searchField.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}
class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
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
                      onPressed: () async{
                       _hideKeyboard();
                        if(mounted) Navigator.pop(context);},
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: SearchFilterBar(
                        controller: _searchController,
                        onChanged: (text){},
                        onFilterTap: (){

                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h,),
                Padding(padding: EdgeInsets.only(left: 16, bottom: 16),
                  child: Column(
                    children: [
                      _bookedEventCard(
                          imageAsset: "assets/images/Annapurna.png",
                          title: "Annapurna Base Camp",
                          statusText: "Annapurna, Nepal",
                          organizerText: "October - September and May to March",
                          difficultyText: "Mid",
                          onTap: (){
                            Navigator.pushNamed(context, RouteName.destinationDetailScreen);
                          }
                      ),
                      SizedBox(height: 12,),
                      _bookedEventCard(
                          imageAsset: "assets/images/Annapurna.png",
                          title: "Annapurna Base Camp",
                          statusText: "Annapurna, Nepal",
                          organizerText: "October - September and May to March",
                          difficultyText: "Mid",
                          onTap: (){
                            Navigator.pushNamed(context, RouteName.destinationDetailScreen);
                          }
                      )
                    ],
                  ),

                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _bookedEventCard({
        required String imageAsset,
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
            // Image Section
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.asset(
                imageAsset,
                height: 54.w,
                width: 54.w,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  _infoRow(Icons.location_on_outlined, statusText, AppColors.getIconColors(context)),
                  SizedBox(height: 4.h),
                  _infoRow(Icons.calendar_month, organizerText, AppColors.getIconColors(context)),
                ],
              ),
            ),
            SizedBox(width: 10.w),

            // Difficulty Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(99.r),
              ),
              child: Text(
                difficultyText,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
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
            style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}