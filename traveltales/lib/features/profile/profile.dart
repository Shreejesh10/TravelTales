import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/bookingAPI.dart';
import 'package:traveltales/api/friendsApi.dart';
import 'package:traveltales/core/model/booking_model.dart';
import 'package:traveltales/core/model/event_model.dart';
import 'package:traveltales/core/model/friend_request_model.dart';
import 'package:traveltales/core/model/user_info.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/actionDialogBox.dart';
import 'package:traveltales/core/ui/components/functions/dateTime/app_formatters.dart';
import 'package:traveltales/core/ui/components/languageDialog.dart';
import 'package:traveltales/core/ui/components/shimmerView.dart';
import 'package:traveltales/core/ui/components/textField/passwordTextField.dart';
import 'package:traveltales/core/ui/components/themeDialog.dart';
import 'package:traveltales/core/ui/components/viewAllRow.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker picker = ImagePicker();
  final BookingApi _bookingService = BookingApi();


  late Future<List<Booking>> _bookingsFuture;
  late Future<List<Event>> _eventsFuture;

  File? profileImageFile;
  String? profilePhotoUrl;
  bool isLoading = false;
  UserInfo? me;
  String? userError;
  int totalFriendsCount = 0;
  int pendingRequestCount = 0;
  int totalBookedEventsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _bookingsFuture = _safeGetBookings();
    _eventsFuture = _safeGetEvents();
    _loadStats();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Booking>> _safeGetBookings() async {
    try {
      return await _bookingService.getMyBookings();
    } catch (e) {
      log("Failed to load bookings: $e");
      return [];
    }
  }

  Future<List<Event>> _safeGetEvents() async {
    try {
      return await getAllEvents();
    } catch (e) {
      log("Failed to load events: $e");
      return [];
    }
  }

  Future<void> _loadUser() async {
    setState(() {
      userError = null;
      isLoading = true;
    });

    try {
      final user = await fetchMeUserInfo();
      if (!mounted) return;
      setState(() {
        me = user;
        userError = null;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        me = null;
        userError = e.toString();
        isLoading = false;
      });
      log("Failed to load user: $e");
    }
  }

  Future<void> _loadStats() async {
    setState(() {
      isLoading = true;
    });

    try {
      final results = await Future.wait([
        FriendApi.getFriends(),
        FriendApi.getIncomingFriendRequests(),
        _bookingService.getMyBookings(),
      ]);

      final friends = results[0] as List<FriendModel>;
      final requests = results[1] as List<FriendRequestModel>;
      final bookings = results[2] as List<Booking>;

      if (!mounted) return;

      setState(() {
        totalFriendsCount = friends.length;
        pendingRequestCount = requests
            .where((r) => r.status.toLowerCase() == "pending")
            .length;
        totalBookedEventsCount = bookings.length;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;

      });

      log("Failed to load stats: $e");
    }
  }

  Future<void> logout() async {
    await logoutAndClearAuth();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AuthRouteName.loginScreen,
          (route) => false,
    );
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
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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

    if (result == null) {
      throw Exception("Image conversion failed");
    }

    return File(result.path);
  }

  Widget _buildProfileLoadingShimmer() {
    Widget statCard() {
      return Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            children: [
              ShimmerView(width: 20.w, height: 20.w, radius: 8),
              SizedBox(height: 8.h),
              ShimmerView(width: 36.w, height: 20.h, radius: 8),
              SizedBox(height: 6.h),
              ShimmerView(width: 70.w, height: 10.h, radius: 6),
            ],
          ),
        ),
      );
    }

    Widget settingsTile() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            ShimmerView(width: 20.w, height: 20.w, radius: 8),
            SizedBox(width: 16.w),
            Expanded(
              child: ShimmerView(
                width: double.infinity,
                height: 14.h,
                radius: 8,
              ),
            ),
            SizedBox(width: 10.w),
            ShimmerView(width: 14.w, height: 14.w, radius: 7),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
      children: [
        SizedBox(height: 16.h),
        Column(
          children: [
            ShimmerView(width: 84.w, height: 84.w, radius: 42),
            SizedBox(height: 10.h),
            ShimmerView(width: 140.w, height: 20.h, radius: 10),
            SizedBox(height: 8.h),
            ShimmerView(width: 180.w, height: 12.h, radius: 8),
          ],
        ),
        SizedBox(height: 18.h),
        Row(
          children: [
            statCard(),
            SizedBox(width: 10.w),
            statCard(),
            SizedBox(width: 10.w),
            statCard(),
          ],
        ),
        SizedBox(height: 18.h),
        ShimmerView(width: 150.w, height: 18.h, radius: 8),
        SizedBox(height: 8.h),
        _buildRecentBookingsLoadingShimmer(),
        SizedBox(height: 18.h),
        ShimmerView(width: 80.w, height: 18.h, radius: 8),
        SizedBox(height: 8.h),
        settingsTile(),
        SizedBox(height: 8.h),
        settingsTile(),
        SizedBox(height: 8.h),
        settingsTile(),
      ],
    );
  }

  Widget _buildRecentBookingsLoadingShimmer() {
    Widget recentCard() {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            ShimmerView(width: 54.w, height: 54.w, radius: 12),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerView(width: 120.w, height: 14.h, radius: 8),
                  SizedBox(height: 8.h),
                  ShimmerView(width: 150.w, height: 12.h, radius: 8),
                  SizedBox(height: 8.h),
                  ShimmerView(width: 100.w, height: 12.h, radius: 8),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            ShimmerView(width: 58.w, height: 24.h, radius: 999),
          ],
        ),
      );
    }

    return Column(
      children: [
        recentCard(),
        SizedBox(height: 8.h),
        recentCard(),
        SizedBox(height: 8.h),
        recentCard(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isLoading && me == null) {
      return _buildProfileLoadingShimmer();
    }

    final userName = me?.userName?.trim().isNotEmpty == true
        ? me!.userName
        : "Guest User";

    final email = me?.email?.trim().isNotEmpty == true
        ? me!.email
        : "guest@traveltales.com";

    final profileImage = profilePhotoUrl ??
        (me?.profilePictureUrl ?? "");

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
              Navigator.pushNamed(context, RouteName.addFriendScreen);
            },
            icon: Icon(Icons.person_add, size: compactDimens.medium1),
          ),
        ],
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        onRefresh: () async {
          await _loadUser();
          await _loadStats();
          setState(() {
            _bookingsFuture = _safeGetBookings();
            _eventsFuture = _safeGetEvents();
          });
        },
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
          children: [
            _profile(
              imagePath: profileImage,
              userName: userName,
              email: email,
            ),
            SizedBox(height: 16.h),

            if (userError != null)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "Could not load account info. Showing fallback data.",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    iconColor: cs.primary,
                    icon: Icons.person_outline,
                    value: isLoading ?"...": totalFriendsCount.toString(),
                    label: SharedRes.strings(context).totalFriends,
                    onTap: () {
                      Navigator.pushNamed(context, RouteName.totalFriendScreen);
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _statCard(
                    iconColor: Colors.green,
                    icon: Icons.event_available_outlined,
                    value: isLoading ? "..." : totalBookedEventsCount.toString(),
                    label: SharedRes.strings(context).eventsBooked,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteName.dashBoardScreen,
                        arguments: 1,
                      );
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _statCard(
                    iconColor: Colors.red,
                    icon: Icons.pending_outlined,
                    value: isLoading ? "...": pendingRequestCount.toString(),
                    label: SharedRes.strings(context).requestPending,
                    onTap: () {
                      Navigator.pushNamed(context, RouteName.acceptFriendScreen);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ViewAllRow(
                  firstText: SharedRes.strings(context).recentBookedEvents,
                  isViewAll: false,
                  onPressed: (){},
                ),
                SizedBox(height: 8.h),
                FutureBuilder<List<dynamic>>(
                  future: Future.wait([
                    _bookingsFuture,
                    _eventsFuture,
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildRecentBookingsLoadingShimmer();
                    }

                    if (!snapshot.hasData) {
                      return const Text("No bookings found");
                    }

                    final bookings = snapshot.data![0] as List<Booking>;
                    final events = snapshot.data![1] as List<Event>;

                    final eventMap = {
                      for (var e in events) e.eventId: e,
                    };

                    final completedBookings = bookings
                        .where(
                          (b) => b.status == "completed" || b.status == "pending",
                    )
                        .take(3)
                        .toList();

                    if (completedBookings.isEmpty) {
                      return const Text("No completed bookings yet");
                    }

                    return Column(
                      children: completedBookings.map((booking) {
                        final event = eventMap[booking.eventId];
                        if (event == null) return const SizedBox.shrink();

                        final destination = event.destination;
                        final List<String> images = destination.extraInfo.backdropPath;

                        final String imageUrl = images.isNotEmpty
                            ? "$API_URL${images.first}"
                            : "";

                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: _bookedEventCard(
                            context,
                            imageAsset: imageUrl,
                            title: destination.placeName,
                            statusText:
                            "${booking.status == "pending" ? "Pending" : "Completed"} ${event.toDate.toString().split('T').first}",
                            organizerText:
                            "Booked for ${booking.totalPeople} people",
                            difficultyText:
                            destination.extraInfo.difficultyLevel ?? "Normal",
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RouteName.eventDetailScreen,
                                arguments: event,
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ViewAllRow(
                  firstText: SharedRes.strings(context).settings,
                  onPressed: () {},
                  isViewAll: false,
                ),
                SizedBox(height: 8.h),
                _settingsTile(
                  icon: Icons.person_outline,
                  title: SharedRes.strings(context).accountSetting,
                  onTap: () {
                    Navigator.pushNamed(context, RouteName.settingScreen);
                  },
                ),
                SizedBox(height: 8.h),
                _settingsTile(
                  icon: Icons.do_not_disturb_on_total_silence_rounded,
                  title: SharedRes.strings(context).language,
                  onTap: () {
                    AppLanguageDialog.show(context);
                  },
                ),
                SizedBox(height: 8.h),
                _settingsTile(
                  icon: Icons.bookmark_border,
                  title: "See Bookmark",
                  onTap: () {
                    Navigator.pushNamed(context, RouteName.bookmarkScreen);
                  },
                ),
                SizedBox(height: 8.h),
                _settingsTile(
                  icon: Icons.room_preferences_outlined,
                  title: SharedRes.strings(context).changePreference,
                  onTap: () {
                    Navigator.pushNamed(context, RouteName.preferenceScreen);
                  },
                ),
                SizedBox(height: 8.h),
                _settingsTile(
                  icon: Icons.light_mode_outlined,
                  title: SharedRes.strings(context).theme,
                  onTap: () {
                    AppThemeDialog.show(context);
                  },
                ),
                SizedBox(height: 8.h),
                _settingsTile(
                  icon: Icons.logout,
                  title: SharedRes.strings(context).logout,
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () {
                    showAppActionDialog(
                      context: context,
                      title: SharedRes.strings(context).logout,
                      contentWidget: [
                        Text(SharedRes.strings(context).logoutMessage),
                      ],
                      confirmText: SharedRes.strings(context).ok,
                      isDestructive: true,
                      onConfirm: () async {
                        await logout();
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
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
            Icon(icon, size: 20.sp, color: iconColor),
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

    final String imageUrl =
    (imagePath.isNotEmpty && imagePath.startsWith("http"))
        ? imagePath
        : (imagePath.isNotEmpty ? "$API_URL$imagePath" : "");

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
                ),
                child: ClipOval(
                  child: profileImageFile != null
                      ? Image.file(
                    profileImageFile!,
                    fit: BoxFit.cover,
                  )
                      : imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Image.asset(
                        "assets/images/Annapurna.png",
                        fit: BoxFit.cover,
                      );
                    },
                  )
                      : Image.asset(
                    "assets/images/Annapurna.png",
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
    required Color iconColor,
  }) {
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: imageAsset.isNotEmpty
                  ? Image.network(
                imageAsset,
                height: 54.w,
                width: 54.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Image.asset(
                    "assets/images/Annapurna.png",
                    height: 54.w,
                    width: 54.w,
                    fit: BoxFit.cover,
                  );
                },
              )
                  : Image.asset(
                "assets/images/Annapurna.png",
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
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.difficultyBgColor(difficultyText),
                borderRadius: BorderRadius.circular(99.r),
              ),
              child: Text(
                difficultyText,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.difficultyColor(difficultyText),
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
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
