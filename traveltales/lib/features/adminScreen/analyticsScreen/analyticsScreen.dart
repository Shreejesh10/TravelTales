import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/bookingAPI.dart';
import 'package:traveltales/api/destinationAPI.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';

import 'package:traveltales/core/model/event_model.dart';
import 'package:traveltales/core/model/booking_model.dart';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/model/user_info.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  String? _error;

  int ongoingEvents = 0;
  int totalBookedEvents = 0;
  int totalDestinations = 0;
  int totalEvents = 0;

  List<_TopCompanyData> topCompanies = [];
  List<_TopEventData> topBookedEvents = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final List<Event> events = await getAllEvents();
      final List<Destination> destinations = await getAllDestinations();
      final List<UserInfo> users = await getAllUsers();
      final bookingApi = BookingApi();
      final List<Booking> bookings = await bookingApi.getAllBookings();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final int ongoingCount = events.where((event) {
        final eventEnd = DateTime(
          event.toDate.year,
          event.toDate.month,
          event.toDate.day,
        );
        return !eventEnd.isBefore(today);
      }).length;

      final int bookedCount = bookings.length;
      final int destinationCount = destinations.length;
      final int totalEventCount = events.length;

      final Map<int, int> bookingCountByEventId = {};

      for (final booking in bookings) {
        bookingCountByEventId[booking.eventId] =
            (bookingCountByEventId[booking.eventId] ?? 0) + 1;
      }

      final List<_TopEventData> topEvents =
      bookingCountByEventId.entries.map((entry) {
        final int eventId = entry.key;
        final int bookingCount = entry.value;

        final Event? matchedEvent = _findEventById(events, eventId);
        final destination = matchedEvent?.destination;
        final imagePath = destination != null &&
                destination.extraInfo.backdropPath.isNotEmpty
            ? destination.extraInfo.backdropPath.first
            : '';

        return _TopEventData(
          eventId: eventId,
          title: matchedEvent?.title ?? 'Unknown Event',
          destinationName: destination?.placeName ?? 'Unknown Destination',
          imageUrl: imagePath.isNotEmpty
              ? (imagePath.startsWith('http') ? imagePath : '$API_URL$imagePath')
              : '',
          difficultyText: destination?.extraInfo.difficultyLevel ?? 'Normal',
          totalBookings: bookingCount,
        );
      }).toList();

      topEvents.sort((a, b) => b.totalBookings.compareTo(a.totalBookings));

      final Map<String, int> companyEventCount = {};

      for (final event in events) {
        final String ownerKey = event.companyUserId.toString();
        companyEventCount[ownerKey] =
            (companyEventCount[ownerKey] ?? 0) + 1;
      }

      final List<_TopCompanyData> companies =
      companyEventCount.entries.map((entry) {
        final String companyId = entry.key;
        final int eventCount = entry.value;

        final UserInfo? matchedUser = _findUserById(users, companyId);

        return _TopCompanyData(
          id: companyId,
          name: matchedUser?.userName ?? 'Unknown User',
          email: matchedUser?.email ?? '',
          imageUrl: matchedUser?.profilePictureUrl ?? '',
          totalEvents: eventCount,
        );
      }).toList();

      companies.sort((a, b) => b.totalEvents.compareTo(a.totalEvents));

      if (!mounted) return;

      setState(() {
        ongoingEvents = ongoingCount;
        totalBookedEvents = bookedCount;
        totalDestinations = destinationCount;
        totalEvents = totalEventCount;
        topBookedEvents = topEvents.take(5).toList();
        topCompanies = companies.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Event? _findEventById(List<Event> events, int eventId) {
    try {
      return events.firstWhere((event) => event.eventId == eventId);
    } catch (_) {
      return null;
    }
  }

  UserInfo? _findUserById(List<UserInfo> users, String userId) {
    try {
      return users.firstWhere((user) => user.id.toString() == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null && !_isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Failed to load some analytics data',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              Wrap(
                spacing: 18,
                runSpacing: 18,
                children: _isLoading
                    ? [
                  _analyticsCardShimmer(context),
                  _analyticsCardShimmer(context),
                  _analyticsCardShimmer(context),
                  _analyticsCardShimmer(context),
                ]
                    : [
                  _analyticsCard(
                    context,
                    title: "Ongoing Events",
                    value: ongoingEvents.toString(),
                  ),
                  _analyticsCard(
                    context,
                    title: "Total Booked Events",
                    value: totalBookedEvents.toString(),
                  ),
                  _analyticsCard(
                    context,
                    title: "Total Destinations",
                    value: totalDestinations.toString(),
                  ),
                  _analyticsCard(
                    context,
                    title: "Total Events",
                    value: totalEvents.toString(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _isLoading
                            ? _bigChartShimmer(context)
                            : Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                            AppColors.getContainerBoxColor(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Company Report",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  _filterChip("12 Months",
                                      isSelected: true),
                                  const SizedBox(width: 8),
                                  _filterChip("6 Months"),
                                  const SizedBox(width: 8),
                                  _filterChip("30 Days"),
                                  const SizedBox(width: 8),
                                  _filterChip("7 Days"),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 260,
                                child: LineChart(
                                  LineChartData(
                                    minX: 0,
                                    maxX: 11,
                                    minY: 0,
                                    maxY: 100,
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 20,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Colors.grey
                                              .withOpacity(0.15),
                                          strokeWidth: 1,
                                        );
                                      },
                                    ),
                                    titlesData: FlTitlesData(
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: false),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: false),
                                      ),
                                      leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 1,
                                          reservedSize: 28,
                                          getTitlesWidget:
                                              (value, meta) {
                                            const months = [
                                              "Feb",
                                              "Mar",
                                              "Apr",
                                              "May",
                                              "Jun",
                                              "Jul",
                                              "Aug",
                                              "Sep",
                                              "Oct",
                                              "Nov",
                                              "Dec",
                                              "Jan",
                                            ];

                                            final index = value.toInt();
                                            if (index < 0 ||
                                                index >=
                                                    months.length) {
                                              return const SizedBox
                                                  .shrink();
                                            }

                                            return Padding(
                                              padding:
                                              const EdgeInsets.only(
                                                  top: 8),
                                              child: Text(
                                                months[index],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors
                                                      .getSmallTextColor(
                                                      context),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData:
                                    FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: const [
                                          FlSpot(0, 14),
                                          FlSpot(1, 18),
                                          FlSpot(2, 15),
                                          FlSpot(3, 24),
                                          FlSpot(4, 22),
                                          FlSpot(5, 31),
                                          FlSpot(6, 29),
                                          FlSpot(7, 27),
                                          FlSpot(8, 30),
                                          FlSpot(9, 28),
                                          FlSpot(10, 36),
                                          FlSpot(11, 37),
                                        ],
                                        isCurved: true,
                                        color: const Color(0xff11A8FD),
                                        barWidth: 2,
                                        dotData: const FlDotData(
                                            show: false),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: const Color(0xff11A8FD)
                                              .withOpacity(0.08),
                                        ),
                                      ),
                                      LineChartBarData(
                                        spots: const [
                                          FlSpot(0, 12),
                                          FlSpot(1, 10),
                                          FlSpot(2, 16),
                                          FlSpot(3, 15),
                                          FlSpot(4, 19),
                                          FlSpot(5, 21),
                                          FlSpot(6, 18),
                                          FlSpot(7, 20),
                                          FlSpot(8, 19),
                                          FlSpot(9, 23),
                                          FlSpot(10, 22),
                                          FlSpot(11, 48),
                                        ],
                                        isCurved: true,
                                        color: const Color(0xff008CFF),
                                        barWidth: 2,
                                        dotData: FlDotData(
                                          show: true,
                                          checkToShowDot:
                                              (spot, barData) {
                                            return spot.x == 4;
                                          },
                                          getDotPainter: (spot, percent,
                                              barData, index) {
                                            return FlDotCirclePainter(
                                              radius: 4,
                                              color:
                                              const Color(0xff1E293B),
                                              strokeWidth: 2,
                                              strokeColor: Colors.white,
                                            );
                                          },
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: const Color(0xffF3E7E1)
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                    lineTouchData: LineTouchData(
                                      touchTooltipData:
                                      LineTouchTooltipData(
                                        getTooltipColor: (_) =>
                                        Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        _isLoading
                            ? _companyCardShimmer(context)
                            : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                            AppColors.getContainerBoxColor(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Company with Most Events",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Company with most event posted",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.getSmallTextColor(
                                      context),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (topCompanies.isEmpty)
                                const Text("No company data found")
                              else
                                ...topCompanies.map(
                                      (company) => _companyRow(
                                    context,
                                    imageUrl: company.imageUrl,
                                    name: company.name,
                                    email: company.email,
                                    value:
                                    company.totalEvents.toString(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    flex: 1,
                    child: _isLoading
                        ? _topEventsCardShimmer(context)
                        : Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.getContainerBoxColor(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Top Booked Events",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (topBookedEvents.isEmpty)
                            const Text("No booking data found")
                          else
                            ...topBookedEvents.map(
                                  (event) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _bookedEventsCard(
                                  context,
                                  imageAsset: event.imageUrl,
                                  title: event.destinationName,
                                  organizerText:
                                      "Booked ${event.totalBookings} times",
                                  difficultyText: event.difficultyText,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _analyticsCard(
      BuildContext context, {
        required String title,
        required String value,
      }) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getContainerBoxColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getSmallTextColor(context),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _analyticsCardShimmer(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getContainerBoxColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBox(width: 110, height: 14),
            const SizedBox(height: 14),
            _shimmerBox(width: 60, height: 24),
          ],
        ),
      ),
    );
  }

  Widget _bigChartShimmer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getContainerBoxColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _shimmerBox(width: 150, height: 22),
                const Spacer(),
                _shimmerBox(width: 70, height: 28),
                const SizedBox(width: 8),
                _shimmerBox(width: 70, height: 28),
                const SizedBox(width: 8),
                _shimmerBox(width: 70, height: 28),
                const SizedBox(width: 8),
                _shimmerBox(width: 70, height: 28),
              ],
            ),
            const SizedBox(height: 24),
            _shimmerBox(width: double.infinity, height: 260, radius: 10),
          ],
        ),
      ),
    );
  }

  Widget _companyCardShimmer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getContainerBoxColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBox(width: 190, height: 20),
            const SizedBox(height: 8),
            _shimmerBox(width: 170, height: 12),
            const SizedBox(height: 20),
            ...List.generate(
              4,
                  (index) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 18, backgroundColor: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmerBox(width: 120, height: 14),
                          const SizedBox(height: 6),
                          _shimmerBox(width: 150, height: 12),
                        ],
                      ),
                    ),
                    _shimmerBox(width: 28, height: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topEventsCardShimmer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getContainerBoxColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBox(width: 140, height: 20),
            const SizedBox(height: 24),
            ...List.generate(
              5,
                  (index) => Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Row(
                  children: [
                    Expanded(
                      child: _shimmerBox(width: double.infinity, height: 14),
                    ),
                    const SizedBox(width: 12),
                    _shimmerBox(width: 30, height: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _filterChip(String text, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        border: Border.all(
          color: isSelected ? Colors.black26 : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _bookedEventsCard(
    BuildContext context, {
    required String imageAsset,
    required String title,
    required String organizerText,
    required String difficultyText,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.containerBoxColor
            : AppColors.darkContainerBoxColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageAsset.isNotEmpty
                ? Image.network(
                    imageAsset,
                    height: 54,
                    width: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Image.asset(
                        "assets/images/Annapurna.png",
                        height: 54,
                        width: 54,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    "assets/images/Annapurna.png",
                    height: 54,
                    width: 54,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      size: 14,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        organizerText,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.difficultyBgColor(difficultyText),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              difficultyText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.difficultyColor(difficultyText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _companyRow(
      BuildContext context, {
        required String imageUrl,
        required String name,
        required String email,
        required String value,
      }) {
    final String resolvedImageUrl = imageUrl.isEmpty
        ? ''
        : imageUrl.startsWith('http')
            ? imageUrl
            : '$API_URL$imageUrl';
    final bool hasValidImage = resolvedImageUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: hasValidImage ? NetworkImage(resolvedImageUrl) : null,
            child: !hasValidImage
                ? const Icon(Icons.person, size: 18)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getSmallTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopCompanyData {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final int totalEvents;

  _TopCompanyData({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.totalEvents,
  });
}

class _TopEventData {
  final int eventId;
  final String title;
  final String destinationName;
  final String imageUrl;
  final String difficultyText;
  final int totalBookings;

  _TopEventData({
    required this.eventId,
    required this.title,
    required this.destinationName,
    required this.imageUrl,
    required this.difficultyText,
    required this.totalBookings,
  });
}
