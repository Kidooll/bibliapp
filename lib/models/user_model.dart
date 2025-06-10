class UserModel {
  final String id;
  final String? email;
  final String? username;
  final String? name;
  final String? photoUrl;
  final int totalDevotionalsRead;
  final int totalXp;
  final int currentLevel;
  final int xpToNextLevel;
  final int coins;
  final int weeklyGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    this.email,
    this.username,
    this.name,
    this.photoUrl,
    this.totalDevotionalsRead = 0,
    this.totalXp = 0,
    this.currentLevel = 1,
    this.xpToNextLevel = 100,
    this.coins = 0,
    this.weeklyGoal = 7,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      username: json['username'] as String?,
      name: json['name'] as String?,
      photoUrl: json['photo_url'] as String?,
      totalDevotionalsRead: json['total_devotionals_read'] as int? ?? 0,
      totalXp: json['total_xp'] as int? ?? 0,
      currentLevel: json['current_level'] as int? ?? 1,
      xpToNextLevel: json['xp_to_next_level'] as int? ?? 100,
      coins: json['coins'] as int? ?? 0,
      weeklyGoal: json['weekly_goal'] as int? ?? 7,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'photo_url': photoUrl,
      'total_devotionals_read': totalDevotionalsRead,
      'total_xp': totalXp,
      'current_level': currentLevel,
      'xp_to_next_level': xpToNextLevel,
      'coins': coins,
      'weekly_goal': weeklyGoal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
