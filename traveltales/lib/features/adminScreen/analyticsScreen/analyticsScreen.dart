import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 18,
              runSpacing: 18,
              children: [
                _analyticsCard(
                  context,
                  title: "Ongoing Events",
                  value: "126",
                  percentage: "+36%",
                ),
                _analyticsCard(
                  context,
                  title: "Total Booked Events",
                  value: "13",
                  percentage: "+14%",
                ),
                _analyticsCard(
                  context,
                  title: "Total Destinations",
                  value: "1394",
                  percentage: "-56%",
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
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.getContainerBoxColor(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        ///Line Graph
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
                                _filterChip("12 Months", isSelected: true),
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
                                        color: Colors.grey.withOpacity(0.15),
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        reservedSize: 28,
                                        getTitlesWidget: (value, meta) {
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
                                              index >= months.length) {
                                            return const SizedBox.shrink();
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: Text(
                                              months[index],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                AppColors.getSmallTextColor(
                                                  context,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
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
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: const Color(
                                          0xff11A8FD,
                                        ).withOpacity(0.08),
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
                                        checkToShowDot: (spot, barData) {
                                          return spot.x == 4;
                                        },
                                        getDotPainter:
                                            (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: const Color(0xff1E293B),
                                            strokeWidth: 2,
                                            strokeColor: Colors.white,
                                          );
                                        },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: const Color(
                                          0xffF3E7E1,
                                        ).withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipColor: (_) => Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.getContainerBoxColor(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                color: AppColors.getSmallTextColor(context),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _companyRow(
                              context,
                              imageUrl:
                              'assets/images/Annapurna.png',
                              name: 'Jerry Wilson',
                              email: 'j.watson@example.com',
                              value: '234',
                            ),
                            _companyRow(
                              context,
                              imageUrl:
                              'assets/images/Annapurna.png',
                              name: 'Devon Lane',
                              email: 'dat.roberts@example.com',
                              value: '159',
                            ),
                            _companyRow(
                              context,
                              imageUrl:
                              'assets/images/Annapurna.png',
                              name: 'Jane Cooper',
                              email: 'jgraham@example.com',
                              value: '83',
                            ),
                            _companyRow(
                              context,
                              imageUrl:
                              'assets/images/Annapurna.png',
                              name: 'Dianne Russell',
                              email: 'curtis.d@example.com',
                              value: '81',
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
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.getContainerBoxColor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Top Booked Events",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _eventRow("Tilicho Lake Trek", "382"),
                        _eventRow("Hiking to Jamacho", "974"),
                        _eventRow("Bandipur Sunrise", "211"),
                        _eventRow("Aspire", "893"),
                        _eventRow("Aspire", "893"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _analyticsCard(
      BuildContext context, {
        required String title,
        required String value,
        required String percentage,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                percentage,
                style: TextStyle(
                  color: percentage.contains("+") ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
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

  Widget _eventRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
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

  Widget _companyRow(
      BuildContext context, {
        required String imageUrl,
        required String name,
        required String email,
        required String value,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(imageUrl),
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