class JobModel {
  final int? id;
  final String title;
  final String customer;
  final String location;
  final String technician;
  final String priority;
  final String status;

  JobModel({
    this.id,
    required this.title,
    required this.customer,
    required this.location,
    required this.technician,
    required this.priority,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'customer': customer,
      'location': location,
      'technician': technician,
      'priority': priority,
      'status': status,
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'],
      title: map['title'],
      customer: map['customer'],
      location: map['location'],
      technician: map['technician'],
      priority: map['priority'],
      status: map['status'],
    );
  }
}
