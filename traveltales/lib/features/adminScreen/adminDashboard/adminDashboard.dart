import 'package:flutter/material.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/actionDialogBox.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/features/adminScreen/analyticsScreen/analyticsScreen.dart';
import 'package:traveltales/features/adminScreen/createDestinationPage/createDestinationScreen.dart';
import 'package:traveltales/features/adminScreen/userManagement/userManagement.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int selectedIndex = 0;

  Future<void> logout() async {
    await logoutAndClearAuth();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AuthRouteName.loginScreen,
          (route) => false,
    );
  }

  final List<String> menuItems = [
    "Analytics Dashboard",
    "User Management",
    "Create Destination",
  ];

  Widget _buildPageContent() {
    switch (selectedIndex) {
      case 0:
        return const AnalyticsScreen();
      case 1:
        return const UserManagementScreen();
      case 2:
        return const CreateDestinationScreen();
      default:
        return const AnalyticsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.containerBoxColor,
              border: Border(
                right: BorderSide(color: AppColors.getBorderColor(context)),
              ),

            ),
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "TravelTales",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // MENU
                ...List.generate(menuItems.length, (index) {
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        menuItems[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.getSmallTextColor(context),
                        ),
                      ),
                    ),
                  );
                }),

                const Spacer(),

                // ADMIN SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Admin",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextButton.icon(
                    onPressed: () {
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
                    icon: const Icon(Icons.logout, size: 18, color: Colors.red),
                    label: const Text(
                      "Log out",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.getDetailBackgroundColor(context),
                    border: Border(
                      bottom: BorderSide(color: AppColors.getBorderColor(context)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        menuItems[selectedIndex],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    color: AppColors.getDetailBackgroundColor(context),
                    child: _buildPageContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


