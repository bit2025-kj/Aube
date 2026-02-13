class Advertisement {
  final String title;
  final String message;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Advertisement({
    required this.title,
    required this.message,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      title: json['title'],
      message: json['message'],
      imageUrl: json['image_url'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isActive: json['is_active'] ?? true,
    );
  }
}



