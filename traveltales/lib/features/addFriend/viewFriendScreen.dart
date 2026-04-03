import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/friendsApi.dart';
import 'package:traveltales/core/model/friend_request_model.dart';
import 'package:traveltales/core/model/user_info.dart';
import 'package:traveltales/core/ui/components/actionDialogBox.dart';
import 'package:traveltales/core/ui/components/app_flushbar.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ViewAllFriendScreen extends StatefulWidget {
  const ViewAllFriendScreen({super.key});

  @override
  State<ViewAllFriendScreen> createState() => _ViewAllFriendScreenState();
}

class _ViewAllFriendScreenState extends State<ViewAllFriendScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = true;
  String? _errorMessage;
  List<FriendModel> _friends = [];
  int? _currentUserId;
  final Set<int> _removingFriendIds = {};

  final Map<int, UserInfo> _friendUsers = {};

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userIdString = await _storage.read(key: "user_id");
      final friends = await FriendApi.getFriends();
      final currentUserId = int.tryParse(userIdString ?? "");

      for (final friend in friends) {
        final otherUserId = currentUserId == null
            ? friend.friendUserId
            : (friend.userId == currentUserId
            ? friend.friendUserId
            : friend.userId);

        if (!_friendUsers.containsKey(otherUserId)) {
          try {
            final user = await getUserById(otherUserId);
            _friendUsers[otherUserId] = user;
          } catch (e) {
            debugPrint("Error fetching friend user $otherUserId: $e");
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _currentUserId = currentUserId;
        _friends = friends;
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

  int _getOtherUserId(FriendModel friend) {
    if (_currentUserId == null) {
      return friend.friendUserId;
    }

    return friend.userId == _currentUserId
        ? friend.friendUserId
        : friend.userId;
  }

  Future<void> _removeFriend(FriendModel friend) async {
    final friendUserId = _getOtherUserId(friend);
    final friendName =
        _friendUsers[friendUserId]?.userName?.trim().isNotEmpty == true
            ? _friendUsers[friendUserId]!.userName!.trim()
            : "User";

    setState(() {
      _removingFriendIds.add(friendUserId);
    });

    try {
      await FriendApi.removeFriend(friendUserId: friendUserId);

      if (!mounted) return;

      setState(() {
        _friends.removeWhere(
              (friend) => _getOtherUserId(friend) == friendUserId,
        );
        _friendUsers.remove(friendUserId);
      });

      AppFlushbar.success(context, "$friendName has been removed");
    } catch (e) {
      if (!mounted) return;

      AppFlushbar.errorFrom(
        context,
        e,
        fallbackMessage: "Failed to remove friend.",
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _removingFriendIds.remove(friendUserId);
      });
    }
  }

  void _showRemoveDialog(FriendModel friend, String name) {
    showAppActionDialog(
      context: context,
      title: 'Remove Friend',
      onConfirm: () {
        Navigator.pop(context);
        _removeFriend(friend);
      },
      contentWidget: [
        Text(
          'Are you sure you want to remove $name from your friends?',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Friends'),
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        onRefresh: _loadFriends,
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
              onPressed: _loadFriends,
              child: const Text("Retry"),
            ),
          ),
        ],
      );
    }

    if (_friends.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        children: [
          SizedBox(height: 120.h),
          Icon(
            Icons.people_outline,
            size: 46.sp,
            color: Colors.grey,
          ),
          SizedBox(height: 12.h),
          Text(
            "No friends yet",
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
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        final otherUserId = _getOtherUserId(friend);
        final otherUser = _friendUsers[otherUserId];
        final isRemoving = _removingFriendIds.contains(otherUserId);

        final String imageUrl = otherUser != null &&
            otherUser.profilePictureUrl != null &&
            otherUser.profilePictureUrl!.isNotEmpty
            ? "$API_URL${otherUser.profilePictureUrl}"
            : "";

        final String name = otherUser?.userName ?? "User $otherUserId";

        debugPrint("FRIEND ID: $otherUserId");
        debugPrint("FRIEND NAME: $name");
        debugPrint("FRIEND PROFILE PATH: ${otherUser?.profilePictureUrl}");
        debugPrint("FRIEND FULL IMAGE URL: $imageUrl");

        return _friendCard(
          name: name,
          imageUrl: imageUrl,
          isRemoving: isRemoving,
          onRemove: () {
            _showRemoveDialog(friend, name);
          },
        );
      },
    );
  }

  Widget _friendCard({
    required String name,
    String? imageUrl,
    required bool isRemoving,
    required VoidCallback onRemove,
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
            onPressed: isRemoving ? null : onRemove,
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
            child: isRemoving
                ? SizedBox(
              width: 18.w,
              height: 18.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.red,
              ),
            )
                : Icon(
              Icons.person_remove,
              size: 20.sp,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
