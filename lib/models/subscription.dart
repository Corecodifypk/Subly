import '../utils/subscription_date_utils.dart';

class Subscription {
  Subscription({
    required this.id,
    required this.name,
    required this.planName,
    required this.amount,
    required this.billingCycle,
    required this.nextPaymentDate,
    this.category = 'All',
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final String planName;
  final double amount;
  final String billingCycle;
  final DateTime nextPaymentDate;
  final String category;
  final bool isActive;
  final DateTime createdAt;

  Subscription copyWith({
    String? id,
    String? name,
    String? planName,
    double? amount,
    String? billingCycle,
    DateTime? nextPaymentDate,
    String? category,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      planName: planName ?? this.planName,
      amount: amount ?? this.amount,
      billingCycle: billingCycle ?? this.billingCycle,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'planName': planName,
        'amount': amount,
        'billingCycle': billingCycle,
        'nextPaymentDate': nextPaymentDate.toIso8601String(),
        'category': category,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Subscription.fromMap(Map<String, dynamic> map) => Subscription(
        id: map['id'] as String,
        name: map['name'] as String,
        planName: map['planName'] as String,
        amount: (map['amount'] as num).toDouble(),
        billingCycle: map['billingCycle'] as String,
        nextPaymentDate: DateTime.parse(map['nextPaymentDate'] as String),
        category: map['category'] as String? ?? 'All',
        isActive: map['isActive'] as bool? ?? true,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.parse(map['nextPaymentDate'] as String),
      );

  double get monthlyAmount =>
      billingCycle == 'Yearly' ? amount / 12 : amount;

  int get daysUntilPayment =>
      SubscriptionDateUtils.daysUntil(nextPaymentDate);

  bool get isOverdue => SubscriptionDateUtils.isOverdue(nextPaymentDate);
}
