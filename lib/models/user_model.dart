class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String accountNumber;
  final String customerTier;
  final bool isKycVerified;
  final String joinedDate;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.accountNumber,
    this.customerTier = 'Platinum Member',
    this.isKycVerified = true,
    this.joinedDate = 'Jan 2024',
  });

  String get firstName => name.split(' ').first;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'accountNumber': accountNumber,
      'customerTier': customerTier,
      'isKycVerified': isKycVerified,
      'joinedDate': joinedDate,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return UserModel(
      userId: docId ?? map['userId'] ?? 'USR_${DateTime.now().millisecondsSinceEpoch}',
      name: map['name'] ?? 'User',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '+91 98765 43210',
      accountNumber: map['accountNumber'] ?? 'ACC-8921-4402',
      customerTier: map['customerTier'] ?? 'Platinum Member',
      isKycVerified: map['isKycVerified'] ?? true,
      joinedDate: map['joinedDate'] ?? 'Jan 2024',
    );
  }
}
