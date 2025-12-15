import 'package:flutter/material.dart';
import 'package:iris_app/admin_assistant.dart';
import 'package:iris_app/admin_drawer.dart';
import 'package:iris_app/app_colors.dart';
import 'package:iris_app/assign_task.dart';
import 'package:iris_app/cerberus.dart';
import 'package:iris_app/products.dart';
import 'package:iris_app/worker_management.dart';
import 'package:postgrest/src/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagerHomeScreen extends StatefulWidget {
  final Map<String, dynamic> staffData;
  
  ManagerHomeScreen({Key? key, required this.staffData}) : super(key: key);

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}



class _ManagerHomeScreenState extends State<ManagerHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _workerEmailController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Dynamic lists from database
  List<WorkerTask> _completedTasks = [];
  List<WorkerTask> _inProgressTasks = [];
  bool _isLoadingTasks = false;

  List<Map<String, dynamic>> _sections = [];
  List<Map<String, dynamic>> _tasks = [];
  int? _selectedSectionId;
  String? _selectedSectionTitle;
   String? _selectedtaskId; // CHANGED: String instead of int? _selectedtaskId;
  String? _selectedtaskTitle;
  bool _isLoadingSections = false;
  bool _isLoadingtasks = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSections();
    _loadtasks();
    _loadAssignedTasks(); // Load assigned tasks
  }

  @override
  void dispose() {
    _tabController.dispose();
    _workerEmailController.dispose();
    _sectionController.dispose();
    _taskTitleController.dispose();
    _taskDescController.dispose();
    super.dispose();
  }

  // Load sections from Supabase
  Future<void> _loadSections() async {
    setState(() {
      _isLoadingSections = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('sections')
          .select('section_id, section_title')
          .order('section_title');

      setState(() {
        _sections = List<Map<String, dynamic>>.from(response);
        _isLoadingSections = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSections = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sections: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Load tasks from Supabase
  Future<void> _loadtasks() async {
    setState(() {
      _isLoadingtasks = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('tasks')
          .select('task_id, title')
          .order('title');

      setState(() {
        _tasks = List<Map<String, dynamic>>.from(response);
        _isLoadingtasks = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingtasks = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading tasks: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // NEW: Load assigned tasks from Supabase
  Future<void> _loadAssignedTasks() async {
    setState(() {
      _isLoadingTasks = true;
    });

    try {
      final managerStaffId = widget.staffData['staff_id'] as int;

      // Fetch assigned tasks with joins to get worker name, task title, and section
      final response = await Supabase.instance.client
          .from('assigned_tasks')
          .select('''
            task_id,
            staff_id,
            status,
            schedule_date,
            allocated_time,
            completion_time,
            Staff!assigned_tasks_staff_id_fkey(email),
            tasks!assigned_tasks_task_id_fkey(title),
            sections!assigned_tasks_section_id_fkey(section_title)
          ''')
          .eq('manager_id', managerStaffId);

      // Separate tasks by status
      List<WorkerTask> completed = [];
      List<WorkerTask> inProgress = [];

      for (var task in response) {
        final status = task['status'] as String;
        final workerEmail = task['Staff']['email'] as String;
        final taskTitle = task['tasks']['title'] as String;
        final sectionTitle = task['sections']['section_title'] as String;
        final scheduleDate = task['schedule_date'] != null
            ? DateTime.parse(task['schedule_date'] as String)
            : DateTime.now();

        final workerTask = WorkerTask(
          id: task['task_id'].toString(),
          workerName: workerEmail.split('@')[0], // Extract name from email
          workerEmail: workerEmail,
          taskTitle: taskTitle,
          section: sectionTitle,
          status: status == 'completed' ? 'Completed' : 'In Progress',
          date: scheduleDate,
        );

        if (status == 'completed') {
          completed.add(workerTask);
        } else if (status == 'in_progress' || status == 'pending') {
          inProgress.add(workerTask);
        }
      }

      setState(() {
        _completedTasks = completed;
        _inProgressTasks = inProgress;
        _isLoadingTasks = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTasks = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading assigned tasks: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // UPDATED: Fix the modal with proper task dropdown
  void _showAssignTaskModal() {
    // Reset all fields when modal opens
    _selectedDate = null;
    _selectedTime = null;
    _selectedSectionId = null;
    _selectedSectionTitle = null;
    _selectedtaskId = null;
    _selectedtaskTitle = null;
    _workerEmailController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkCard
                : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.assignment_add,
                          color: AppColors.primaryBlue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Assign New Task',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // FIXED: Task Dropdown
                    // FIXED: Task Dropdown with String type
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedtaskId != null
                            ? AppColors.primaryBlue
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedtaskId,
                      decoration: InputDecoration(
                        labelText: 'Task',
                        hintText: _isLoadingtasks
                            ? 'Loading tasks...'
                            : 'Select Task',
                        prefixIcon: const Icon(
                          Icons.task_alt,
                          color: AppColors.primaryBlue,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                      ),
                      items: _tasks.map((task) {
                        return DropdownMenuItem<String>(
                          value: task['task_id'] as String, // FIXED: Cast to String
                          child: Text(task['title'] as String),
                        );
                      }).toList(),
                      onChanged: _isLoadingtasks
                          ? null
                          : (value) {
                              setModalState(() {
                                _selectedtaskId = value;
                                _selectedtaskTitle = _tasks
                                    .firstWhere((t) => t['task_id'] == value)['title'] as String;
                              });
                            },
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
                      isExpanded: true,
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Worker Email
                  TextField(
                    controller: _workerEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Worker Email',
                      hintText: 'worker@iris.com',
                      prefixIcon: const Icon(Icons.email, color: AppColors.primaryBlue),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedSectionId != null
                            ? AppColors.primaryBlue
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: _selectedSectionId,
                      decoration: InputDecoration(
                        labelText: 'Section',
                        hintText: _isLoadingSections
                            ? 'Loading sections...'
                            : 'Select section',
                        prefixIcon: const Icon(
                          Icons.location_on,
                          color: AppColors.primaryBlue,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                      ),
                      items: _sections.map((section) {
                        return DropdownMenuItem<int>(
                          value: section['section_id'] as int,
                          child: Text(section['section_title'] as String),
                        );
                      }).toList(),
                      onChanged: _isLoadingSections
                          ? null
                          : (value) {
                              setModalState(() {
                                _selectedSectionId = value;
                                _selectedSectionTitle = _sections
                                    .firstWhere((s) => s['section_id'] == value)['section_title'] as String;
                              });
                            },
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
                      isExpanded: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date and Time Row
                  Row(
                    children: [
                      // Date Picker
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, setModalState),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedDate != null
                                    ? AppColors.primaryBlue
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: AppColors.primaryBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedDate != null
                                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                        : 'Select Date',
                                    style: TextStyle(
                                      color: _selectedDate != null
                                          ? Colors.black87
                                          : Colors.grey[600],
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Time Picker
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(context, setModalState),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedTime != null
                                    ? AppColors.primaryBlue
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: AppColors.primaryBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedTime != null
                                        ? _selectedTime!.format(context)
                                        : 'Select Time',
                                    style: TextStyle(
                                      color: _selectedTime != null
                                          ? Colors.black87
                                          : Colors.grey[600],
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Assign Button
                  ElevatedButton(
                    onPressed: () => _assignTask(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Assign Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Date picker
  Future<void> _selectDate(BuildContext context, StateSetter setModalState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setModalState(() {
        _selectedDate = picked;
      });
    }
  }

  // Time picker
  Future<void> _selectTime(BuildContext context, StateSetter setModalState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setModalState(() {
        _selectedTime = picked;
      });
    }
  }

  // UPDATED: Assign Task method with correct field names
  Future<void> _assignTask(BuildContext context) async {
    // Validate all fields
    if (_selectedtaskId == null ||
        _workerEmailController.text.isEmpty ||
        _selectedSectionId == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Please fill all fields'),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );

      // 1. Find worker by email
      final workerResponse = await Supabase.instance.client
          .from('Staff')
          .select('staff_id')
          .eq('email', _workerEmailController.text.trim())
          .eq('role', 4) // Ensure it's a worker
          .maybeSingle();

      if (workerResponse == null) {
        if (mounted) Navigator.pop(context);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Worker not found with this email'),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        return;
      }

      final workerStaffId = workerResponse['staff_id'] as int;
      final managerStaffId = widget.staffData['staff_id'] as int;

      // Format time as HH:MM:SS for Supabase time field
      final String formattedTime =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:'
          '${_selectedTime!.minute.toString().padLeft(2, '0')}:00';
print(_selectedtaskId);
print(workerStaffId);
print(managerStaffId);
print(_selectedSectionId);
print(_selectedDate!.toIso8601String().split('T')[0]);
print(formattedTime);
      // 2. Insert into assigned_tasks table with correct field names
      await Supabase.instance.client.from('assigned_tasks').insert({
        'task_id': _selectedtaskId, // Convert to string if task_id is varchar
        'staff_id': workerStaffId,
        'manager_id': managerStaffId,
        'section_id': _selectedSectionId,
        'status': 'pending', // Default status
        'schedule_date': _selectedDate!.toIso8601String().split('T')[0], // YYYY-MM-DD
        'allocated_time': formattedTime, // HH:MM:SS
      });

      // Remove loading dialog
      if (mounted) Navigator.pop(context);

      // Close modal
      if (mounted) Navigator.pop(context);

      // Reload assigned tasks
      await _loadAssignedTasks();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Task assigned successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      // Clear form
      _workerEmailController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _selectedSectionId = null;
        _selectedSectionTitle = null;
        _selectedtaskId = null;
        _selectedtaskTitle = null;
      });
    } catch (e) {
      // Remove loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBackground
          : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Manager Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer:  AdminDrawer(
       staffData: widget.staffData,
      ),
      body: Column(
        children: [
       // Combined Modern Header Section
Container(
  width: double.infinity,
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.primaryBlue,
        Color(0xFF42A5F5),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Title and Add Button Row
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Task Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showAssignTaskModal,
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Assign Task',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Quick Stats Row (Inside Card)
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                count: '${_completedTasks.length}',
                label: 'Completed',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.pending_actions,
                count: '${_inProgressTasks.length}',
                label: 'In Progress',
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),




      
    ],
  


                
  )
),
      // Simplified Tab Bar (Clean Integration)
    Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade300, width: 1),
  ),
  child: TabBar(
    controller: _tabController,
    indicatorColor: AppColors.primaryBlue, // just line under active tab
    indicatorWeight: 3, // thin highlight line
    labelColor: AppColors.primaryBlue,
    unselectedLabelColor: Colors.grey,
    labelStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
    ),
    unselectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 13,
    ),
    tabs: const [
      Tab(
        icon: Icon(Icons.check_circle_outline, size: 18),
        text: 'Completed',
      ),
      Tab(
        icon: Icon(Icons.pending_outlined, size: 18),
        text: 'In Progress',
      ),
    ],
  ),),
            
          

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(_completedTasks, true),
                _buildTaskList(_inProgressTasks, false),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.textSecondary,
          currentIndex: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.task),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warehouse),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Workers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assistant),
              label: 'IRIS AI',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WarehouseProductsScreen(),
                  ),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkersManagementScreen(staffData: widget.staffData),
                  ),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>ChatScreen(),
                  ),
                );
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<WorkerTask> tasks, bool isCompleted) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_circle_outline : Icons.pending_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted ? 'No completed tasks yet' : 'No tasks in progress',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Handle task tap
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isCompleted ? Icons.check_circle : Icons.pending_actions,
                            color: isCompleted ? AppColors.success : AppColors.warning,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.taskTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? AppColors.success
                                      : AppColors.warning,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  task.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 18,
                                color: AppColors.primaryBlue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  task.workerName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: AppColors.primaryBlue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  task.section,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: AppColors.primaryBlue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${task.date.day}/${task.date.month}/${task.date.year}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}