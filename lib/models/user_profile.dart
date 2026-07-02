class UserProfile {
  UserProfile({
    this.greeting = 'Slam',
    this.name = 'Tysen Don',
    this.profileImagePath,
    this.monthlyBudget = 500.0,
  });

  final String greeting;
  final String name;
  final String? profileImagePath;
  final double monthlyBudget;

  UserProfile copyWith({
    String? greeting,
    String? name,
    String? profileImagePath,
    double? monthlyBudget,
    bool clearImage = false,
  }) {
    return UserProfile(
      greeting: greeting ?? this.greeting,
      name: name ?? this.name,
      profileImagePath:
          clearImage ? null : (profileImagePath ?? this.profileImagePath),
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
    );
  }

  Map<String, dynamic> toMap() => {
        'greeting': greeting,
        'name': name,
        'profileImagePath': profileImagePath,
        'monthlyBudget': monthlyBudget,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        greeting: map['greeting'] as String? ?? 'Slam',
        name: map['name'] as String? ?? 'Tysen Don',
        profileImagePath: map['profileImagePath'] as String?,
        monthlyBudget: (map['monthlyBudget'] as num?)?.toDouble() ?? 500.0,
      );
}
