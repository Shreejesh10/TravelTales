import 'package:flutter/material.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/destinationAPI.dart';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/features/adminScreen/createDestinationPage/createOrEditDialogBox.dart';

class AdminDestinationDetailScreen extends StatefulWidget {
  final Destination destination;

  const AdminDestinationDetailScreen({
    super.key,
    required this.destination,
  });

  @override
  State<AdminDestinationDetailScreen> createState() =>
      _AdminDestinationDetailScreenState();
}

class _AdminDestinationDetailScreenState
    extends State<AdminDestinationDetailScreen> {
  bool isDescriptionExpanded = false;



  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;
    final extra = destination.extraInfo;
    final frontImage =
    extra.backdropPath.isNotEmpty ? extra.backdropPath.first : "";

    return Scaffold(
      backgroundColor: AppColors.getDetailBackgroundColor(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderBar(context, destination),
                const SizedBox(height: 24),
                _buildMainShowcaseCard(
                  context: context,
                  destination: destination,
                  frontImage: frontImage,
                ),
                const SizedBox(height: 24),
                _buildContentSections(context, destination),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBar(BuildContext context, Destination destination) {
    return Row(
      children: [
        back_icon(
          context: context,
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Destination Details",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: AppColors.getSmallTextColor(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                destination.placeName,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        back_icon(
          context: context,
          icon: Icons.edit_outlined,
          onTap: () async {
            final result = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => CreateOrEditDestinationDialogContent(
                destination: widget.destination,
              ),
            );


          },
        ),
      ],
    );
  }

  Widget _buildMainShowcaseCard({
    required BuildContext context,
    required Destination destination,
    required String frontImage,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.getContainerBoxColor(context),
            AppColors.getContainerBoxColor(context).withOpacity(0.92),
          ],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 12),
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 340,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                    color: Colors.black.withOpacity(0.10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: frontImage.isNotEmpty
                    ? Image.network(
                  "$API_URL$frontImage",
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imageFallback(),
                )
                    : _imageFallback(),
              ),
            ),
            const SizedBox(width: 28),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _badge(
                        context: context,
                        icon: Icons.place_outlined,
                        label: destination.location,
                      ),
                      _badge(
                        context: context,
                        icon: Icons.route_outlined,
                        label: destination.extraInfo.duration.isNotEmpty
                            ? destination.extraInfo.duration
                            : "Duration N/A",
                      ),
                      _badge(
                        context: context,
                        icon: Icons.landscape_outlined,
                        label: destination.extraInfo.elevation.isNotEmpty
                            ? "${destination.extraInfo.elevation.first} m"
                            : "Elevation N/A",
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    destination.placeName,
                    style: TextStyle(
                      fontSize: 34,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "A curated overview of this destination for admin management, review, and quick content verification.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.getSmallTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: AppColors.getDetailBackgroundColor(context),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.04),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Overview",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          destination.description,
                          maxLines: isDescriptionExpanded ? null : 6,
                          overflow: isDescriptionExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.75,
                            color: AppColors.getSmallTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 14),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isDescriptionExpanded = !isDescriptionExpanded;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: Text(
                              isDescriptionExpanded ? "Show less" : "Read more",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.getSmallTextColor(context)
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSections(BuildContext context, Destination destination) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              descriptionBox(
                context: context,
                title: "Highlights",
                icon: Icons.auto_awesome_outlined,
                child: _modernBulletList(destination.extraInfo.highlights),
              ),
              const SizedBox(height: 20),
              descriptionBox(
                context: context,
                title: "Attractions",
                icon: Icons.explore_outlined,
                child: _modernBulletList(destination.extraInfo.attractions),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              descriptionBox(
                context: context,
                title: "Safety Tips",
                icon: Icons.shield_outlined,
                child: _modernBulletList(destination.extraInfo.safetyTips),
              ),
              const SizedBox(height: 20),
              descriptionBox(
                context: context,
                title: "Travel Information",
                icon: Icons.map_outlined,
                child: Column(
                  children: [
                    _infoLine(
                      context,
                      "Transportation",
                      destination.extraInfo.transportation,
                    ),
                    _divider(),
                    _infoLine(
                      context,
                      "Accommodation",
                      destination.extraInfo.accommodation,
                    ),
                    _divider(),
                    _infoLine(
                      context,
                      "Best Time to Visit",
                      destination.extraInfo.bestTimeToVisit,
                    ),
                    _divider(),
                    _infoLine(
                      context,
                      "Duration",
                      destination.extraInfo.duration,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget back_icon({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.getContainerBoxColor(context),
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 22,
            color: AppColors.getIconColors(context),
          ),
        ),
      ),
    );
  }

  Widget _badge({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.getDetailBackgroundColor(context),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.getIconColors(context),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget descriptionBox({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.getContainerBoxColor(context),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.getDetailBackgroundColor(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }

  Widget _modernBulletList(List<String> items) {
    if (items.isEmpty) {
      return const Text("N/A");
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.75),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.7,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _infoLine(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "N/A",
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.getSmallTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 24,
      thickness: 1,
      color: Colors.black.withOpacity(0.05),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 44,
      ),
    );
  }
}
