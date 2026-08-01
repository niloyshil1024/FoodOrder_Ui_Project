class FoodModel {
  final int id;
  final String name;
  final double price;
  final String image;
  final double rating;
  final String description;
  bool isFavorite;

  FoodModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.rating,
    required this.description,
    this.isFavorite = false,
  });

  String get imageUrl => image;

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      image: json['image']?.toString() ?? 'assets/cheeseBurger.png',
      rating: double.tryParse(json['rating'].toString()) ?? 4.5,
      description: json['description']?.toString() ?? '',
      // 🎯 এখানে সেফ চেক যুক্ত করা হয়েছে যাতে null আসলে এরর না দেয়
      isFavorite: json['isFavorite'] != null
          ? (json['isFavorite'] == true || json['isFavorite'] == 1)
          : false,
    );
  }
}