import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/bookingAPI.dart';
import 'package:traveltales/api/friendsApi.dart';
import 'package:traveltales/core/model/friend_request_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/actionDialogBox.dart';
import 'package:traveltales/core/ui/components/app_flushbar.dart';
import 'package:traveltales/core/ui/components/button.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/features/bookedEventsDetail/esewa_webview_screen.dart';

import '../../../core/model/booking_model.dart';
import '../../../core/model/event_model.dart';
import '../../../core/model/user_info.dart';

class EventBookingScreen extends StatefulWidget {
  final Event event;
  const EventBookingScreen({super.key, required this.event});

  @override
  State<EventBookingScreen> createState() => _EventBookingScreenState();
}

class _EventBookingScreenState extends State<EventBookingScreen> {
  int selectedPayment = 0;
  bool isEsewaSelected = false;
  final BookingApi _bookingService = BookingApi();
  bool isLoading = false;
  String loadingText = "Processing...";
  bool _isLoadingFriends = false;
  int? _currentUserId;
  List<FriendModel> _friends = [];
  final Map<int, UserInfo> _friendUsers = {};
  final Set<int> _selectedFriendUserIds = {};
  Event get event => widget.event;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    if (_isLoadingFriends) return;

    setState(() => _isLoadingFriends = true);

    try {
      final userId = int.tryParse(await getUserId() ?? "");
      final friends = await FriendApi.getFriends();
      final Map<int, UserInfo> users = {};

      for (final friend in friends) {
        final otherUserId = userId == null
            ? friend.friendUserId
            : (friend.userId == userId ? friend.friendUserId : friend.userId);

        if (!users.containsKey(otherUserId)) {
          try {
            users[otherUserId] = await getUserById(otherUserId);
          } catch (e) {
            debugPrint("Failed to fetch friend $otherUserId: $e");
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _currentUserId = userId;
        _friends = friends;
        _friendUsers
          ..clear()
          ..addAll(users);
      });
    } catch (e) {
      debugPrint("Failed to load friends: $e");
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingFriends = false);
    }
  }

  int _getOtherUserId(FriendModel friend) {
    if (_currentUserId == null) {
      return friend.friendUserId;
    }
    return friend.userId == _currentUserId ? friend.friendUserId : friend.userId;
  }

  String? get _selectedFriendName {
    if (_selectedFriendUserIds.isEmpty) return null;
    if (_selectedFriendUserIds.length == 1) {
      final friendId = _selectedFriendUserIds.first;
      final friend = _friendUsers[friendId];
      final name = friend?.userName.trim();
      return (name == null || name.isEmpty) ? "User $friendId" : name;
    }
    return "${_selectedFriendUserIds.length} friends selected";
  }

  Future<void> _showInviteFriendDialog() async {
    if (_isLoadingFriends) {
      AppFlushbar.info(context, "Loading your friends...");
      return;
    }

    if (_friends.isEmpty) {
      await showAppActionDialog(
        context: context,
        title: "Invite your friend",
        onConfirm: () {},
        confirmText: "OK",
        cancelText: "Close",
        contentWidget: const [
          Text("You do not have any friends to invite yet."),
        ],
      );
      return;
    }

    final Set<int> tempSelectedFriendUserIds = {..._selectedFriendUserIds};

    await showAppActionDialog(
      context: context,
      title: "Invite your friend",
      confirmText: "Done",
      cancelText: "Cancel",
      onConfirm: () {
        if (!mounted) return;
        setState(() {
          _selectedFriendUserIds
            ..clear()
            ..addAll(tempSelectedFriendUserIds);
        });
      },
      contentWidget: [
        Text(
          "Note: Friends will be notified",
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.getSmallTextColor(context),
          ),
        ),
        SizedBox(height: 12.h),
        StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Column(
              children: _friends.map((friend) {
                final otherUserId = _getOtherUserId(friend);
                final otherUser = _friendUsers[otherUserId];
                final displayName = (otherUser?.userName.trim().isNotEmpty ?? false)
                    ? otherUser!.userName
                    : "User $otherUserId";
                final imageUrl = otherUser != null &&
                        otherUser.profilePictureUrl != null &&
                        otherUser.profilePictureUrl!.isNotEmpty
                    ? "$API_URL${otherUser.profilePictureUrl}"
                    : null;
                final isSelected = tempSelectedFriendUserIds.contains(otherUserId);

                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: () {
                      setDialogState(() {
                        if (isSelected) {
                          tempSelectedFriendUserIds.remove(otherUserId);
                        } else {
                          tempSelectedFriendUserIds.add(otherUserId);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFECFDF5)
                            : AppColors.getContainerBoxColor(context),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected
                              ? Colors.green
                              : Theme.of(context).dividerColor.withOpacity(0.15),
                          width: isSelected ? 1.6 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24.r,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                            child: imageUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 22.sp,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  isSelected
                                      ? "Included in this booking"
                                      : "Tap to include this friend",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.getSmallTextColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 26.h,
                            width: 26.w,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.green : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.green
                                    : Theme.of(context).dividerColor.withOpacity(0.35),
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _handleEsewaPayment() async {
    if (!isEsewaSelected) {
      AppFlushbar.info(context, "Please select eSewa");
      return;
    }

    try {
      setState(() {
        isLoading = true;
        loadingText = "Creating booking...";
      });

      final booking = await _bookingService.createBooking(
        eventId: event.eventId,
        totalPeople: 1 + _selectedFriendUserIds.length,
        friendUserIds: _selectedFriendUserIds.toList(),
      );

      setState(() => loadingText = "Preparing payment...");
      final paymentData = await _bookingService.initiateEsewaPayment(
        booking.bookingId,
      );
      debugPrint("paymentUrl: ${paymentData.paymentUrl}");
      debugPrint("formData: ${paymentData.formData}");

      setState(() {
        isLoading = false;
        loadingText = "Processing...";
      });

      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (_) => EsewaWebViewScreen(
            paymentUrl: paymentData.paymentUrl,
            formData: paymentData.formData,
            successUrlPrefix:
                (paymentData.formData['success_url'] ??
                        '$API_URL/bookings/esewa/success')
                    .toString(),
            failureUrlPrefix:
                (paymentData.formData['failure_url'] ??
                        '$API_URL/bookings/esewa/failure')
                    .toString(),
          ),
        ),
      );

      if (!mounted) return;

      if (result?['success'] == true) {
        setState(() {
          isLoading = true;
          loadingText = "Confirming payment...";
        });

        await _bookingService.confirmEsewaSuccess(
          (result?['url'] ?? '').toString(),
        );

        Booking? updatedBooking;

        for (int i = 0; i < 6; i++) {
          if (!mounted) return;
          setState(() => loadingText = "Verifying booking status...");
          await Future.delayed(const Duration(seconds: 2));
          updatedBooking = await _bookingService.getBookingById(
            booking.bookingId,
          );

          if (updatedBooking.status.toLowerCase() == "completed") {
            break;
          }
        }

        if (!mounted) return;
        setState(() {
          isLoading = false;
          loadingText = "Processing...";
        });

        if (updatedBooking != null &&
            updatedBooking.status.toLowerCase() == "completed") {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteName.dashBoardScreen,
            (route) => false,
            arguments: {
              'index': 1,
              'successMessage': _selectedFriendName == null
                  ? 'Event booked successfully'
                  : 'Event booked with $_selectedFriendName',
            },
          );
        } else if (updatedBooking != null &&
            updatedBooking.status.toLowerCase() == "pending") {
          AppFlushbar.info(
            context,
            "Payment received, but verification is still pending",
          );
        } else {
          AppFlushbar.error(
            context,
            "Payment verification failed",
            fallbackMessage: "We couldn't verify your payment. Please try again.",
          );
        }
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          loadingText = "Processing...";
        });

        AppFlushbar.error(
          context,
          "Payment cancelled or failed",
          fallbackMessage: "Payment was cancelled or could not be completed.",
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        loadingText = "Processing...";
      });
      final message = e.toString().contains("Missing eSewa success payload")
          ? "Payment finished, but the success data was missing."
          : "Something went wrong while confirming your payment.";
      AppFlushbar.error(
        context,
        message,
        fallbackMessage: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Proceed to Payment")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _paymentBox(onTap: () {}),
            SizedBox(height: 8.h),
            _inviteFriendBox(),
            SizedBox(height: 8.h),
            _contentBox(
              context,
              heading: "Esewa",
              isSelected: isEsewaSelected,
              onTap: () {
                setState(() {
                  isEsewaSelected = true;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
        child: _priceBottomBar(),
      ),
    );
  }

  Widget _inviteFriendBox() {
    return InkWell(
      onTap: isLoading ? null : _showInviteFriendDialog,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.getContainerBoxColor(context),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 50.h,
              width: 50.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(Icons.group_add_outlined, color: Colors.orange, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Invite your friend",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  if (_selectedFriendName != null)
                    Text(
                      _selectedFriendName!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.getSmallTextColor(context),
                      ),
                    ),
                  if (_selectedFriendUserIds.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _selectedFriendUserIds.take(4).map((friendId) {
                        final friend = _friendUsers[friendId];
                        final displayName = (friend?.userName.trim().isNotEmpty ?? false)
                            ? friend!.userName
                            : "User $friendId";
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 24.sp,
              color: AppColors.getSmallTextColor(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.getContainerBoxColor(context),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    SharedRes.strings(context).totalPrice,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.getSmallTextColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    event.price.toString(),
                    // AppFormatters.formatPrice(event.price),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            SizedBox(
              width: 160.w,
              height: 54.h,
              child: AppButton(
                onPressed: isLoading ? null : _handleEsewaPayment,
                text: isLoading ? loadingText : SharedRes.strings(context).bookNow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentBox({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.getContainerBoxColor(context),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 60.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6EE),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(Icons.backpack, color: Colors.green, size: 28.sp),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "RS ${event.price.toString()}",
                              style: TextStyle(
                                color: AppColors.getRichTextColor(context),
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: "/person",
                              style: TextStyle(
                                color: AppColors.getSmallTextColor(context),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "Basic Details",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 22.h),

            Text(
              "Essential Material for this trip:",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (event.whatToBring.isNotEmpty)
                  ? event.whatToBring
                        .map((item) => checklistItem(context, item))
                        .toList()
                  : [checklistItem(context, "No checklist available")],
            ),
          ],
        ),
      ),
    );
  }

  Widget checklistItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20.h,
            width: 20.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: Colors.green),
              color: const Color(0xFFECFDF5),
            ),
            child: const Icon(Icons.check, size: 14, color: Colors.green),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.4,
                color: AppColors.getSmallTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _contentBox(
  BuildContext context, {
  required String heading,
  required VoidCallback onTap,
  required bool isSelected,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: AppColors.getContainerBoxColor(context),
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(
        color: Theme.of(context).dividerColor.withOpacity(0.08),
      ),
      boxShadow: [
        BoxShadow(
          blurRadius: 10,
          offset: const Offset(0, 4),
          color: Colors.black.withOpacity(0.05),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Row(
              children: [
                Image.asset("assets/images/esewa.png", height: 24.h),

                SizedBox(width: 8.w),

                Expanded(
                  child: Text(
                    heading,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Radio<bool>(
                  value: true,
                  groupValue: isSelected, // pass this from parent
                  onChanged: (_) => onTap(),
                  activeColor: AppColors.getIconColors(context),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
