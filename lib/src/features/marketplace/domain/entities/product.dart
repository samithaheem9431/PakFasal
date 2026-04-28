class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.companyName,
    required this.phone,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.location,
    this.verified = false,
    this.whatsappNumber,
  });

  final String id;
  final String name;
  final String category;
  final String companyName;
  final String phone;
  final String description;
  final String imageUrl;
  final double price;
  final String? location;
  final bool verified;
  final String? whatsappNumber;
}
