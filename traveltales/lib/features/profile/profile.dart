import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/user_info.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/actionDialogBox.dart';
import 'package:traveltales/core/ui/components/languageDialog.dart';
import 'package:traveltales/core/ui/components/themeDialog.dart';
import 'package:traveltales/core/ui/components/viewAllRow.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker picker = ImagePicker();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  File? profileImageFile;
  String? profilePhotoUrl;
  bool isLoading = false;
  UserInfo? me;
  String? userError;

  @override
  void initState() {
    super.initState();
    loadProfilePhoto();
    _loadUser();
  }

  Future<void> _loadUser()async{
    setState(() {
      userError = null;
      isLoading = true;
    });
    try{
      final user = await fetchMeUserInfo();
      setState(() {
        me = user;
        isLoading = false;
      });
    }catch(e){
      setState(() {
        userError = e.toString();
        isLoading = false;
      });

    }
  }
  Future<void> loadProfilePhoto() async {
    final url = await storage.read(key: 'profile_picture_url');
    if (url != null) {
      setState(() {
        profilePhotoUrl = url;
      });
    }
  }

  Future<void> _changeProfilePicture() async {

    try {
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return;

      final file = File(picked.path);
      final converted = await convertToJpg(file);


      setState(() {
        profileImageFile = converted;
        isLoading = true;
      });

      final uploadedUrl = await uploadProfilePicture(converted);

      if (!mounted) return;
      setState(() {
        profilePhotoUrl = uploadedUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated!")),

      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not update photo: $e")),
      );
      log("Could not update photo: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<File> convertToJpg(File input) async {
    final dir = await getTemporaryDirectory();
    final outPath = p.join(
      dir.path,
      "profile_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      input.absolute.path,
      outPath,
      quality: 85,
      format: CompressFormat.jpeg,
    );

    if (result == null) throw Exception("Image conversion failed");

    return File(result.path);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;


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
            onPressed: () {
              Navigator.pushNamed(context, RouteName.settingScreen);
            },
            icon: Icon(Icons.edit, size: compactDimens.medium1),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
        children: [
          _profile(
            imagePath: 'assets/images/HomePageImage.png',
            userName:me?.userName ?? "",
            email: me?.email ?? "",
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                  child: _statCard(
                    iconColor: cs.primary,
                    icon: Icons.person_outline,
                    value: "15",
                    label: SharedRes.strings(context).totalFriends,
                    onTap: () {},
                  )
              ),
              SizedBox(width: 10.w),
              Expanded(
                  child: _statCard(
                    iconColor: Colors.green,
                    icon: Icons.event_available_outlined,
                    value: "234",
                    label: SharedRes.strings(context).eventsBooked,
                    onTap: () {},)
              ),
              SizedBox(width: 10.w),
              Expanded(
                  child: _statCard(
                    iconColor: Colors.red,
                    icon: Icons.pending_outlined,
                    value: "5",
                    label: SharedRes.strings(context).requestPending,
                    onTap: () {},)
              )

            ],
          ),
          SizedBox(height: 16.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ViewAllRow(
                  firstText: SharedRes.strings(context).recentBookedEvents,
                  onPressed:(){}
              ),
              SizedBox(height: 8.h),
              _bookedEventCard(
                context,
                  imageAsset: "assets/images/Bouddha.png",
                  title: "Everest Base Camp",
                  statusText: "Completed Oct 15, 2025",
                  organizerText: "Kalpa Tours and Travels",
                  difficultyText: "Hard",
                  onTap: (){}
              ),
              SizedBox(height: 8.h),
              _bookedEventCard(
                  context,
                  imageAsset: "assets/images/Bouddha.png",
                  title: "Everest Base Camp",
                  statusText: "Completed Oct 15, 2025",
                  organizerText: "Kalpa Tours and Travels",
                  difficultyText: "Hard",
                  onTap: (){}
              ),
              SizedBox(height: 8.h),
              _bookedEventCard(
                  context,
                  imageAsset: "assets/images/Bouddha.png",
                  title: "Everest Base Camp",
                  statusText: "Completed Oct 15, 2025",
                  organizerText: "Kalpa Tours and Travels",
                  difficultyText: "Hard",
                  onTap: (){}
              )
            ],
          ),
          SizedBox(height: 16.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ViewAllRow(
                  firstText: SharedRes.strings(context).settings,
                  onPressed:(){},
                isViewAll: false,
              ),
              SizedBox(height: 8.h),
              _settingsTile(
                icon: Icons.person_outline,
                title: SharedRes.strings(context).accountSetting,
                onTap: (){
                  Navigator.pushNamed(context, RouteName.settingScreen);
                },
              ),
              SizedBox(height: 8.h),
              _settingsTile(
                icon: Icons.do_not_disturb_on_total_silence_rounded,
                title: SharedRes.strings(context).language,
                onTap: (){
                  AppLanguageDialog.show(context);
                },
              ),
              SizedBox(height: 8.h),
              _settingsTile(
                icon: Icons.password,
                title: SharedRes.strings(context).changePassword,
                onTap: (){
                  showAppActionDialog(
                      context: context,
                      title: SharedRes.strings(context).changePassword,
                      contentWidget: [
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: SharedRes.strings(context).password,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),


                          ),
                        ),
                        SizedBox(height: 8.h,),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: SharedRes.strings(context).password,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),


                          ),
                        )
                      ],
                      onConfirm: () {}
                  );
                },
              ),
              SizedBox(height: 8.h),
              _settingsTile(
                icon: Icons.light_mode_outlined,
                title: SharedRes.strings(context).theme,
                onTap: (){
                  AppThemeDialog.show(context);
                },
              ),
              SizedBox(height: 8.h),
              _settingsTile(
                icon: Icons.logout,
                title: SharedRes.strings(context).logout,
                onTap: (){
                  showAppActionDialog(
                    context: context,
                    title: SharedRes.strings(context).logout,
                    contentWidget: [
                      Text(
                          SharedRes.strings(context).logoutMessage),
                    ],
                    confirmText: SharedRes.strings(context).ok,
                    isDestructive: true,
                    onConfirm: () async {
                    },
                  );
                },
                textColor: Colors.red,
                iconColor: Colors.red,
              ),
            ]
          )
        ],
      ),

    );
  }
  Widget _settingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.getContainerBoxColor(context),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: iconColor,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: 14.sp,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
  Widget _profile({
    required String imagePath,
    required String userName,
    required String email,
  }) {
    final cs = Theme.of(context).colorScheme;

    ImageProvider avatarProvider;
    if (profileImageFile != null && isLoading) {
      avatarProvider = FileImage(profileImageFile!);
    } else if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty) {
      avatarProvider = NetworkImage("$API_URL$profilePhotoUrl");
    }
    else
      {
        avatarProvider = AssetImage(imagePath);
      }

    return Align(
      child: Column(
        children: [
          SizedBox(height: 16.h),

          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 84.w,
                height: 84.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: DecorationImage(
                    image: avatarProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned(
                right: -2,
                bottom: -2,
                child: InkWell(
                  onTap: _changeProfilePicture,
                  borderRadius: BorderRadius.circular(99.r),
                  child: Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          color: Colors.black.withOpacity(0.15),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 16.sp,
                      color: cs.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),
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

  Widget _statCard({
        required IconData icon,
        required String value,
        required String label,
        required VoidCallback onTap,
        required iconColor
      }) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.getContainerBoxColor(context),
          borderRadius: BorderRadius.circular(14.r),

        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20.sp, color: iconColor),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _bookedEventCard(
      BuildContext context, {
        required String imageAsset,
        required String title,
        required String statusText,
        required String organizerText,
        required String difficultyText,
        required VoidCallback onTap,
      }) {
    final cs = Theme.of(context).colorScheme;

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
                  _infoRow(Icons.check_circle_outline, statusText, Colors.green),
                  SizedBox(height: 4.h),
                  _infoRow(Icons.verified_outlined, organizerText, Colors.green),
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




