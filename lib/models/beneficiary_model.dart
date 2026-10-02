class Beneficiary {
  final String id;
  final String name;
  final String accountNumber;
  final String maskedNumber;
  final String bankName;
  final String nickname;
  final String avatarInitials;

  Beneficiary({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.maskedNumber,
    required this.bankName,
    this.nickname = '',
    this.avatarInitials = '',
  });

  String get initials {
    if (avatarInitials.isNotEmpty) return avatarInitials;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'B';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'accountNumber': accountNumber,
      'maskedNumber': maskedNumber,
      'bankName': bankName,
      'nickname': nickname,
      'avatarInitials': avatarInitials,
    };
  }

  factory Beneficiary.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Beneficiary(
      id: docId ?? map['id'] ?? 'BEN_${DateTime.now().millisecondsSinceEpoch}',
      name: map['name'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      maskedNumber: map['maskedNumber'] ?? '',
      bankName: map['bankName'] ?? '',
      nickname: map['nickname'] ?? '',
      avatarInitials: map['avatarInitials'] ?? '',
    );
  }
}
