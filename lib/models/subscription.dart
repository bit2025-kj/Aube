class Subscription {
  final String id;
  final String userId;
  final String planId;
  final String planName;
  final String status;
  final String startDate;
  final String expiresAt;
  final String activationKey;
  final String phoneNumber;
  final int months;
  final String? validatedBy;  // nullable
  final String? validatedAt;  // nullable

  Subscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.status,
    required this.startDate,
    required this.expiresAt,
    required this.activationKey,
    required this.phoneNumber,
    required this.months,
    this.validatedBy,
    this.validatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      planId: json['plan_id'] ?? '',
      planName: json['plan_name'] ?? '',
      status: json['status'] ?? '',
      startDate: json['created_at'] ?? '',
      expiresAt: json['expires_at'] ?? '',
      activationKey: json['activation_key'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      months: json['months'] ?? 0,
      validatedBy: json['validated_by'],
      validatedAt: json['validated_at'],
    );
  }
}



