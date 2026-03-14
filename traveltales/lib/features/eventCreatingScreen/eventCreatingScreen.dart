import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/button.dart';
import 'package:traveltales/core/ui/components/functions/dateTime/datePickerFunction.dart';
import 'package:traveltales/core/ui/components/searchField.dart';
import 'package:traveltales/core/ui/components/textField/commonTextField.dart';
import 'package:traveltales/core/ui/components/viewAllRow.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

import '../../core/model/event_create_model.dart';

class EventCreatingScreen extends StatefulWidget {
  const EventCreatingScreen({super.key});

  @override
  State<EventCreatingScreen> createState() => _EventCreatingScreenState();
}

class _EventCreatingScreenState extends State<EventCreatingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _meetingPointController = TextEditingController();
  final TextEditingController _whatToBringController = TextEditingController();
  final TextEditingController _maxPeopleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _meetingTimeController = TextEditingController();


  DateTime? _fromDate;
  DateTime? _toDate;
  TimeOfDay? _meetingTime;


  List<Destination> _searchedDestinations = [];
  Destination? _selectedDestination;
  bool _isSearching = false;
  bool _isCreatingEvent = false;



  Future<void> _pickFromDate() async {
    final picked = await pickDate(context);

    if (picked != null) {
      setState(() {
        _fromDate = picked;
        _fromDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await pickDate(context);

    if (picked != null) {
      setState(() {
        _toDate = picked;
        _toDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }
  Future<void> _pickMeetingTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _meetingTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return child!;
      },
    );

    if (picked != null) {
      setState(() {
        _meetingTime = picked;
        _meetingTimeController.text = picked.format(context);
      });
    }
  }

  Future<void> _searchDestination(String value) async {
    final query = value.trim();

    if (query.isEmpty || query.length < 2) {
      setState(() {
        _searchedDestinations = [];
        _isSearching = false;
        _selectedDestination = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _selectedDestination = null;
    });

    try {
      final result = await searchDestination(query);

      setState(() {
        _searchedDestinations = result;
      });
    } catch (e) {
      debugPrint("Search error: $e");
      setState(() {
        _searchedDestinations = [];
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _selectDestination(Destination destination) {
    setState(() {
      _selectedDestination = destination;
      _searchController.text = destination.placeName;
      _searchedDestinations = [];
      _isSearching = false;
    });
  }

  Future<void> _handleCreateEvent() async {
    if (_selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a destination")),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter event title")),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter event description")),
      );
      return;
    }

    if (_meetingPointController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter meeting point")),
      );
      return;
    }

    if (_whatToBringController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter what to bring")),
      );
      return;
    }

    if (_fromDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select from date")),
      );
      return;
    }

    if (_toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select to date")),
      );
      return;
    }

    if (_priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter price")),
      );
      return;
    }

    if (_maxPeopleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter maximum people")),
      );
      return;
    }

    final double? price = double.tryParse(_priceController.text.trim());
    final int? maxPeople = int.tryParse(_maxPeopleController.text.trim());

    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Price must be a valid number")),
      );
      return;
    }

    if (maxPeople == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum people must be a valid number")),
      );
      return;
    }

    if (_toDate!.isBefore(_fromDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("To date cannot be before from date")),
      );
      return;
    }
    if (_meetingTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select meeting time")),
      );
      return;
    }

    try {
      setState(() {
        _isCreatingEvent = true;
      });
      final String formattedMeetingTime =
          "${_meetingTime!.hour.toString().padLeft(2, '0')}:"
          "${_meetingTime!.minute.toString().padLeft(2, '0')}:00";

      final List<String> whatToBringList = _whatToBringController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();

      final event = EventCreateModel(
        destinationId: _selectedDestination!.destinationId,
        title: _titleController.text.trim(),
        eventDescription: _descriptionController.text.trim(),
        fromDate: _fromDate!,
        toDate: _toDate!,
        meetingPoint: _meetingPointController.text.trim(),
        whatToBring: whatToBringList,
        maxPeople: maxPeople,
        price: price,
        meetingTime: formattedMeetingTime,
      );

      await createEvent(event);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event created successfully")),
      );

      Navigator.pushNamed(context, RouteName.companyDashboardScreen, arguments: 1);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create event: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingEvent = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _meetingPointController.dispose();
    _whatToBringController.dispose();
    _maxPeopleController.dispose();
    _priceController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    _meetingTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: compactDimens.extraLarge,
        leading: Padding(
          padding: EdgeInsets.only(left: compactDimens.small3),
          child: Image.asset(
            Theme.of(context).brightness == Brightness.dark
                ? 'assets/images/MountainDark.png'
                : 'assets/images/Mountain.png',
            height: compactDimens.medium2,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, size: compactDimens.medium1),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
        children: [
          Text("Plan Amazing", style: _headingStyle()),
          Text("Adventure For", style: _headingStyle()),
          Row(
            children: [
              Text("Explorers!", style: _headingStyle()),
              SizedBox(width: compactDimens.small1),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.asset(
                  'assets/images/CreatingEventImage.jpg',
                  height: 34.h,
                  width: compactDimens.homeScreenImageSize,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          Row(
            children: [
              Expanded(
                child: SearchFilterBar(
                  controller: _searchController,
                  onChanged: _searchDestination,
                  isFilter: false,
                ),
              ),
              SizedBox(width: 4.w),
              IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchedDestinations = [];
                    _selectedDestination = null;
                  });
                },
                icon: Icon(Icons.close, size: 24.sp),
              ),
            ],
          ),

          if (_isSearching) ...[
            SizedBox(height: 12.h),
            const Center(child: CircularProgressIndicator()),
          ],

          if (_searchedDestinations.isNotEmpty &&
              _selectedDestination == null) ...[
            SizedBox(height: 12.h),
            _searchResultBox(),
          ],

          if (_selectedDestination != null) ...[
            SizedBox(height: 12.h),
            _contentBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ViewAllRow(
                    firstText: SharedRes.strings(context).selectedDestination,
                    isViewAll: false,
                    onPressed: () {},
                  ),

                  SizedBox(height: 12.h),
                  _selectedDestinationCard(_selectedDestination!),
                ],
              ),
            ),
          ],

          SizedBox(height: 12.h),
          _contentBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ViewAllRow(
                  firstText: SharedRes.strings(context).eventInformation,
                  isViewAll: false,
                  onPressed: () {},
                ),
                SizedBox(height: compactDimens.small1),
                Text(
                  "Fill in the main information for your event.",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12.h),

                CommonTextField(
                  controller: _titleController,
                  labelText: SharedRes.strings(context).enterEventTitle,
                  hintText: SharedRes.strings(context).eventTitleHint,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 12.h),

                CommonTextField(
                  controller: _descriptionController,
                  labelText: SharedRes.strings(context).enterEventDescription,
                  hintText: SharedRes.strings(context).eventDescriptionHint,
                  keyboardType: TextInputType.multiline,
                  maxLines: 6,
                ),
                SizedBox(height: 12.h),

                CommonTextField(
                  controller: _meetingPointController,
                  labelText: SharedRes.strings(context).meetingPoint,
                  hintText: SharedRes.strings(context).meetingPointHint,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 12.h),

                CommonTextField(
                  controller: _whatToBringController,
                  labelText: SharedRes.strings(context).whatToBring,
                  hintText: SharedRes.strings(context).whatToBringHint,
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),
          _contentBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ViewAllRow(
                  firstText: SharedRes.strings(context).eventDate,
                  isViewAll: false,
                  onPressed: () {},
                ),
                SizedBox(height: 12.h),

                CommonTextField(
                  controller: _fromDateController,
                  labelText: SharedRes.strings(context).fromDate,
                  hintText: SharedRes.strings(context).fromDate,
                  keyboardType: TextInputType.datetime,
                  readOnly: true,
                  onTap: _pickFromDate,
                  suffixIcon: const Icon(Icons.calendar_month),
                ),
                SizedBox(height: 12.h),

                CommonTextField(
                  controller: _toDateController,
                  labelText: SharedRes.strings(context).toDate,
                  hintText: SharedRes.strings(context).toDate,
                  keyboardType: TextInputType.datetime,
                  readOnly: true,
                  onTap: _pickToDate,
                  suffixIcon: const Icon(Icons.calendar_month),
                ),
                SizedBox(height: 12.h),
                CommonTextField(
                  controller: _meetingTimeController,
                  labelText: "Meeting Time",
                  hintText: "Meeting Time",
                  keyboardType: TextInputType.datetime,
                  readOnly: true,
                  onTap: _pickMeetingTime,
                  suffixIcon: const Icon(Icons.timer_outlined),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),
          _contentBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ViewAllRow(
                  firstText: SharedRes.strings(context).pricingAndCapacity,
                  isViewAll: false,
                  onPressed: () {},
                ),
                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(
                      child: CommonTextField(
                        controller: _priceController,
                        labelText: SharedRes.strings(context).price,
                        hintText: SharedRes.strings(context).enterPrice,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CommonTextField(
                        controller: _maxPeopleController,
                        labelText: SharedRes.strings(context).maximumPeople,
                        hintText: SharedRes.strings(context).enterPeople,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),
          AppButton(
            text: _isCreatingEvent
                ? "Creating..."
                : SharedRes.strings(context).createEvent,
            onPressed: _isCreatingEvent
                ? null
                : () {
              _handleCreateEvent();
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _contentBox({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.getContainerBoxColor(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  TextStyle _headingStyle() {
    return TextStyle(fontSize: 42.sp, height: 1.2);
  }

  Widget _selectedDestinationCard(Destination destination) {
    final String imageUrl =
        "$API_URL${destination.extraInfo.frontImagePath.first}";

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          RouteName.destinationDetailScreen,
          arguments: destination.destinationId,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.containerBoxColor
              : AppColors.darkContainerBoxColor,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                imageUrl,
                height: 100.w,
                width: 85.w,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.placeName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    destination.location,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    destination.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchResultBox() {
    return _contentBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ViewAllRow(
            firstText: "Search Results",
            isViewAll: false,
            onPressed: () {},
          ),
          SizedBox(height: 12.h),

          ..._searchedDestinations.map((destination) {
            final String imageUrl =
                "$API_URL${destination.extraInfo.frontImagePath.first}";

            return InkWell(
              onTap: () => _selectDestination(destination),
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        imageUrl,
                        height: 70.h,
                        width: 72.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destination.placeName,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            destination.location,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.getSmallTextColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),

                          Text(
                            destination.extraInfo.difficultyLevel,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.difficultyColor(
                                destination.extraInfo.difficultyLevel,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
