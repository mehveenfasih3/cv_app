class WorkerTask {
  final String id;
  final String workerName;
  final String workerEmail;
  final String taskTitle;
  final String section;
  final String status;
  final DateTime date;

  WorkerTask({
    required this.id,
    required this.workerName,
    required this.workerEmail,
    required this.taskTitle,
    required this.section,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workerName': workerName,
      'workerEmail': workerEmail,
      'taskTitle': taskTitle,
      'section': section,
      'status': status,
      'date': date.toIso8601String(),
    };
  }

  factory WorkerTask.fromJson(Map<String, dynamic> json) {
    return WorkerTask(
      id: json['id'],
      workerName: json['workerName'],
      workerEmail: json['workerEmail'],
      taskTitle: json['taskTitle'],
      section: json['section'],
      status: json['status'],
      date: DateTime.parse(json['date']),
    );
  }
}