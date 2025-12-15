import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:iris_app/app_colors.dart';
import 'package:iris_app/cerberus.dart';
import 'package:iris_app/custom_drawer.dart';
import 'package:iris_app/cv_scanning.dart';
import 'package:iris_app/performance_report.dart';
import 'package:iris_app/worker_assistant.dart';
import 'package:postgrest/src/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerHomeScreen extends StatefulWidget {
  final PostgrestMap staffData;
  
  const WorkerHomeScreen({Key? key, required this.staffData}) : super(key: key);

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final staffId = widget.staffData['staff_id'];
        final today = DateTime.now();
      final todayDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // Fetch assigned tasks with related data
      final response = await supabase
          .from('assigned_tasks')
          .select('''
            task_id,
            staff_id,
            manager_id,
            section_id,
            status,
            schedule_date,
            allocated_time,
            completion_time,
            tasks (
              task_id,
              title,
              description
            ),
            sections (
              section_id,
              section_title
            )
          ''')
          .eq('staff_id', staffId)
           .eq('schedule_date', todayDate)
          .order('allocated_time', ascending: true);

      setState(() {
        _tasks = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading tasks: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateTaskStatus(String taskId, String staffId, bool isCompleted) async {
    try {
      final newStatus = isCompleted ? 'completed' : 'pending';
      final completionTime = isCompleted ? TimeOfDay.now().format(context) : null;
      
      await supabase
          .from('assigned_tasks')
          .update({
            'status': newStatus,
            'completion_time': completionTime,
          })
          .eq('task_id', taskId)
          .eq('staff_id', staffId);

      // Refresh the task list
      await _fetchTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCompleted ? 'Task marked as completed' : 'Task marked as pending',
            ),
            backgroundColor: isCompleted ? AppColors.success : AppColors.info,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _getTaskStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return 'completed';
      case 'in progress':
        return 'in Progress';
      case 'pending':
      default:
        return 'pending';
    }
  }

  Color _getTaskStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'in_progress':
        return AppColors.info;
      case 'pending':
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffName = widget.staffData['staff_name'] ?? 'Worker';
    final staffEmail = widget.staffData['email'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTasks,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      drawer: CustomDrawer(
       staffData: widget.staffData,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchTasks,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks assigned',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back later for new tasks',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchTasks,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final taskData = _tasks[index];
                          final task = taskData['tasks'];
                          final section = taskData['sections'];
                          final taskStatus = taskData['status'] ?? 'pending';
                          final isCompleted = taskStatus.toLowerCase() == 'completed';
                          
                          // Parse date
                          DateTime? assignedDate;
                          try {
                            assignedDate = DateTime.parse(taskData['scheudule_date']);
                          } catch (e) {
                            assignedDate = DateTime.now();
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Checkbox(
                                value: isCompleted,
                                onChanged: (value) {
                                  _updateTaskStatus(
                                    taskData['task_id'].toString(),
                                    widget.staffData['staff_id'].toString(),
                                    value!,
                                  );
                                },
                                activeColor: AppColors.primaryBlue,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      task?['title'] ?? 'Unknown Task',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getTaskStatusColor(taskStatus)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _getTaskStatusLabel(taskStatus),
                                      style: TextStyle(
                                        color: _getTaskStatusColor(taskStatus),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  if (task?['description'] != null)
                                    Text(
                                      task['description'],
                                      style: TextStyle(
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  if (section != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          section['section_title'] ?? 'Unknown Section',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        taskData['allocated_time'] ?? 'N/A',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${assignedDate.day}/${assignedDate.month}/${assignedDate.year}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (taskData['completion_time'] != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline,
                                          size: 16,
                                          color: AppColors.success,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Completed at: ${taskData['completion_time']}',
                                          style: const TextStyle(
                                            color: AppColors.success,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              trailing: Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isCompleted
                                    ? AppColors.success
                                    : AppColors.mediumGrey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assistant),
            label: 'IRIS AI',
          ),
        ],
        onTap: (index)async {
          final cameras =  await availableCameras();
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CameraPage(cameras: cameras,),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  PerformanceReportScreen(staffData: widget.staffData,),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}