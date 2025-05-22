// lib/models/product_card_data.dart

class ProductCardData {
  final int id;
  final String name;
  final String productId;
  final String description;
  final String longDescription;
  final String type;
  final int scoreRommaana;
  final String family;
  final String single;
  final String expat;
  final String img;
  final int insuranceCompanyId;
  final int priceId;
  final Map<String, dynamic> insuranceCompany;
  final Map<String, dynamic> price;

  ProductCardData({
    required this.id,
    required this.name,
    required this.productId,
    required this.description,
    required this.longDescription,
    required this.type,
    required this.scoreRommaana,
    required this.family,
    required this.single,
    required this.expat,
    required this.img,
    required this.insuranceCompanyId,
    required this.priceId,
    required this.insuranceCompany,
    required this.price,
  });

  // Factory constructor to create a ProductCardData object from a JSON map
  factory ProductCardData.fromJson(Map<String, dynamic> json) {
    return ProductCardData(
      id: json['id'] as int,
      name: json['name'] as String,
      productId: json['productId'] as String,
      description: json['description'] as String,
      longDescription: json['longDescription'] as String,
      type: json['type'] as String,
      scoreRommaana: json['scoreRommaana'] as int,
      family: json['family'] as String,
      single: json['single'] as String,
      expat: json['expat'] as String,
      img: json['img'] as String,
      insuranceCompanyId: json['insurance_company_id'] as int,
      priceId: json['price_id'] as int,
      insuranceCompany: json['InsuranceCompany'] as Map<String, dynamic>,
      price: json['Price'] as Map<String, dynamic>,
    );
  }
}

