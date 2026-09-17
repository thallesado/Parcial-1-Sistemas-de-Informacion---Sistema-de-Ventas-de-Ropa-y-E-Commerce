import 'package:flutter/material.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.oldPrice,
    required this.imageAlignment,
    required this.color,
    required this.colorName,
    required this.material,
    required this.fit,
    required this.style,
    required this.occasion,
    required this.sizes,
    required this.stockByBranch,
    required this.popularity,
    required this.description,
    required this.composition,
    required this.origin,
    required this.modelInfo,
    required this.rating,
    required this.reviewCount,
    this.isNew = false,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final double? oldPrice;
  final Alignment imageAlignment;
  final Color color;
  final String colorName;
  final String material;
  final String fit;
  final String style;
  final String occasion;
  final List<String> sizes;
  final Map<String, int> stockByBranch;
  final int popularity;
  final String description;
  final String composition;
  final String origin;
  final String modelInfo;
  final double rating;
  final int reviewCount;
  final bool isNew;

  int get totalStock =>
      stockByBranch.values.fold(0, (sum, value) => sum + value);

  bool get hasLowStock => totalStock <= 10;

  int get discount =>
      oldPrice == null ? 0 : (((oldPrice! - price) / oldPrice!) * 100).round();
}
