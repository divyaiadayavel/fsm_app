class TechnicianModel {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final int jobs;

  TechnicianModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.jobs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'jobs': jobs,
    };
  }

  factory TechnicianModel.fromMap(Map<String, dynamic> map) {
    return TechnicianModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      jobs: map['jobs'],
    );
  }
}
