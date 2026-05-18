class DiscountModel {

  final int id;
  final String title;
  final String type;
  final int discountPercent;
  final String startDate;
  final String endDate;
  final String? banner;

  DiscountModel({
    required this.id,
    required this.title,
    required this.type,
    required this.discountPercent,
    required this.startDate,
    required this.endDate,
    this.banner,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {

    return DiscountModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      discountPercent: json['discount_percent'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      banner: json['banner'],
    );
  }
}