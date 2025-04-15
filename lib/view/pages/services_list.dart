import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceDetailsPage extends StatelessWidget {
  ServiceDetailsPage({super.key});

  final Map<String, List<String>> serviceDetails = {
    "Massages": [
      "Swedish Massage",
      "Deep Tissue Massage",
      "Hot Stone Massage",
      "Aromatherapy",
      "Reflexology"
    ],
    "Facials & Skincare": [
      "Deep Cleansing Facial",
      "Anti-Aging Facial",
      "Hydrating Facial",
      "Chemical Peels",
      "LED Light Therapy"
    ],
    "Nail Care": [
      "Gel Manicure",
      "Acrylic Nails",
      "Spa Pedicure",
      "Nail Art",
      "Cuticle Treatment"
    ],
    "Sauna & Steam": [
      "Dry Sauna",
      "Infrared Sauna",
      "Steam Room Therapy",
      "Herbal Steam Baths"
    ],
    "Hair & Salon": [
      "Haircuts",
      "Styling",
      "Coloring",
      "Keratin Treatment",
      "Scalp Care"
    ],
  };

  @override
  Widget build(BuildContext context) {
    String serviceName = Get.arguments as String; // Extract service name
    List<String> subcategories = serviceDetails[serviceName] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(serviceName),
      ),
      body: ListView.builder(
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.spa),
            title: Text(subcategories[index]),
            trailing: const Icon(Icons.arrow_forward_ios),
          );
        },
      ),
    );
  }
}
