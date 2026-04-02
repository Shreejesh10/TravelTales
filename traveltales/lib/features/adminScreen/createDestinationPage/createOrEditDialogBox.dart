import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/destinationAPI.dart';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/ui/components/actionDialogBox.dart';
import 'package:traveltales/core/ui/components/app_flushbar.dart';
import 'package:traveltales/core/ui/components/button.dart';
import 'package:traveltales/core/ui/components/dropDownMenu.dart';
import 'package:traveltales/core/ui/components/textField/commonTextField.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/features/adminScreen/createDestinationPage/destinationFormController.dart';

class CreateOrEditDestinationDialogContent extends StatefulWidget {
  final Destination? destination;

  const CreateOrEditDestinationDialogContent({
    super.key,
    this.destination,
  });

  bool get isEdit => destination != null;

  @override
  State<CreateOrEditDestinationDialogContent> createState() =>
      _CreateOrEditDestinationDialogContentState();
}

class _CreateOrEditDestinationDialogContentState
    extends State<CreateOrEditDestinationDialogContent> {
  final form = DestinationFormController();
  final ImagePicker _picker = ImagePicker();

  Uint8List? _frontImageBytes;
  Uint8List? _backdropImageBytes;
  String? _frontImageName;
  String? _backdropImageName;
  String? _existingFrontImagePath;
  String? _existingBackdropImagePath;

  bool _isSubmitting = false;

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
  void initState() {
    super.initState();
    _fillFormIfEdit();
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  void _fillFormIfEdit() {
    final d = widget.destination;
    if (d == null) return;

    final extra = d.extraInfo;
    _existingFrontImagePath =
    extra.frontImagePath.isNotEmpty ? extra.frontImagePath.first : null;
    _existingBackdropImagePath =
    extra.backdropPath.isNotEmpty ? extra.backdropPath.first : null;

    form.placeName.text = d.placeName;
    form.location.text = d.location;
    form.description.text = d.description;
    form.transportation.text = extra?.transportation ?? "";
    form.accommodation.text = extra?.accommodation ?? "";
    form.duration.text = extra?.duration ?? "";
    form.difficulty.text = extra?.difficultyLevel ?? "";
    form.highlights.text = (extra?.highlights ?? []).join(", ");
    form.attraction.text = (extra?.attractions ?? []).join(", ");
    form.safetyTips.text = (extra?.safetyTips ?? []).join(", ");

    final elevations = extra?.elevation ?? [];
    if (elevations.isNotEmpty) {
      form.elevation.text = elevations.first.toString();
    }

    final bestTime = (extra?.bestTimeToVisit ?? "").trim();
    if (bestTime.contains(" to ")) {
      final parts = bestTime.split(" to ");
      form.bestTimeFrom.text = parts.isNotEmpty ? parts.first.trim() : "";
      form.bestTimeTo.text = parts.length > 1 ? parts.last.trim() : "";
    } else {
      form.bestTimeFrom.text = bestTime;
      form.bestTimeTo.text = "";
    }

    final genreVector = extra?.genreVector ?? [];
    _selectedGenres.clear();

    for (int i = 0; i < genreVector.length && i < _genres.length; i++) {
      if (genreVector[i] == 1) {
        _selectedGenres.add(_genres[i]);
      }
    }

    form.genre.text = _selectedGenres.join(", ");
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

  Future<void> _submit() async {
    if (form.placeName.text
        .trim()
        .isEmpty ||
        form.location.text
            .trim()
            .isEmpty ||
        form.description.text
            .trim()
            .isEmpty) {
      AppFlushbar.info(
        context,
        "Place name, location and description are required.",
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
      final existingExtra = widget.destination?.extraInfo;

      final Map<String, dynamic> body = {
        "place_name": form.placeName.text.trim(),
        "location": form.location.text.trim(),
        "description": form.description.text.trim(),
        "extra_info": {
          "highlights": _splitCommaValues(form.highlights.text),
          "attractions": _splitCommaValues(form.attraction.text),
          "best_time_to_visit": _buildBestTimeRange(),
          "transportation": form.transportation.text.trim(),
          "accommodation": form.accommodation.text.trim(),
          "safety_tips": _splitCommaValues(form.safetyTips.text),
          "photos": [],
          "genre_vector": _buildGenreVector(),
          "difficulty_level": form.difficulty.text.trim(),
          "duration": form.duration.text.trim(),
          "elevation": elevationValue != null ? [elevationValue] : [],
          "backdrop_path": widget.isEdit
              ? List<String>.from(existingExtra?.backdropPath ?? [])
              : [],
          "front_image_path": widget.isEdit
              ? List<String>.from(existingExtra?.frontImagePath ?? [])
              : [],
        },
      };

      Destination? savedDestination;

      if (widget.isEdit) {
        savedDestination = await updateDestination(
          destinationId: widget.destination!.destinationId,
          body: body,
        );
      } else {
        savedDestination = await createDestination(body);
      }

      if (savedDestination == null) {
        throw Exception(
          widget.isEdit
              ? "Destination update failed"
              : "Destination creation failed",
        );
      }

      if (_backdropImageBytes != null && _backdropImageName != null) {
        savedDestination = await uploadDestinationBackdropWeb(
          destinationId: savedDestination.destinationId,
          bytes: _backdropImageBytes!,
          filename: _backdropImageName!,
        );
      }

      if (_frontImageBytes != null && _frontImageName != null) {
        savedDestination = await uploadDestinationFrontImageWeb(
          destinationId: savedDestination!.destinationId,
          bytes: _frontImageBytes!,
          filename: _frontImageName!,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);

      AppFlushbar.success(
        context,
        widget.isEdit
            ? "Destination updated successfully"
            : "Destination added successfully",
      );
    } catch (e) {
      if (!mounted) return;
      AppFlushbar.errorFrom(
        context,
        e,
        fallbackMessage: widget.isEdit
            ? "Couldn't update the destination. Please try again."
            : "Couldn't add the destination. Please try again.",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, color: Colors.red,),

                ),

                Expanded(
                  child: Center(
                    child: Text(
                      widget.isEdit
                          ? "Edit Destination Detail"
                          : "Write New Destination Detail",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
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
                            existingImagePath: _existingFrontImagePath,
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
                            existingImagePath: _existingBackdropImagePath,
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
                                  suffixIcon: const Icon(Icons.calendar_month),
                                  readOnly: true,
                                  onTap: () => _pickMonth(form.bestTimeFrom),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CommonTextField(
                                  controller: form.bestTimeTo,
                                  labelText: "",
                                  hintText: "To",
                                  keyboardType: TextInputType.datetime,
                                  suffixIcon: const Icon(Icons.calendar_month),
                                  readOnly: true,
                                  onTap: () => _pickMonth(form.bestTimeTo),
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
                              _selectedGenres = form.genre.text.isNotEmpty
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
                                    form.genre.text =
                                        _selectedGenres.join(", ");
                                  });
                                },
                                contentWidget: [
                                  StatefulBuilder(
                                    builder: (context, setInnerState) {
                                      return Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _genres.map((genre) {
                                          final isSelected =
                                          _selectedGenres.contains(genre);

                                          return ChoiceChip(
                                            label: Text(genre),
                                            selected: isSelected,
                                            onSelected: (_) {
                                              setInnerState(() {
                                                if (_selectedGenres.contains(
                                                  genre,
                                                )) {
                                                  _selectedGenres.remove(genre);
                                                } else {
                                                  _selectedGenres.add(genre);
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
                            suffixIcon:
                            const Icon(Icons.access_time_outlined),
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
                            ? (widget.isEdit ? "Updating..." : "Saving...")
                            : (widget.isEdit
                            ? "Update Destination"
                            : "Add Destination"),
                        onPressed: _isSubmitting ? null : _submit,
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

  Widget _uploadImageContainer({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
    Uint8List? bytes,
    String? fileName,
    String? existingImagePath,
  }) {
    final imageUrl = existingImagePath == null || existingImagePath.isEmpty
        ? null
        : existingImagePath.startsWith('http')
        ? existingImagePath
        : '$API_URL$existingImagePath';

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
        child: bytes != null || imageUrl != null
            ? Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: bytes != null
                  ? Image.memory(
                bytes,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              )
                  : Image.network(
                imageUrl!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported),
                  );
                },
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
                  fileName ??
                      (imageUrl != null ? "Current image" : "Selected image"),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
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
}
