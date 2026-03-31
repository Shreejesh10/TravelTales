import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/friendsApi.dart';
import 'package:traveltales/core/model/friend_request_model.dart';
import 'package:traveltales/core/model/user_info.dart';
import 'package:traveltales/core/ui/components/actionDialogBox.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';

class AcceptFriendScreen extends StatefulWidget {
  const AcceptFriendScreen({super.key});

  @override
  State<AcceptFriendScreen> createState() => _AcceptFriendScreenState();
}

class _AcceptFriendScreenState extends State<AcceptFriendScreen> {
  bool _isLoading = true;
  final Map<int, UserInfo> _users = {};
  String? _errorMessage;
  List<FriendRequestModel> _requests = [];
  final Set<int> _processingRequestIds = {};

  @override
  void initState() {
    super.initState();
    _loadIncomingRequests();
  }

  Future<void> _loadIncomingRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requests = await FriendApi.getIncomingFriendRequests();

      if (!mounted) return;

      final pendingRequests =
      requests.where((r) => r.status == "pending").toList();

      for (final req in pendingRequests) {
        if (!_users.containsKey(req.senderId)) {
          try {
            final user = await getUserById(req.senderId);
            _users[req.senderId] = user;
          } catch (e) {
            debugPrint("Error fetching user ${req.senderId}: $e");
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _requests = pendingRequests;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  Future<void> _acceptFriendRequest(int requestId) async {
    setState(() {
      _processingRequestIds.add(requestId);
    });

    try {
      await FriendApi.acceptFriendRequest(requestId: requestId);

      if (!mounted) return;

      setState(() {
        _requests.removeWhere((request) => request.id == requestId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Friend request accepted"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _processingRequestIds.remove(requestId);
      });
    }
  }

  void _showAcceptDialog(FriendRequestModel request) {
    showAppActionDialog(
      context: context,
      title: 'Accept Friend Request',
      onConfirm: () {
        Navigator.pop(context);
        _acceptFriendRequest(request.id);
      },
      contentWidget: [
        Text(
          'Are you sure you want to accept this friend request?',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Pending"),
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        onRefresh: _loadIncomingRequests,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        children: [
          SizedBox(height: 120.h),
          Icon(
            Icons.error_outline,
            size: 42.sp,
            color: Colors.red,
          ),
          SizedBox(height: 12.h),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: ElevatedButton(
              onPressed: _loadIncomingRequests,
              child: const Text("Retry"),
            ),
          ),
        ],
      );
    }

    if (_requests.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        children: [
          SizedBox(height: 120.h),
          Icon(
            Icons.person_add_disabled_outlined,
            size: 46.sp,
            color: Colors.grey,
          ),
          SizedBox(height: 12.h),
          Text(
            "No pending requests",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          final user = _users[request.senderId];
          final isProcessing = _processingRequestIds.contains(request.id);

          final String imageUrl = user != null &&
              user.profilePictureUrl != null &&
              user.profilePictureUrl!.isNotEmpty
              ? "$API_URL${user.profilePictureUrl}"
              : "";

          return _friendCard(
            name: user?.userName ?? "User ${request.senderId}",
            imageUrl: imageUrl,
            isProcessing: isProcessing,
            onAccept: () => _showAcceptDialog(request),
          );
        }
    );
  }

  Widget _friendCard({
    required String name,
    String? imageUrl,
    required bool isProcessing,
    required VoidCallback onAccept,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.getContainerBoxColor(context),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                ? NetworkImage(imageUrl)
                : null,
            child: (imageUrl == null || imageUrl.isEmpty)
                ? Icon(
              Icons.person,
              size: 22.sp,
              color: Colors.grey,
            )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: isProcessing ? null : onAccept,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 8.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              backgroundColor: AppColors.getContainerBoxColor(context),
              elevation: 0,
            ),
            child: isProcessing
                ? SizedBox(
              width: 18.w,
              height: 18.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.green,
              ),
            )
                : Icon(
              Icons.person_add_rounded,
              size: 20.sp,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}