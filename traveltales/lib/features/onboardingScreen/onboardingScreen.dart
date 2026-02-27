import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';

import '../../api/api.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _error;

  List<Map<String, dynamic>> _genres = [];

  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final all = await fetchAllGenres();
      final selected = await fetchUserPreferenceIds();

      setState(() {
        _genres = all;
        _selectedIds
          ..clear()
          ..addAll(selected);
      });
    } catch (e, st) {
      log("Preference load error: $e", stackTrace: st);
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _onNext() async {
    if(_selectedIds.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one category to continue"),
)
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await saveUserPreferencesByIds(_selectedIds.toList());
      if (!mounted) return;
      Navigator.pushNamed(context, RouteName.dashBoardScreen);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/OnboardingImage.png', fit: BoxFit.cover),
            Container(color: cs.secondary.withOpacity(0.25)),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Stack(
                  children: [
                    // Skip
                    Positioned(
                      top: 8.h,
                      right: 0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.r),
                        onTap: () => Navigator.pushNamed(context, RouteName.dashBoardScreen),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          child: Text(
                            "Skip",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Chips
                    Align(
                      alignment: const Alignment(0, -0.12),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 320.w),
                        child: _buildChipArea(theme),
                      ),
                    ),

                    // Bottom
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 22.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              SharedRes.strings(context).selectTheCategories,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontSize: 20.sp,
                                height: 1.25,
                              ),
                            ),
                            SizedBox(height: 14.h),
                            SizedBox(
                              width: double.infinity,
                              height: 52.h,
                              child: ElevatedButton(
                                onPressed: (_loading || _saving) ? null : _onNext,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cs.primary,
                                  foregroundColor: cs.onPrimary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: _saving
                                    ? SizedBox(
                                  width: 18.w,
                                  height: 18.w,
                                  child: const CircularProgressIndicator(strokeWidth: 2),
                                )
                                    : Text(
                                  "Next",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipArea(ThemeData theme) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Failed to load categories\n$_error",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          SizedBox(height: 12.h),
          ElevatedButton(onPressed: _load, child: const Text("Retry")),
        ],
      );
    }

    if (_genres.isEmpty) {
      return Text(
        "No categories found.",
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6.w,
      runSpacing: 7.h,
      children: _genres.map((g) {
        final id = (g["id"] as num).toInt();
        final name = g["name"].toString();
        final isSelected = _selectedIds.contains(id);

        return _CategoryChip(
          label: name,
          selected: isSelected,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedIds.remove(id);
              } else {
                _selectedIds.add(id);
              }
            });
          },
        );
      }).toList(),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color bgSelected = cs.primary;
    final Color bgUnselected =
    isDark ? Colors.white.withOpacity(0.14) : Colors.white.withOpacity(0.72);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: selected ? bgSelected : bgUnselected,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: selected ? Colors.transparent : Colors.white.withOpacity(0.22),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: selected ? cs.onPrimary : cs.secondary,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }
}