import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/destinationAPI.dart';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/ui/components/actionDialogBox.dart';
import 'package:traveltales/core/ui/components/button.dart';
import 'package:traveltales/core/ui/components/dropDownMenu.dart';
import 'package:traveltales/core/ui/components/searchField.dart';
import 'package:traveltales/core/ui/components/textField/commonTextField.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/features/adminScreen/createDestinationPage/destinationFormController.dart';

class CreateDestinationScreen extends StatefulWidget {
  const CreateDestinationScreen({super.key});

  @override
  State<CreateDestinationScreen> createState() =>
      _CreateDestinationScreenState();
}

class _CreateDestinationScreenState extends State<CreateDestinationScreen> {
  final form = DestinationFormController();

  final ImagePicker _picker = ImagePicker();

  Uint8List? _frontImageBytes;
  Uint8List? _backdropImageBytes;
  String? _frontImageName;
  String? _backdropImageName;

  bool _isSubmitting = false;

  List<Destination> _destinations = [];
  bool _isLoadingDestinations = true;
  String? _destinationError;

  final List<String> _difficultyLevels = ["Easy", "Medium", "Hard"];
  final List<String> _genres = [
    "Hiking",
    "Trekking",
    "Camping",
    "Sunset",
    "Sunrise",
    "Jungle",
    "Mountain",
    "Lakeside",
    "Waterfall",
    "Religious",
    "Wildlife",
    "Rafting",
    "Paragliding",
    "Photography Spot",
  ];

  Set<String> _selectedGenres = {};

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

  Future<void> _pickFrontImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      _frontImageBytes = bytes;
      _frontImageName = picked.name;
    });
  }

  Future<void> _pickBackdropImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      _backdropImageBytes = bytes;
      _backdropImageName = picked.name;
    });
  }

  Future<void> _pickMonth(TextEditingController controller) async {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    final String? selectedMonth = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.getDetailBackgroundColor(dialogContext),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Month",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: months.map((month) {
                    return SizedBox(
                      width: 110,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, month);
                        },
                        child: Text(
                          month,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedMonth != null) {
      controller.text = selectedMonth;
    }
  }

  List<String> _splitCommaValues(String text) {
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<int> _buildGenreVector() {
    return _genres.map((genre) {
      return _selectedGenres.contains(genre) ? 1 : 0;
    }).toList();
  }

  String _buildBestTimeRange() {
    final from = form.bestTimeFrom.text.trim();
    final to = form.bestTimeTo.text.trim();

    if (from.isEmpty && to.isEmpty) return "";
    if (from.isNotEmpty && to.isNotEmpty) return "$from to $to";
    return from.isNotEmpty ? from : to;
  }

  void _clearForm() {
    form.clear();

    _selectedGenres.clear();
    _frontImageBytes = null;
    _backdropImageBytes = null;
    _frontImageName = null;
    _backdropImageName = null;
  }

  Future<void> _submitDestination() async {
    if (form.placeName.text.trim().isEmpty ||
        form.location.text.trim().isEmpty ||
        form.description.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Place name, location and description are required."),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String elevationText = form.elevation.text.trim();
      final int? elevationValue = int.tryParse(
        elevationText.replaceAll(RegExp(r'[^0-9]'), ''),
      );

      final Map<String, dynamic> body = {
        "place_name": form.placeName.text.trim(),
        "location": form.location.text.trim(),
        "description": form.description.text.trim(),
        "extra_info": {
          "highlights": _splitCommaValues(form.highlights.text),
          "attractions": _splitCommaValues(form.attraction.text),
          "best_time_to_visit": _buildBestTimeRange(),
          "transportation": form.transportation.text.trim(),
          "accommodation": form.attraction.text.trim(),
          "safety_tips": _splitCommaValues(form.safetyTips.text),
          "photos": [],
          "genre_vector": _buildGenreVector(),
          "difficulty_level": form.difficulty.text.trim(),
          "duration": form.duration.text.trim(),
          "elevation": elevationValue != null ? [elevationValue] : [],
          "backdrop_path": [],
          "front_image_path": [],
        },
      };

      final Destination? created = await createDestination(body);
      if (created == null) {
        throw Exception("Destination creation failed");
      }

      Destination? latestDestination = created;

      if (_backdropImageBytes != null && _backdropImageName != null) {
        latestDestination = await uploadDestinationBackdropWeb(
          destinationId: created.destinationId,
          bytes: _backdropImageBytes!,
          filename: _backdropImageName!,
        );
      }

      if (_frontImageBytes != null && _frontImageName != null) {
        latestDestination = await uploadDestinationFrontImageWeb(
          destinationId: created.destinationId,
          bytes: _frontImageBytes!,
          filename: _frontImageName!,
        );
      }
      await _loadDestinations();
      if (!mounted) return;

      Navigator.pop(context);
      setState(() {
        _clearForm();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            latestDestination != null
                ? "Destination added successfully"
                : "Destination created, but image upload may have failed",
          ),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add destination: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _openAddDestinationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          child: Container(
            width: 900,
            constraints: const BoxConstraints(maxWidth: 950, maxHeight: 760),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.getDetailBackgroundColor(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Write New Destination Detail",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _uploadImageContainer(
                                context: context,
                                text: "Upload main image",
                                bytes: _frontImageBytes,
                                fileName: _frontImageName,
                                onTap: _pickFrontImage,
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: _uploadImageContainer(
                                context: context,
                                text: "Upload Back Drop Image",
                                bytes: _backdropImageBytes,
                                fileName: _backdropImageName,
                                onTap: _pickBackdropImage,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CommonTextField(
                                controller: form.placeName,
                                labelText: "Place Name",
                                hintText: "eg: Lumbini",
                                keyboardType: TextInputType.name,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CommonTextField(
                                      controller: form.bestTimeFrom,
                                      labelText: "Best time to Visit",
                                      hintText: "From",
                                      keyboardType: TextInputType.datetime,
                                      suffixIcon: const Icon(
                                        Icons.calendar_month,
                                      ),
                                      readOnly: true,
                                      onTap: () =>
                                          _pickMonth(form.bestTimeFrom),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CommonTextField(
                                      controller: form.bestTimeTo,
                                      labelText: "",
                                      hintText: "To",
                                      keyboardType: TextInputType.datetime,
                                      suffixIcon: const Icon(
                                        Icons.calendar_month,
                                      ),
                                      readOnly: true,
                                      onTap: () =>
                                          _pickMonth(form.bestTimeTo),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CommonTextField(
                                controller: form.location,
                                labelText: "Location",
                                hintText: "eg: Lumbini, Nepal",
                                keyboardType: TextInputType.name,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: CommonTextField(
                                controller: form.accommodation,
                                labelText: "Accommodation",
                                hintText: "eg: Hotel, Teahouse",
                                keyboardType: TextInputType.name,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CommonTextField(
                                controller: form.genre,
                                labelText: "Place genre",
                                hintText: "Select genre",
                                keyboardType: TextInputType.name,
                                suffixIcon: const Icon(Icons.chevron_right),
                                readOnly: true,
                                onTap: () {
                                  _selectedGenres =
                                      form.genre.text.isNotEmpty
                                      ? form.genre.text
                                            .split(',')
                                            .map((e) => e.trim())
                                            .where((e) => e.isNotEmpty)
                                            .toSet()
                                      : <String>{};

                                  showAppActionDialog(
                                    context: context,
                                    title: "Choose your destination genre",
                                    onConfirm: () {
                                      setState(() {
                                        form.genre.text = _selectedGenres
                                            .join(", ");
                                      });
                                    },
                                    contentWidget: [
                                      StatefulBuilder(
                                        builder: (context, setInnerState) {
                                          return Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: _genres.map((genre) {
                                              final isSelected = _selectedGenres
                                                  .contains(genre);

                                              return ChoiceChip(
                                                label: Text(genre),
                                                selected: isSelected,
                                                onSelected: (_) {
                                                  setInnerState(() {
                                                    if (_selectedGenres
                                                        .contains(genre)) {
                                                      _selectedGenres.remove(
                                                        genre,
                                                      );
                                                    } else {
                                                      _selectedGenres.add(
                                                        genre,
                                                      );
                                                    }
                                                  });
                                                },
                                                selectedColor:
                                                    AppColors.primaryColor,
                                                backgroundColor:
                                                    AppColors.getContainerBoxColor(
                                                      context,
                                                    ),
                                                labelStyle: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : AppColors.getSmallTextColor(
                                                          context,
                                                        ),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              );
                                            }).toList(),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: CommonTextField(
                                controller: form.attraction,
                                labelText: "Attraction (multiple)",
                                hintText: "Cafes, Stupa, Lake",
                                keyboardType: TextInputType.name,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CommonTextField(
                                controller: form.highlights,
                                labelText: "Highlights (multiple)",
                                hintText: "Atmosphere, Culture, View",
                                keyboardType: TextInputType.name,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: CommonTextField(
                                controller: form.safetyTips,
                                labelText: "Safety Tips (multiple)",
                                hintText: "Watch belongings, stay hydrated",
                                keyboardType: TextInputType.name,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CommonDropDownMenu(
                                controller: form.difficulty,
                                labelText: "Difficulty Level",
                                hintText: "Select difficulty",
                                items: _difficultyLevels,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CommonTextField(
                                controller: form.elevation,
                                labelText: "Elevation",
                                hintText: "eg: 5160m",
                                keyboardType: TextInputType.number,
                                suffixIcon: const Icon(Icons.height),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CommonTextField(
                                controller: form.transportation,
                                labelText: "Transportation",
                                hintText: "eg: bus, jeep, flight",
                                keyboardType: TextInputType.name,
                                suffixIcon: const Icon(Icons.bus_alert),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CommonTextField(
                                controller: form.duration,
                                labelText: "Duration",
                                hintText: "eg: 14-18 days",
                                keyboardType: TextInputType.text,
                                suffixIcon: const Icon(
                                  Icons.access_time_outlined,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        CommonTextField(
                          controller: form.description,
                          labelText: "Description",
                          hintText: "Description of the place",
                          maxLines: 6,
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: 180,
                          child: AppButton(
                            text: _isSubmitting
                                ? "Saving..."
                                : "Add Destination",
                            onPressed: _isSubmitting
                                ? null
                                : _submitDestination,
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
            SearchFilterBar(isFilter: false, controller: form.search),
            const SizedBox(height: 20),
            AppButton(
              text: "Add New Destination",
              onPressed: _openAddDestinationDialog,
            ),
            const SizedBox(height: 24),
            if (_isLoadingDestinations)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_destinationError != null)
              Center(
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
                      Text(
                        _destinationError!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        text: "Retry",
                        onPressed: _loadDestinations,
                      ),
                    ],
                  ),
                ),
              )
            else if (_destinations.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text("No destinations found."),
                  ),
                )
              else
                LayoutBuilder(
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
                          title: destination.placeName,
                          season: bestTime.isNotEmpty ? bestTime : "Best time not set",
                          location: destination.location,
                          imageUrl: "$API_URL$image",
                          onViewDetails: () {},
                        );
                      },
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}

Widget _uploadImageContainer({
  required BuildContext context,
  required String text,
  required VoidCallback onTap,
  Uint8List? bytes,
  String? fileName,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      height: 170,
      decoration: BoxDecoration(
        color: AppColors.getContainerBoxColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: bytes != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    bytes,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      fileName ?? "Selected image",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 40,
                  color: AppColors.getIconColors(context),
                ),
                const SizedBox(height: 10),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    ),
  );
}

Widget _destinationCard({
  required BuildContext context,
  required String title,
  required String season,
  required String location,
  required String imageUrl,
  required VoidCallback onViewDetails,
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
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
