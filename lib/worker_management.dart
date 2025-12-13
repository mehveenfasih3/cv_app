import 'package:flutter/material.dart';
import 'package:iris_app/admin_worker.dart';
import 'package:iris_app/app_colors.dart';


class WorkersManagementScreen extends StatefulWidget {
  const WorkersManagementScreen({Key? key}) : super(key: key);

  @override
  State<WorkersManagementScreen> createState() =>
      _WorkersManagementScreenState();
}

class _WorkersManagementScreenState extends State<WorkersManagementScreen> {
   String? selectedSection;
  final List<Worker> _workers = [
    Worker(
      id: '1',
      name: 'John Doe',
      email: 'john@iris.com',
      phone: '+92 300 1234567',
      section: 'Warehouse A',
      joinDate: DateTime(2024, 1, 15),
    ),
    Worker(
      id: '2',
      name: 'Jane Smith',
      email: 'jane@iris.com',
      phone: '+92 301 2345678',
      section: 'Electronics',
      joinDate: DateTime(2024, 2, 20),
    ),
    Worker(
      id: '3',
      name: 'Mike Johnson',
      email: 'mike@iris.com',
      phone: '+92 302 3456789',
      section: 'Warehouse C',
      joinDate: DateTime(2024, 3, 10),
    ),
  ];

  void _showAddWorkerDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final sectionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Worker'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
      value: selectedSection,
      decoration: const InputDecoration(
        labelText: 'Section',
        prefixIcon: Icon(Icons.location_on),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: 'Warehouse',
          child: Text('Warehouse'),
        ),
        DropdownMenuItem(
          value: 'Grocery',
          child: Text('Grocery'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          selectedSection = value;
        });
      },
    )
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
              if (nameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty) {
                setState(() {
                  _workers.add(
                    Worker(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                      section: sectionController.text,
                      joinDate: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Worker added successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditWorkerDialog(Worker worker) {
    final nameController = TextEditingController(text: worker.name);
    final emailController = TextEditingController(text: worker.email);
    final phoneController = TextEditingController(text: worker.phone);
    final sectionController = TextEditingController(text: worker.section);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Worker'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 12),
             DropdownButtonFormField<String>(
      value: selectedSection,
      decoration: const InputDecoration(
        labelText: 'Section',
        prefixIcon: Icon(Icons.location_on),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: 'Warehouse',
          child: Text('Warehouse'),
        ),
        DropdownMenuItem(
          value: 'Grocery',
          child: Text('Grocery'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          selectedSection = value;
        });
      },
    )
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
              setState(() {
                final index = _workers.indexWhere((w) => w.id == worker.id);
                if (index != -1) {
                  _workers[index] = Worker(
                    id: worker.id,
                    name: nameController.text,
                    email: emailController.text,
                    phone: phoneController.text,
                    section: sectionController.text,
                    joinDate: worker.joinDate,
                  );
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Worker updated successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteWorker(Worker worker) {
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
              setState(() {
                _workers.removeWhere((w) => w.id == worker.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Worker deleted successfully'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddWorkerDialog,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _workers.length,
        itemBuilder: (context, index) {
          final worker = _workers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryBlue,
                child: Text(
                  worker.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.white,
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
                      Text(worker.email),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(worker.phone),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(worker.section),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditWorkerDialog(worker);
                  } else if (value == 'delete') {
                    _deleteWorker(worker);
                  }
                },
                itemBuilder: (context) => [
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWorkerDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}