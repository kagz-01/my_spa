import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailsPage extends StatelessWidget {
  ProductDetailsPage({super.key});

  final Map<String, List<String>> productDetails = {
    "Hair Care": [
      "Shampoos",
      "Conditioners",
      "Hair Oils",
      "Hair Serums",
      "Hair Masks",
      "Styling Products"
    ],
    "Skincare": [
      "Facial Cleansers",
      "Toners",
      "Moisturizers",
      "Sunscreens",
      "Anti-aging Serums",
      "Face Masks"
    ],
    "Nail Care": [
      "Nail Polishes",
      "Nail Care Kits",
      "Nail Creams",
      "Artificial Nails"
    ],
    "Beauty & Makeup": [
      "Foundation",
      "Lipsticks",
      "Eyeshadows",
      "Mascaras",
      "Highlighters",
      "Makeup Brushes"
    ],
    "Fragrances": ["Perfumes", "Colognes", "Body Mists", "Essential Oils"],
    "Jewelry & Accessories": [
      "Earrings",
      "Necklaces",
      "Bracelets",
      "Rings",
      "Piercing Jewelry",
      "Hair Accessories"
    ],
    "Spa & Wellness": [
      "Bath Salts",
      "Body Scrubs",
      "Lotions",
      "Scented Candles",
      "Diffusers",
      "Herbal Teas",
      "Yoga Mats"
    ],
  };

  @override
  Widget build(BuildContext context) {
    String productName = Get.arguments as String; // Retrieve argument
    List<String> subcategories = productDetails[productName] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
      ),
      body: ListView.builder(
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text(subcategories[index]),
            trailing: const Icon(Icons.arrow_forward_ios),
          );
        },
      ),
    );
  }
}
