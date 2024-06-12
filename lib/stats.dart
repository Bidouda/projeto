import 'package:flutter/material.dart';
import 'control.dart'; // Import your Control class
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final TextEditingController _yearController = TextEditingController();
  Map<int, int> _monthlyCounts = {};
  double _averageRating = 0.0; // Variable to hold the average rating

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  void _calculateMonthlyCounts() async {
    int year = int.tryParse(_yearController.text) ?? DateTime.now().year;
    Control control = Control();
    await control.startDatabase();

    Map<int, int> counts = {};
    for (int month = 1; month <= 12; month++) {
      int count = await control.countEntradasByMonth(year, month);
      counts[month] = count;
    }

    double averageRating = await control.averageNotasByYear(year); // Calculate the average rating
    setState(() {
      _monthlyCounts = counts;
      _averageRating = averageRating; // Update the average rating state
    });
  }

  double _calculateAverage() {
    if (_monthlyCounts.isEmpty) return 0.0;
    int total = _monthlyCounts.values.fold(0, (sum, count) => sum + count);
    return total / _monthlyCounts.length;
  }

  int _calculateTotal() {
    if (_monthlyCounts.isEmpty) return 0;
    return _monthlyCounts.values.fold(0, (sum, count) => sum + count);
  }

  @override
  Widget build(BuildContext context) {
    List<String> monthNames = DateFormat().dateSymbols.MONTHS; // Get localized month names

    double average = _calculateAverage();
    int totalBooks = _calculateTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  const Text(
                    'Enter Year:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calculateMonthlyCounts,
                    child: const Text('Calculate Stats'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_monthlyCounts.isNotEmpty) ...[
              Text(
                'Average Monthly Books Read: ${average.toStringAsFixed(2)} books',
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 8),
              Text(
                'Average Yearly Rating: ${_averageRating.toStringAsFixed(2)}', // Display the average rating
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              Text(
                'Total Books: $totalBooks',
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 8), // Add some spacing

            ],
            const SizedBox(height: 24),
            Expanded(
              child: _monthlyCounts.isNotEmpty
                  ? BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${monthNames[group.x - 1]}: ${rod.toY.round()} books',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt() - 1;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              monthNames[index].substring(0, 3),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(value.toInt().toString()),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: _monthlyCounts.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.blue,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              )
                  : const Center(
                child: Text(
                  'Enter a year and press "Calculate Stats" to see data',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
