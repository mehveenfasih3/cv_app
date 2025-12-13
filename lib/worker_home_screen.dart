import 'package:flutter/material.dart';
import 'package:iris_app/app_colors.dart';
import 'package:iris_app/custom_drawer.dart';
import 'package:iris_app/cv_scanning.dart';
import 'package:iris_app/performance_report.dart';
import 'package:iris_app/worker_assistant.dart';
import 'package:iris_app/worker_task.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({Key? key}) : super(key: key);

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  // Sample tasks - replace with actual data from database
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Load Warehouse A',
      description: 'Load 50 boxes to Warehouse A Section B',
      date: DateTime.now(),
      time: '09:00 AM',
      isCompleted: false,
    ),
    Task(
      id: '2',
      title: 'Inventory Check',
      description: 'Check inventory for Electronics Section',
      date: DateTime.now(),
      time: '11:00 AM',
      isCompleted: true,
    ),
    Task(
      id: '3',
      title: 'Package Delivery',
      description: 'Prepare packages for afternoon delivery',
      date: DateTime.now(),
      time: '02:00 PM',
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(
        userName: 'John Doe',
        userEmail: 'john.doe@iris.com',
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (value) {
                  setState(() {
                    task.isCompleted = value!;
                  });
                },
                activeColor: AppColors.primaryBlue,
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(task.description),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.time,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${task.date.day}/${task.date.month}/${task.date.year}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Icon(
                task.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: task.isCompleted
                    ? AppColors.success
                    : AppColors.mediumGrey,
              ),
            ),
          );
        },
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
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => CVScanningScreen(),
              //   ),
              // );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PerformanceReportScreen(),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IrisAssistantScreen(),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}