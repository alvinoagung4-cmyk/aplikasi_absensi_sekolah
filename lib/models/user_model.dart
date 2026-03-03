class User {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String phone;
  final String position;
  final String department;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.position,
    required this.department,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'position': position,
      'department': department,
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      position: json['position'] ?? '',
      department: json['department'] ?? '',
    );
  }
}

class LoginCredentials {
  final String username;
  final String password;

  LoginCredentials({
    required this.username,
    required this.password,
  });
}

class AttendanceRecord {
  final String id;
  final String userId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String location;
  final String status; // 'present', 'late', 'absent'
  final String? notes;

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.checkInTime,
    this.checkOutTime,
    required this.location,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'checkInTime': checkInTime.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'location': location,
      'status': status,
      'notes': notes,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      checkInTime: DateTime.parse(json['checkInTime'] ?? DateTime.now().toIso8601String()),
      checkOutTime: json['checkOutTime'] != null ? DateTime.parse(json['checkOutTime']) : null,
      location: json['location'] ?? '',
      status: json['status'] ?? 'absent',
      notes: json['notes'],
    );
  }
}
