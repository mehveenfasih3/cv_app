import 'package:flutter/material.dart';
import 'package:iris_app/admin_worker.dart';
import 'package:iris_app/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkersManagementScreen extends StatefulWidget {
  final Map<String, dynamic> staffData;
  
  const WorkersManagementScreen({Key? key, required this.staffData}) : super(key: key);

  @override
  State<WorkersManagementScreen> createState() =>
      _WorkersManagementScreenState();
}

class _WorkersManagementScreenState extends State<WorkersManagementScreen> {
  String? selectedSection;
  List<Worker> _workers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  // Load workers from Staff table where role = 4 and manager_id matches
  Future<void> _loadWorkers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final managerId = widget.staffData['staff_id'];
      
      // Fetch workers assigned to this manager
      final response = await Supabase.instance.client
          .from('Staff')
          .select('staff_id, email, password, warehouse_id, created_at')
          .eq('role', 4); // Only workers

      List<Worker> loadedWorkers = [];

      for (var staff in response) {
        final staffId = staff['staff_id'];
        
        // Check if this worker has tasks assigned by this manager
        final assignedTasks = await Supabase.instance.client
            .from('assigned_tasks')
            .select('task_id')
            .eq('staff_id', staffId)
            .eq('manager_id', managerId)
            .limit(1);

        // Only include workers who have tasks from this manager
        if (assignedTasks.isNotEmpty) {
          loadedWorkers.add(Worker(
            id: staff['staff_id'].toString(),
            name: (staff['email'] as String).split('@')[0],
            email: staff['email'] as String,
            phone: '',
            section: staff['warehouse_id']?.toString() ?? 'Not Assigned',
            joinDate: staff['created_at'] != null
                ? DateTime.parse(staff['created_at'] as String)
                : DateTime.now(),
          ));
        }
      }

      setState(() {
        _workers = loadedWorkers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading workers: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _fetchWorkerPerformance(String workerId) async {
    try {
      final managerId = widget.staffData['staff_id'];
      final now = DateTime.now();
      
      // Calculate date ranges
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = today.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      // Format dates
      final todayStr = _formatDate(today);
      final weekStartStr = _formatDate(weekStart);
      final monthStartStr = _formatDate(monthStart);

      // Fetch all tasks assigned by this manager to this worker
      final allTasks = await Supabase.instance.client
          .from('assigned_tasks')
          .select('''
            task_id,
            status,
            schedule_date,
            tasks (
              task_id,
              title
            )
          ''')
          .eq('staff_id', int.parse(workerId))
          .eq('manager_id', managerId);

      // Filter tasks by date ranges
      final dailyTasks = allTasks.where((task) => task['schedule_date'] == todayStr).toList();
      final weeklyTasks = allTasks.where((task) {
        final date = task['schedule_date'];
        return date.compareTo(weekStartStr) >= 0 && date.compareTo(todayStr) <= 0;
      }).toList();
      final monthlyTasks = allTasks.where((task) {
        final date = task['schedule_date'];
        return date.compareTo(monthStartStr) >= 0 && date.compareTo(todayStr) <= 0;
      }).toList();

      return {
        'Daily': _processTaskData(dailyTasks),
        'Weekly': _processTaskData(weeklyTasks),
        'Monthly': _processTaskData(monthlyTasks),
      };
    } catch (e) {
      print('Error fetching performance: $e');
      return {
        'Daily': {'completed': 0, 'pending': 0, 'total': 0, 'incompleteTasks': []},
        'Weekly': {'completed': 0, 'pending': 0, 'total': 0, 'incompleteTasks': []},
        'Monthly': {'completed': 0, 'pending': 0, 'total': 0, 'incompleteTasks': []},
      };
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _processTaskData(List<dynamic> tasks) {
    int completed = 0;
    int pending = 0;
    List<String> incompleteTasks = [];

    for (var task in tasks) {
      final status = (task['status'] ?? 'pending').toString().toLowerCase();
      
      if (status == 'completed') {
        completed++;
      } else {
        pending++;
        final taskData = task['tasks'];
        if (taskData != null && taskData['title'] != null) {
          incompleteTasks.add(taskData['title']);
        }
      }
    }

    return {
      'completed': completed,
      'pending': pending,
      'total': tasks.length,
      'incompleteTasks': incompleteTasks,
    };
  }

  Future<void> _showWorkerPerformanceReport(Worker worker) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );

    final performanceData = await _fetchWorkerPerformance(worker.id);
    
    if (mounted) {
      Navigator.pop(context); // Close loading
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _WorkerPerformanceBottomSheet(
          worker: worker,
          performanceData: performanceData,
        ),
      );
    }
  }

  Future<void> _updateWorker({
    required int staffId,
    required String email,
    String? password,
    required int? warehouseId,
  }) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );

      Map<String, dynamic> updateData = {
        'email': email.trim(),
        'warehouse_id': warehouseId,
      };

      if (password != null && password.isNotEmpty) {
        updateData['password'] = password.trim();
      }

      await Supabase.instance.client
          .from('Staff')
          .update(updateData)
          .eq('staff_id', staffId);

      if (mounted) Navigator.pop(context);

      await _loadWorkers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Worker updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating worker: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteWorker(int staffId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );

      await Supabase.instance.client
          .from('Staff')
          .delete()
          .eq('staff_id', staffId);

      if (mounted) Navigator.pop(context);

      await _loadWorkers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Worker deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting worker: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showEditWorkerDialog(Worker worker) {
    final emailController = TextEditingController(text: worker.email);
    final passwordController = TextEditingController();
    int? selectedWarehouseId = worker.section != 'Not Assigned'
        ? int.tryParse(worker.section)
        : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Worker'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password (leave empty to keep current)',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedWarehouseId,
                  decoration: const InputDecoration(
                    labelText: 'Warehouse',
                    prefixIcon: Icon(Icons.warehouse),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Warehouse 1')),
                    DropdownMenuItem(value: 2, child: Text('Warehouse 2')),
                    DropdownMenuItem(value: 3, child: Text('Warehouse 3')),
                    DropdownMenuItem(value: 4, child: Text('Warehouse 4')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedWarehouseId = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (emailController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _updateWorker(
                    staffId: int.parse(worker.id),
                    email: emailController.text,
                    password: passwordController.text.isNotEmpty
                        ? passwordController.text
                        : null,
                    warehouseId: selectedWarehouseId,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email is required'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteWorker(Worker worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Worker'),
        content: Text('Are you sure you want to delete ${worker.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteWorker(int.parse(worker.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workers Management'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : _workers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No workers found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Workers with assigned tasks will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWorkers,
                  color: AppColors.primaryBlue,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _workers.length,
                    itemBuilder: (context, index) {
                      final worker = _workers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primaryBlue,
                            child: Text(
                              worker.name.isNotEmpty
                                  ? worker.name.substring(0, 1).toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            worker.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.email,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(worker.email)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warehouse,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('Warehouse ${worker.section}'),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'performance') {
                                _showWorkerPerformanceReport(worker);
                              } else if (value == 'edit') {
                                _showEditWorkerDialog(worker);
                              } else if (value == 'delete') {
                                _confirmDeleteWorker(worker);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'performance',
                                child: Row(
                                  children: [
                                    Icon(Icons.bar_chart, color: AppColors.success),
                                    SizedBox(width: 8),
                                    Text('Performance'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: AppColors.primaryBlue),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: AppColors.error),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _WorkerPerformanceBottomSheet extends StatefulWidget {
  final Worker worker;
  final Map<String, dynamic> performanceData;

  const _WorkerPerformanceBottomSheet({
    required this.worker,
    required this.performanceData,
  });

  @override
  State<_WorkerPerformanceBottomSheet> createState() => _WorkerPerformanceBottomSheetState();
}

class _WorkerPerformanceBottomSheetState extends State<_WorkerPerformanceBottomSheet> {
  String _selectedPeriod = 'Daily';

  @override
  Widget build(BuildContext context) {
    final data = widget.performanceData[_selectedPeriod];
    final total = data['total'] as int;
    final completed = data['completed'] as int;
    final completionRate = total > 0
        ? ((completed / total) * 100).toStringAsFixed(1)
        : '0.0';

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryBlue,
                      child: Text(
                        widget.worker.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.worker.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Performance Report',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Period Selector
                    Row(
                      children: [
                        _buildPeriodChip('Daily'),
                        const SizedBox(width: 8),
                        _buildPeriodChip('Weekly'),
                        const SizedBox(width: 8),
                        _buildPeriodChip('Monthly'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Completion Rate
                    Card(
                      elevation: 2,
                      color: AppColors.primaryBlue.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppColors.primaryBlue.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: total > 0 ? completed / total : 0.0,
                                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                color: AppColors.primaryBlue,
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats
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
                    _buildStatCard(
                      'Total Tasks',
                      total.toString(),
                      AppColors.info,
                      Icons.assignment,
                    ),
                    const SizedBox(height: 20),

                    // Incomplete Tasks
                    if ((data['incompleteTasks'] as List).isNotEmpty) ...[
                      const Row(
                        children: [
                          Icon(Icons.list_alt, color: AppColors.warning, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Incomplete Tasks',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warning.withOpacity(0.2),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: List.generate(
                            (data['incompleteTasks'] as List).length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
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
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.celebration, color: AppColors.success, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'All tasks completed! 🎉',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            period,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
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
}