import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/notification/notificationService.dart';
import 'package:traveltales/core/model/user_info.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _isCheckingAuth = false;
  bool _isLoggedIn = false;

  String? _role;
  String? _userId;
  String? _errorMessage;
  bool _hasCompletedPreference = false;

  UserInfo? _userInfo;

  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  bool get isLoggedIn => _isLoggedIn;
  String? get role => _role;
  String? get userId => _userId;
  String? get errorMessage => _errorMessage;
  bool get hasCompletedPreference => _hasCompletedPreference;
  UserInfo? get userInfo => _userInfo;

  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await login(email, password);

      _role = result["roles"]?.toString();
      _hasCompletedPreference = result["has_completed_preference"] == true;
      _userId = await getUserId();

      if (_isCompanyUser) {
        _userInfo = await fetchMeUserInfo();
        final blockedMessage = _companyLoginBlockMessage(_userInfo?.status);
        if (blockedMessage != null) {
          await _clearPersistedAuthState();
          _clearLocalState();
          _errorMessage = blockedMessage;
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        try {
          _userInfo = await fetchMeUserInfo();
        } catch (_) {
          _userInfo = null;
        }
      }

      _isLoggedIn = true;
      await NotificationService.instance.onUserAuthenticated();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      _isLoggedIn = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    _isCheckingAuth = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'access_token');
      final storedRole = await _storage.read(key: 'roles');
      final storedUserId = await _storage.read(key: 'user_id');
      final storedPreference = await _storage.read(key: 'has_completed_preference');

      if (token != null && token.isNotEmpty) {
        _role = storedRole;
        _userId = storedUserId;
        _hasCompletedPreference = storedPreference == "true";
        if (_isCompanyUser) {
          try {
            _userInfo = await fetchMeUserInfo();
            if (_companyLoginBlockMessage(_userInfo?.status) != null) {
              await _clearPersistedAuthState();
              _clearLocalState();
            } else {
              _isLoggedIn = true;
              await NotificationService.instance.onUserAuthenticated();
            }
          } catch (e) {
            _errorMessage = e.toString().replaceFirst("Exception: ", "");
            _clearLocalState();
          }
        } else {
          _isLoggedIn = true;
          await NotificationService.instance.onUserAuthenticated();
        }
      } else {
        _clearLocalState();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      _clearLocalState();
    }

    _isCheckingAuth = false;
    notifyListeners();
  }

  Future<void> refreshMe() async {
    try {
      _userInfo = await fetchMeUserInfo();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
    }
  }

  Future<void> logoutUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      await NotificationService.instance.onUserLoggedOut();
      await logoutAndClearAuth();
      await _storage.delete(key: 'user_id');
      await _storage.delete(key: 'roles');
      await _storage.delete(key: 'has_completed_preference');
      _clearLocalState();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool get _isCompanyUser => _role?.toLowerCase().trim() == "company";

  String? _companyLoginBlockMessage(String? status) {
    final normalizedStatus = status?.trim().toLowerCase();
    if (normalizedStatus == "pending" || normalizedStatus == "unverified") {
      return "Your company is not verified yet. Please wait for admin verification.";
    }
    if (normalizedStatus == "rejected") {
      return "Your company verification was rejected. Please contact the admin.";
    }
    return null;
  }

  Future<void> _clearPersistedAuthState() async {
    await NotificationService.instance.onUserLoggedOut();
    await logoutAndClearAuth();
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'roles');
    await _storage.delete(key: 'has_completed_preference');
  }

  void _clearLocalState() {
    _isLoggedIn = false;
    _role = null;
    _userId = null;
    _userInfo = null;
    _hasCompletedPreference = false;
  }
}
