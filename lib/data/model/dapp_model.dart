class DAppModel {
  final String id;
  final String name;
  final String description;
  final String url;
  final String imagePath;
  final String category;
  final bool isPopular;
  final double rating;

  const DAppModel({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.imagePath,
    required this.category,
    this.isPopular = false,
    this.rating = 0.0,
  });

  factory DAppModel.fromJson(Map<String, dynamic> json) {
    return DAppModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      imagePath: json['imagePath'] as String,
      category: json['category'] as String,
      isPopular: json['isPopular'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'url': url,
      'imagePath': imagePath,
      'category': category,
      'isPopular': isPopular,
      'rating': rating,
    };
  }
}
