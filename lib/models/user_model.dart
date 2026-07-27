import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String university;
  final String profileImage;
  final String role; // 'Admin' or 'Intern'
  final DateTime createdAt;
  final String internId;
  final String bio;
  final String skills;
  final String address;
  final String emergencyContact;
  final String github;
  final String linkedin;
  final String portfolio;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.university,
    required this.profileImage,
    required this.role,
    required this.createdAt,
    this.internId = '',
    this.bio = '',
    this.skills = '',
    this.address = '',
    this.emergencyContact = '',
    this.github = '',
    this.linkedin = '',
    this.portfolio = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      department: data['department'] ?? '',
      university: data['university'] ?? '',
      profileImage: data['profileImage'] ?? '',
      role: data['role'] ?? 'Intern',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      internId: data['internId'] ?? 'INT-${id.substring(0, 5).toUpperCase()}',
      bio: data['bio'] ?? '',
      skills: data['skills'] ?? '',
      address: data['address'] ?? '',
      emergencyContact: data['emergencyContact'] ?? '',
      github: data['github'] ?? '',
      linkedin: data['linkedin'] ?? '',
      portfolio: data['portfolio'] ?? '',
    );
  }

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'university': university,
      'profileImage': profileImage,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'internId': internId,
      'bio': bio,
      'skills': skills,
      'address': address,
      'emergencyContact': emergencyContact,
      'github': github,
      'linkedin': linkedin,
      'portfolio': portfolio,
    };
  }

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isIntern => role.toLowerCase() == 'intern';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
