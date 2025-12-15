import 'package:flutter/material.dart';
import 'package:iris_app/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerformanceReportScreen extends StatefulWidget {
  final Map<String, dynamic> staffData;
  
  const PerformanceReportScreen({Key? key, required this.staffData}) : super(key: key);

  @override
  State<PerformanceReportScreen> createState() =>
      _PerformanceReportScreenState();
}

class _PerformanceReportScreenState extends State<PerformanceReportScreen> {
  final supabase = Supabase.instance.client;
  String _selectedPeriod = 'Daily';
  bool _isLoading = true;
  String? _errorMessage;
  
  Map<String, Map<String, dynamic>> _performanceData = {
    'Daily': {
      'completed': 0,
      'pending': 0,
      'total': 0,
      'incompleteTasks': [],
    },
    'Weekly': {
      'completed': 0,
      'pending': 0,
      'total': 0,
      'incompleteTasks': [],
    },
    'Monthly': {
      'completed': 0,
      'pending': 0,
      'total': 0,
      'incompleteTasks': [],
    },
  };

  @override
  void initState() {
    super.initState();
    _fetchPerformanceData();
  }

  Future<void> _fetchPerformanceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final staffId = widget.staffData['staff_id'];
      final now = DateTime.now();

      // Calculate date ranges
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = today.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      // Format dates for SQL query
      final todayStr = _formatDate(today);
      final weekStartStr = _formatDate(weekStart);
      final monthStartStr = _formatDate(monthStart);

      // Fetch daily tasks
      final dailyTasks = await supabase
          .from('assigned_tasks')
          .select('''
            task_id,
            status,
            tasks (
              task_id,
              title
            )
          ''')
          .eq('staff_id', staffId)
          .eq('schedule_date', todayStr);

      // Fetch weekly tasks
      final weeklyTasks = await supabase
          .from('assigned_tasks')
          .select('''
            task_id,
            status,
            tasks (
              task_id,
              title
            )
          ''')
          .eq('staff_id', staffId)
          .gte('schedule_date', weekStartStr)
          .lte('schedule_date', todayStr);

      // Fetch monthly tasks
      final monthlyTasks = await supabase
          .from('assigned_tasks')
          .select('''
            task_id,
            status,
            tasks (
              task_id,
              title
            )
          ''')
          .eq('staff_id', staffId)
          .gte('schedule_date', monthStartStr)
          .lte('schedule_date', todayStr);

      setState(() {
        _performanceData = {
          'Daily': _processTaskData(dailyTasks),
          'Weekly': _processTaskData(weeklyTasks),
          'Monthly': _processTaskData(monthlyTasks),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading performance data: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _processTaskData(List<dynamic> tasks) {
    int completed = 0;
    int pending = 0;
    int inProgress = 0;
    List<String> incompleteTasks = [];

    for (var task in tasks) {
      final status = (task['status'] ?? 'pending').toString().toLowerCase();
      
      if (status == 'completed') {
        completed++;
      } else {
        if (status == 'pending') {
          pending++;
        } else if (status == 'in_progress') {
          inProgress++;
        }
        
        // Add to incomplete tasks list
        final taskData = task['tasks'];
        if (taskData != null && taskData['title'] != null) {
          incompleteTasks.add(taskData['title']);
        }
      }
    }

    return {
      'completed': completed,
      'pending': pending + inProgress,
      'total': tasks.length,
      'incompleteTasks': incompleteTasks,
      'onTime': completed, // You can add more logic here for late tasks if needed
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Performance Report'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Performance Report'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchPerformanceData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _performanceData[_selectedPeriod]!;
    final total = data['total'] as int;
    final completed = data['completed'] as int;
    final completionRate = total > 0
        ? ((completed / total) * 100).toStringAsFixed(1)
        : '0.0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPerformanceData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPerformanceData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                        value: total > 0 ? completed / total : 0.0,
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
                      completed.toString(),
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
                      total.toString(),
                      AppColors.info,
                      Icons.assignment,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'On Time',
                      data['onTime'].toString(),
                      AppColors.primaryBlue,
                      Icons.schedule,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Incomplete Tasks
              if ((data['incompleteTasks'] as List).isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
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
                          (data['incompleteTasks'] as List).length,
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
                                    (data['incompleteTasks'] as List)[index],
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
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.celebration,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'All tasks completed! 🎉',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildPeriodChip(String period) {
    final isSelected = _selectedPeriod == period;
    final periodData = _performanceData[period]!;
    final total = periodData['total'] as int;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                period,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$total tasks',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? AppColors.white.withOpacity(0.8) : AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
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