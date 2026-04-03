import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/friendsApi.dart';
import 'package:traveltales/core/model/friend_request_model.dart';
import 'package:traveltales/core/model/user_info.dart';
import 'package:traveltales/core/ui/components/app_flushbar.dart';
import 'package:traveltales/core/ui/components/searchField.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<UserInfo> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounce;
  int? _currentUserId;
  Set<int> _friendUserIds = {};
  Map<int, FriendRequestModel> _outgoingPendingRequests = {};

  final Set<int> _sendingRequests = {};
  final Set<int> _cancellingRequests = {};

  @override
  void initState() {
    super.initState();
    _loadFriendState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchUsers();
    });
  }

  Future<void> _loadFriendState() async {
    try {
      final userIdString = await _storage.read(key: "user_id");
      final currentUserId = int.tryParse(userIdString ?? "");
      final results = await Future.wait([
        FriendApi.getFriends(),
        FriendApi.getOutgoingFriendRequests(),
      ]);
      final friends = results[0] as List<FriendModel>;
      final outgoingRequests = results[1] as List<FriendRequestModel>;

      final friendIds = friends.map((friend) {
        if (currentUserId == null) {
          return friend.friendUserId;
        }

        return friend.userId == currentUserId
            ? friend.friendUserId
            : friend.userId;
      }).toSet();

      final outgoingPendingRequests = <int, FriendRequestModel>{};
      for (final request in outgoingRequests) {
        if (request.status.toLowerCase() == "pending") {
          outgoingPendingRequests[request.receiverId] = request;
        }
      }

      if (!mounted) return;

      setState(() {
        _currentUserId = currentUserId;
        _friendUserIds = friendIds;
        _outgoingPendingRequests = outgoingPendingRequests;
      });
    } catch (_) {
      // If friend ids fail to load, keep search usable rather than blocking UI.
    }
  }

  Future<void> _searchUsers() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _users = [];
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await searchUsers(query);

      if (!mounted) return;

      setState(() {
        _users = users.where((user) {
          final isCurrentUser = _currentUserId != null && user.id == _currentUserId;
          final isAlreadyFriend = _friendUserIds.contains(user.id);
          return !isCurrentUser && !isAlreadyFriend;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _sendFriendRequest(int receiverId) async {
    setState(() {
      _sendingRequests.add(receiverId);
    });

    try {
      await FriendApi.sendFriendRequest(receiverId: receiverId);

      if (!mounted) return;

      await _loadFriendState();
      if (!mounted) return;

      AppFlushbar.success(context, "Friend request sent");
    } catch (e) {
      if (!mounted) return;

      AppFlushbar.errorFrom(
        context,
        e,
        fallbackMessage: "Failed to send friend request.",
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _sendingRequests.remove(receiverId);
      });
    }
  }

  Future<void> _cancelFriendRequest(int receiverId) async {
    final request = _outgoingPendingRequests[receiverId];
    if (request == null) return;

    setState(() {
      _cancellingRequests.add(receiverId);
    });

    try {
      await FriendApi.cancelFriendRequest(requestId: request.id);

      if (!mounted) return;

      setState(() {
        _outgoingPendingRequests.remove(receiverId);
      });

      AppFlushbar.success(context, "Friend request removed");
    } catch (e) {
      if (!mounted) return;

      AppFlushbar.errorFrom(
        context,
        e,
        fallbackMessage: "Failed to remove friend request.",
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _cancellingRequests.remove(receiverId);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Friend"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            SearchFilterBar(
              hintText: "Search Friend Username",
              isFilter: false,
              onTap: () {},
              controller: _searchController,
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      return Center(
        child: Text(
          "Search users by username",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey,
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!.replaceFirst("Exception: ", ""),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.red,
          ),
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Text(
          "No users found",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];

        final String imageUrl = user.profilePictureUrl != null &&
            user.profilePictureUrl!.isNotEmpty
            ? "$API_URL${user.profilePictureUrl}"
            : "";

        debugPrint("PROFILE PATH: ${user.profilePictureUrl}");
        debugPrint("FULL PROFILE URL: $imageUrl");


        return _friendCard(
          name: user.userName ?? "Unknown User",
          imageUrl: imageUrl,
          isSending: _sendingRequests.contains(user.id),
          isPending: _outgoingPendingRequests.containsKey(user.id),
          isCancelling: _cancellingRequests.contains(user.id),
          onAdd: () => _sendFriendRequest(user.id),
          onRemoveRequest: () => _cancelFriendRequest(user.id),
        );
      },
    );
  }

  Widget _friendCard({
    required String name,
    required String imageUrl,
    required bool isSending,
    required bool isPending,
    required bool isCancelling,
    required VoidCallback onAdd,
    required VoidCallback onRemoveRequest,
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
          ClipOval(
            child: SizedBox(
              width: 48.w,
              height: 48.w,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint("USER IMAGE ERROR: $error");
                  debugPrint("USER IMAGE URL: $imageUrl");

                  return Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      size: 22.sp,
                      color: Colors.grey,
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.person,
                  size: 22.sp,
                  color: Colors.grey,
                ),
              ),
            ),
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
          InkWell(
            onTap: isSending || isCancelling
                ? null
                : (isPending ? onRemoveRequest : onAdd),
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: isPending
                    ? Colors.red.withOpacity(0.12)
                    : AppColors.getContainerBoxColor(context),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: isSending || isCancelling
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isPending ? Colors.red : AppColors.getIconColors(context),
                      ),
                    )
                  : Icon(
                      isPending ? Icons.person_remove : Icons.person_add,
                      size: 20.sp,
                      color: isPending ? Colors.red : AppColors.getIconColors(context),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
