import 'package:flutter/material.dart';
import 'package:iris_app/app_colors.dart';

class PerformanceReportScreen extends StatefulWidget {
  const PerformanceReportScreen({Key? key}) : super(key: key);

  @override
  State<PerformanceReportScreen> createState() =>
      _PerformanceReportScreenState();
}

class _PerformanceReportScreenState extends State<PerformanceReportScreen> {
  String _selectedPeriod = 'Daily';

  final Map<String, Map<String, dynamic>> _performanceData = {
    'Daily': {
      'completed': 8,
      'pending': 2,
      'total': 10,
      'incompleteTasks': ['Load Warehouse C', 'Package Sorting'],
    },
    'Weekly': {
      'completed': 45,
      'pending': 5,
      'total': 50,
      'incompleteTasks': [
        'Inventory Audit',
        'Deep Cleaning',
        'Equipment Check',
        'Safety Inspection',
        'Report Submission'
      ],
    },
    'Monthly': {
      'completed': 180,
      'pending': 20,
      'total': 200,
      'incompleteTasks': [
        'Monthly Report',
        'Equipment Maintenance',
        'Training Session',
        'Quality Check',
        'Documentation Update'
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final data = _performanceData[_selectedPeriod]!;
    final completionRate =
        ((data['completed'] / data['total']) * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Period Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    _buildPeriodChip('Daily'),
                    const SizedBox(width: 8),
                    _buildPeriodChip('Weekly'),
                    const SizedBox(width: 8),
                    _buildPeriodChip('Monthly'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Performance Overview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '$completionRate%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const Text(
                      'Completion Rate',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: data['completed'] / data['total'],
                      backgroundColor: AppColors.lightGrey,
                      color: AppColors.primaryBlue,
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    data['completed'].toString(),
                    AppColors.success,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    data['pending'].toString(),
                    AppColors.warning,
                    Icons.pending,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Tasks',
                    data['total'].toString(),
                    AppColors.info,
                    Icons.assignment,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'On Time',
                    '${data['completed'] - 2}',
                    AppColors.primaryBlue,
                    Icons.schedule,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Incomplete Tasks
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.list_alt,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Incomplete Tasks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      data['incompleteTasks'].length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                data['incompleteTasks'][index],
                                style: const TextStyle(fontSize: 15),
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

  Widget _buildPeriodChip(String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            period,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}