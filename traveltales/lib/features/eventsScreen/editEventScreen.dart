import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/event_create_model.dart';
import 'package:traveltales/core/model/event_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/app_flushbar.dart';
import 'package:traveltales/core/ui/components/button.dart';
import 'package:traveltales/core/ui/components/functions/dateTime/datePickerFunction.dart';
import 'package:traveltales/core/ui/components/textField/commonTextField.dart';
import 'package:traveltales/core/ui/components/viewAllRow.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key, required this.event});

  final Event event;

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
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
  bool _isUpdatingEvent = false;

  Event get event => widget.event;

  @override
  void initState() {
    super.initState();
    _titleController.text = event.title;
    _descriptionController.text = event.eventDescription;
    _meetingPointController.text = event.meetingPoint;
    _whatToBringController.text = event.whatToBring.join(', ');
    _maxPeopleController.text = event.maxPeople.toString();
    _priceController.text = event.price.toString();
    _fromDate = event.fromDate;
    _toDate = event.toDate;
    _fromDateController.text = _formatInputDate(event.fromDate);
    _toDateController.text = _formatInputDate(event.toDate);
    _meetingTime = _parseMeetingTime(event.meetingTime);
    _meetingTimeController.text = event.meetingTime;
  }

  String _formatInputDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  TimeOfDay? _parseMeetingTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _pickFromDate() async {
    final picked = await pickDate(context);

    if (picked != null) {
      setState(() {
        _fromDate = picked;
        _fromDateController.text = _formatInputDate(picked);
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await pickDate(context);

    if (picked != null) {
      setState(() {
        _toDate = picked;
        _toDateController.text = _formatInputDate(picked);
      });
    }
  }

  Future<void> _pickMeetingTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _meetingTime ?? TimeOfDay.now(),
      builder: (context, child) => child!,
    );

    if (picked != null) {
      setState(() {
        _meetingTime = picked;
        _meetingTimeController.text = picked.format(context);
      });
    }
  }

  Future<void> _handleUpdateEvent() async {
    if (_titleController.text.trim().isEmpty) {
      AppFlushbar.info(context, "Please enter event title");
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      AppFlushbar.info(context, "Please enter event description");
      return;
    }

    if (_meetingPointController.text.trim().isEmpty) {
      AppFlushbar.info(context, "Please enter meeting point");
      return;
    }

    if (_whatToBringController.text.trim().isEmpty) {
      AppFlushbar.info(context, "Please enter what to bring");
      return;
    }

    if (_fromDate == null) {
      AppFlushbar.info(context, "Please select from date");
      return;
    }

    if (_toDate == null) {
      AppFlushbar.info(context, "Please select to date");
      return;
    }

    if (_meetingTime == null) {
      AppFlushbar.info(context, "Please select meeting time");
      return;
    }

    if (_priceController.text.trim().isEmpty) {
      AppFlushbar.info(context, "Please enter price");
      return;
    }

    if (_maxPeopleController.text.trim().isEmpty) {
      AppFlushbar.info(context, "Please enter maximum people");
      return;
    }

    final double? price = double.tryParse(_priceController.text.trim());
    final int? maxPeople = int.tryParse(_maxPeopleController.text.trim());

    if (price == null) {
      AppFlushbar.info(context, "Price must be a valid number");
      return;
    }

    if (maxPeople == null) {
      AppFlushbar.info(context, "Maximum people must be a valid number");
      return;
    }

    if (_toDate!.isBefore(_fromDate!)) {
      AppFlushbar.info(context, "To date cannot be before from date");
      return;
    }

    try {
      setState(() {
        _isUpdatingEvent = true;
      });

      final String formattedMeetingTime =
          "${_meetingTime!.hour.toString().padLeft(2, '0')}:"
          "${_meetingTime!.minute.toString().padLeft(2, '0')}:00";

      final List<String> whatToBringList = _whatToBringController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();

      final updatedEvent = EventCreateModel(
        destinationId: event.destination.destinationId,
        title: _titleController.text.trim(),
        eventDescription: _descriptionController.text.trim(),
        fromDate: _fromDate!,
        toDate: _toDate!,
        meetingTime: formattedMeetingTime,
        meetingPoint: _meetingPointController.text.trim(),
        whatToBring: whatToBringList,
        maxPeople: maxPeople,
        price: price,
      );

      await updateEvent(event.eventId, updatedEvent.toJson());

      if (!mounted) return;
      Navigator.pushNamed(context, RouteName.companyDashboardScreen);
      AppFlushbar.success(context, "Event updated successfully");

    } catch (e) {
      if (!mounted) return;

      AppFlushbar.errorFrom(
        context,
        e,
        fallbackMessage: "Couldn't update the event. Please try again.",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingEvent = false;
        });
      }
    }
  }

  @override
  void dispose() {
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
      appBar: AppBar(title: const Text("Edit Event")),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
        children: [
          SizedBox(height: 12.h),
          _contentBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ViewAllRow(
                  firstText: "Edit Event Info",
                  isViewAll: false,
                  onPressed: null,
                ),
                SizedBox(height: compactDimens.small1),
                Text(
                  "Update the main information for your event.",
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
                const ViewAllRow(
                  firstText: "Event Date",
                  isViewAll: false,
                  onPressed: null,
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
                const ViewAllRow(
                  firstText: "Price and Capacity",
                  isViewAll: false,
                  onPressed: null,
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
            text: _isUpdatingEvent ? "Updating..." : "Update Event",
            onPressed: _isUpdatingEvent ? null : _handleUpdateEvent,
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
}
