import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/user_info.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/actionDialogBox.dart';
import 'package:traveltales/core/ui/components/app_flushbar.dart';
import 'package:traveltales/core/ui/components/textField/commonTextField.dart';
import 'package:traveltales/core/ui/components/textField/emailTextField.dart';
import 'package:traveltales/core/ui/components/textField/passwordTextField.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? userError;
  bool isLoading = false;
  UserInfo? me;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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


  Future<void> _updateUser({String? name, String? email}) async {
    setState(() {
      isLoading = true;
    });

    try {
      await updateUser(
        userName: name ?? _nameController.text.trim(),
        email: email ?? _emailController.text.trim(),
      );
      await _loadUser();

      if (!mounted) return;

      await logout();

      AppFlushbar.success(context, "Profile updated successfully");
    } catch (e) {
      if (!mounted) return;

      AppFlushbar.errorFrom(
        context,
        e,
        fallbackMessage: "Failed to update profile.",
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  Future<void> _changePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPass = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      AppFlushbar.info(context, "All fields are required");
      return;
    }

    if (newPass.length < 6) {
      AppFlushbar.info(context, "Password must be at least 6 characters");
      return;
    }

    if (newPass != confirm) {
      AppFlushbar.info(context, "Passwords do not match");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await changePassword(
        currentPassword: current,
        newPassword: newPass,
      );

      if (!mounted) return;

      Navigator.pop(context);

      AppFlushbar.success(context, "Password changed successfully");


      await logout(); //logout after password Change

    } catch (e) {
      if (!mounted) return;

      AppFlushbar.errorFrom(
        context,
        e,
        fallbackMessage: "Failed to change password.",
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Setting')),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        children: [
          _settingsTile(
            icon: Icons.drive_file_rename_outline,
            title: "Change Name",
            onTap: () {
              _nameController.text = me!.userName;
              showAppActionDialog(
                context: context,
                title: "Change Name",
                onConfirm: () {
                  final name = _nameController.text.trim();

                  if (name.isEmpty) {
                    AppFlushbar.info(context, "Name cannot be empty");
                    return;
                  }

                  _updateUser(name: name);
                },
                contentWidget: [
                  CommonTextField(
                    controller: _nameController,
                    labelText: "Change Name",
                    hintText: "Enter your new name",
                    keyboardType: TextInputType.text,
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 8.h),
          _settingsTile(
            icon: Icons.attach_email_outlined,
            title: "Change Email",
            onTap: () {
              _emailController.text = me!.email;
              showAppActionDialog(
                context: context,
                title: "Change Email",
                onConfirm: () {
                  final email = _emailController.text.trim();

                  if (email.isEmpty || !email.contains("@")) {
                    AppFlushbar.info(context, "Enter a valid email");
                    return;
                  }

                  _updateUser(email: email);
                },
                contentWidget: [
                  EmailTextField(
                    controller: _emailController,
                    labelText: "Change Email",
                    hintText: SharedRes.strings(context).enterEmail,

                  ),
                ],
              );
            },
          ),
          SizedBox(height: 8.h),
          _settingsTile(
            icon: Icons.password,
            title: SharedRes.strings(context).changePassword,
            onTap: () {
              showAppActionDialog(
                context: context,
                title: SharedRes.strings(context).changePassword,
                contentWidget: [
                  PasswordTextField(
                    controller: _currentPasswordController,
                    labelText: SharedRes.strings(context).password,
                  ),
                  SizedBox(height: 8.h),
                  PasswordTextField(
                    controller: _passwordController,
                    labelText: SharedRes.strings(context).password,
                  ),
                  SizedBox(height: 8.h),
                  PasswordTextField(
                    controller: _confirmPasswordController,
                    labelText: SharedRes.strings(context).confirmPassword,
                  ),
                ],
                onConfirm: _changePassword,
              );
            },
          ),

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
            Icon(Icons.arrow_forward, size: 14.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
