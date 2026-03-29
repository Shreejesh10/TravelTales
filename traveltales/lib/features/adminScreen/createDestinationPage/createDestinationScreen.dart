import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/destinationAPI.dart';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/actionDialogBox.dart';
import 'package:traveltales/core/ui/components/button.dart';
import 'package:traveltales/core/ui/components/searchField.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/features/adminScreen/createDestinationPage/createOrEditDialogBox.dart';
import 'package:traveltales/features/adminScreen/createDestinationPage/destinationFormController.dart';

class CreateDestinationScreen extends StatefulWidget {
  const CreateDestinationScreen({super.key});

  @override
  State<CreateDestinationScreen> createState() =>
      _CreateDestinationScreenState();
}

class _CreateDestinationScreenState extends State<CreateDestinationScreen> {
  final form = DestinationFormController();

  List<Destination> _destinations = [];
  bool _isLoadingDestinations = true;
  String? _destinationError;
  bool _isSearching = false;

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    setState(() {
      _isLoadingDestinations = true;
      _destinationError = null;
    });

    try {
      final data = await getAllDestinations();

      if (!mounted) return;

      setState(() {
        _destinations = data;
        _isLoadingDestinations = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _destinationError = e.toString();
        _isLoadingDestinations = false;
      });
    }
  }

  Future<void> _searchDestinations(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      await _loadDestinations();
      return;
    }

    setState(() {
      _isSearching = true;
      _destinationError = null;
    });

    try {
      final data = await searchDestination(trimmedQuery);

      if (!mounted) return;

      setState(() {
        _destinations = data;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _destinationError = e.toString();
        _destinations = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _openAddDestinationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return const CreateOrEditDestinationDialogContent();
      },
    );

    if (result == true) {
      await _loadDestinations();
    }
  }

  Future<void> _openEditDestinationDialog(Destination destination) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CreateOrEditDestinationDialogContent(destination: destination);
      },
    );

    if (result == true) {
      await _loadDestinations();
    }
  }

  Widget _buildBody() {
    if (_isLoadingDestinations || _isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_destinationError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Text(
                "Failed to load destinations",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getSmallTextColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(_destinationError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              AppButton(text: "Retry", onPressed: _loadDestinations),
            ],
          ),
        ),
      );
    }

    if (_destinations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text("No destinations found."),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = (constraints.maxWidth / 220).floor();
        crossAxisCount = crossAxisCount.clamp(1, 5);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _destinations.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            final destination = _destinations[index];
            final extraInfo = destination.extraInfo;
            final bestTime = extraInfo?.bestTimeToVisit ?? "";

            final image =
                destination.extraInfo?.frontImagePath.isNotEmpty == true
                ? destination.extraInfo!.frontImagePath.first
                : destination.extraInfo?.photos.isNotEmpty == true
                ? destination.extraInfo!.photos.first
                : "";

            log("IMAGE URL: $image");

            return _destinationCard(
              context: context,
              destination: destination,
              title: destination.placeName,
              season: bestTime.isNotEmpty ? bestTime : "Best time not set",
              location: destination.location,
              imageUrl: image.startsWith("http") ? image : "$API_URL$image",
              onViewDetails: () {
                Navigator.pushNamed(
                  context,
                  RouteName.adminDestinationDetailScreen,
                  arguments: destination,
                );
              },
              onEdit: () {
                _openEditDestinationDialog(destination);
              },
              onDelete: ()async{
                await deleteDestination(destination.destinationId);
                await _loadDestinations();
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchFilterBar(
              isFilter: false,
              controller: form.search,
              onChanged: (value) {
                _searchDestinations(value);
              },
            ),
            const SizedBox(height: 20),
            AppButton(
              text: "Add New Destination",
              onPressed: _openAddDestinationDialog,
            ),
            const SizedBox(height: 24),
            _buildBody(),
          ],
        ),
      ),
    );
  }
}

Widget _destinationCard({
  required BuildContext context,
  required String title,
  required String season,
  required Destination destination,
  required String location,
  required String imageUrl,
  required VoidCallback onViewDetails,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.getContainerBoxColor(context),
      borderRadius: BorderRadius.circular(10),
    ),
    child: InkWell(
      onTap: onViewDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: AspectRatio(
              aspectRatio: 17 / 12,
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported_outlined),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.getIconColors(context),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        season,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.getIconColors(context),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    editIcon(
                      context: context,
                      icon: Icons.edit,
                      onTap: onEdit,
                      color: Colors.green,
                    ),
                    SizedBox(width: 10),
                    editIcon(
                      context: context,
                      icon: Icons.delete,
                      onTap: () {
                        showAppActionDialog(
                          context: context,
                          title: "Delete Destination?",
                          contentWidget: const [
                            Text("Are you sure you want to delete this destination?"),
                          ],
                          onConfirm: () async {

                            try {
                               onDelete();

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Destination deleted successfully"),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Failed: $e")),
                              );
                            }
                          },
                        );
                      },
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget editIcon({
  required BuildContext context,
  required IconData icon,
  required VoidCallback onTap,
  required color,
}) {
  return Material(
    color: AppColors.getIconColors(context).withOpacity(0.1),
    borderRadius: BorderRadius.circular(18),
    elevation: 0,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 35,
        height: 35,
        alignment: Alignment.center,
        child: Icon(icon, size: 22, color: color),
      ),
    ),
  );
}
