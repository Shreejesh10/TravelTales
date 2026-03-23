import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/pending_company_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/actionDialogBox.dart';
import 'package:traveltales/core/ui/components/textField/commonTextField.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _rejectTextEditingController =
  TextEditingController();

  late Future<List<PendingCompany>> _futureCompanies;

  @override
  void initState() {
    super.initState();
    _futureCompanies = getPendingCompanies();
  }

  @override
  void dispose() {
    _rejectTextEditingController.dispose();
    super.dispose();
  }

  Future<void> _reloadPendingCompanies() async {
    setState(() {
      _futureCompanies = getPendingCompanies();
    });
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  Future<void> _approveCompany(int userId) async {
    try {
      await approveCompany(userId);

      if (!mounted) return;

      Navigator.pushNamed(context, RouteName.adminDashboardScreen);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Company approved successfully"),
        ),
      );

      await _reloadPendingCompanies();
    } catch (e) {
      if (!mounted) return;

      Navigator.pushNamed(context, RouteName.adminDashboardScreen);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to approve company: $e"),
        ),
      );
    }
  }

  Future<void> _rejectCompany(int userId) async {
    final reason = _rejectTextEditingController.text.trim();

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter rejection reason"),
        ),
      );
      return;
    }

    try {
      await rejectCompany(userId, reason);

      if (!mounted) return;

      Navigator.pushNamed(context, RouteName.adminDashboardScreen);
      _rejectTextEditingController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Company rejected successfully"),
        ),
      );

      await _reloadPendingCompanies();
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to reject company: $e"),
        ),
      );
    }
  }

  void _showApproveDialog(PendingCompany company) {
    showAppActionDialog(
      context: context,
      title: "Are you sure?",
      onConfirm: () async {
        await _approveCompany(company.userId);
      },
      contentWidget: [
        Text(
          "This action will approve ${company.userName}'s company request.",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getSmallTextColor(context),
          ),
        ),
      ],
    );
  }

  void _showRejectDialog(PendingCompany company) {
    _rejectTextEditingController.clear();

    showAppActionDialog(
      context: context,
      title: "You want to reject the company",
      onConfirm: () async {
        await _rejectCompany(company.userId);
      },
      contentWidget: [
        CommonTextField(
          controller: _rejectTextEditingController,
          labelText: "Reason to reject the company",
          hintText: "Reason to reject the company",
          keyboardType: TextInputType.text,
          maxLines: 2,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.getContainerBoxColor(context),
            border: Border.all(
              color: AppColors.getBorderColor(context),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Divider(
                height: 1,
                color: AppColors.getBorderColor(context),
              ),
              Expanded(
                child: FutureBuilder<List<PendingCompany>>(
                  future: _futureCompanies,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: TextStyle(
                            color: AppColors.getSmallTextColor(context),
                          ),
                        ),
                      );
                    }

                    final companies = snapshot.data ?? [];

                    if (companies.isEmpty) {
                      return Center(
                        child: Text(
                          "No pending companies found",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.getSmallTextColor(context),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: companies.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: AppColors.getBorderColor(context),
                      ),
                      itemBuilder: (context, index) {
                        final company = companies[index];
                        return _buildCompanyRow(company);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "Company Name",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "User ID",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Registered At",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "Email address",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Accept or Reject",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyRow(PendingCompany company) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _buildAvatar(company),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "@${company.userName.toLowerCase().replaceAll(' ', '')}",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getSmallTextColor(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              company.userId.toString(),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getSmallTextColor(context),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(company.registeredAt),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getSmallTextColor(context),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              company.email,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getSmallTextColor(context),
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => _showApproveDialog(company),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.done,
                      size: 20,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _showRejectDialog(company),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(PendingCompany company) {
    final String firstLetter =
    company.userName.isNotEmpty ? company.userName[0].toUpperCase() : "?";

    return CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFFE9D7FE),
      child: Text(
        firstLetter,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF7F56D9),
        ),
      ),
    );
  }
}