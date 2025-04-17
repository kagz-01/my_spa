import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with SingleTickerProviderStateMixin {
  bool isServicesView = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        isServicesView = _tabController.index == 0;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final services = {
    "Wellness Packages": [
      {
        "name": "Holistic Wellness Package",
        "description":
            "Experience holistic wellness with curated packages for total relaxation",
        "image": "assets/images/services/wellness.jpg"
      },
      {
        "name": "Couple's Retreat",
        "description": "Share relaxation with your partner",
        "image": "assets/images/services/couple.jpg"
      },
    ],
    "Massage Therapy": [
      {
        "name": "Swedish Massage",
        "description":
            "Relax your body and mind with soothing massage techniques",
        "image": "assets/images/services/massage.jpg"
      },
      {
        "name": "Deep Tissue Massage",
        "description": "Relief for muscle pain and tension",
        "image": "assets/images/services/deep_tissue.jpg"
      },
      {
        "name": "Hot Stone Massage",
        "description": "Warm stones enhance the massage experience",
        "image": "assets/images/services/hot_stone.jpg"
      },
    ],
    "Skin & Beauty Care": [
      {
        "name": "Deep Cleansing Facial",
        "description":
            "Glow naturally with expert treatments tailored to enhance your skin's radiance",
        "image": "assets/images/services/facial.jpg"
      },
      {
        "name": "Anti-Aging Facial",
        "description": "Rejuvenating treatment for youthful skin",
        "image": "assets/images/services/anti_aging.jpg"
      },
    ],
    "Full Body Care": [
      {
        "name": "Complete Body Treatment",
        "description":
            "Indulge in comprehensive care that revitalizes you from head to toe",
        "image": "assets/images/services/full_body.jpg"
      },
      {
        "name": "Body Scrub & Wrap",
        "description": "Exfoliation and hydration for your entire body",
        "image": "assets/images/services/scrub.jpg"
      },
    ],
    "Hair & Scalp Treatment": [
      {
        "name": "Scalp Therapy",
        "description":
            "Revive your locks with nourishing therapies for healthy, lustrous hair",
        "image": "assets/images/services/hair.jpg"
      },
      {
        "name": "Hair Mask Treatment",
        "description": "Deep conditioning for damaged hair",
        "image": "assets/images/services/hair_treatment.jpg"
      },
    ],
  };

  // Product categories with descriptions and example illustration paths
  final products = {
    "Hair Care": [
      {
        "name": "Professional Shampoos",
        "description": "Salon-quality hair cleansing products",
        "image": "assets/images/products/shampoo.jpg"
      },
      {
        "name": "Nourishing Conditioners",
        "description": "Deep hydration for all hair types",
        "image": "assets/images/products/conditioner.jpg"
      },
    ],
    "Skincare": [
      {
        "name": "Facial Cleansers",
        "description": "Gentle but effective skin purification",
        "image": "assets/images/products/cleanser.jpg"
      },
      {
        "name": "Toners & Serums",
        "description": "Balance and treat your skin concerns",
        "image": "assets/images/products/toner.jpg"
      },
      {
        "name": "Moisturizers",
        "description": "Hydration for glowing skin",
        "image": "assets/images/products/moisturizer.jpg"
      },
    ],
    "Body Care": [
      {
        "name": "Luxury Body Oils",
        "description": "Nourishing oils for silky skin",
        "image": "assets/images/products/oil.jpg"
      },
      {
        "name": "Body Scrubs",
        "description": "Exfoliation for smooth skin",
        "image": "assets/images/products/scrub.jpg"
      },
    ],
    "Aromatherapy": [
      {
        "name": "Essential Oils",
        "description": "Pure oils for relaxation and wellness",
        "image": "assets/images/products/oil.jpg"
      },
      {
        "name": "Diffusers",
        "description": "Spread calming scents throughout your space",
        "image": "assets/images/products/diffuser.jpg"
      },
    ],
  };

  // Images for each category
  final Map<String, String> categoryIllustrations = {
    "Wellness Packages": "assets/images/services/wellness.jpg",
    "Massage Therapy": "assets/images/services/massage.jpg",
    "Skin & Beauty Care": "assets/images/services/facial.jpg",
    "Full Body Care": "assets/images/services/full_body.jpg",
    "Hair & Scalp Treatment": "assets/images/services/hair_treatment.jpg",
    "Hair Care": "assets/images/products/shampoo.jpg",
    "Skincare": "assets/images/products/oil.jpg",
    "Body Care": "assets/images/products/toner.jpg",
    "Aromatherapy": "assets/images/products/diffuser.jpg",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () => Get.back(),
                  ),
                  const Expanded(
                    child: Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () => Get.toNamed("/notification"),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: 'Urbanist',
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tab Bar: Services/Products
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.brown.shade700,
                labelColor: Colors.brown.shade700,
                unselectedLabelColor: Colors.grey.shade500,
                labelStyle: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                tabs: const [
                  Tab(text: 'Our Services'),
                  Tab(text: 'Products'),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildServicesList(),
                  buildProductsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildServicesList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: services.entries.map((entry) {
        return buildCategorySection(entry.key, entry.value, isService: true);
      }).toList(),
    );
  }

  Widget buildProductsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: products.entries.map((entry) {
        return buildCategorySection(entry.key, entry.value, isService: false);
      }).toList(),
    );
  }

  Widget buildCategorySection(String title, List<dynamic> items,
      {required bool isService}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: getBgColor(title),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              // Navigate to detailed category view
              Get.toNamed("/category-detail", arguments: {
                'title': title,
                'items': items,
                'isService': isService,
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  // Left side content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Text(
                          getDescription(title),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontFamily: 'Urbanist',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Right side decoration with plus icons
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Row(
                      children: [
                        // Add flower or leaf decoration
                        if (title == "Wellness Packages" ||
                            title == "Skin & Beauty Care")
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: Image.asset(
                              "assets/images/services/flower.jpg",
                              height: 40,
                              color: Colors.white.withOpacity(0.3),
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(),
                            ),
                          ),

                        // Placeholder for category illustrations
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.asset(
                              // Use a default image if the category-specific one doesn't exist
                              categoryIllustrations[title] ??
                                  (isService
                                      ? "assets/images/services/massage.jpg"
                                      : "assets/images/products/oil.jpg"),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                getCategoryIcon(title),
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Small plus decoration
                  Positioned(
                    right: 40,
                    top: 5,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),

                  // Small plus decoration
                  Positioned(
                    right: 100,
                    bottom: 10,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData getCategoryIcon(String title) {
    switch (title) {
      case "Wellness Packages":
        return Icons.spa;
      case "Massage Therapy":
        return Icons.airline_seat_flat;
      case "Skin & Beauty Care":
        return Icons.face;
      case "Full Body Care":
        return Icons.accessibility_new;
      case "Hair & Scalp Treatment":
        return Icons.cut;
      case "Hair Care":
        return Icons.brush;
      case "Skincare":
        return Icons.face_retouching_natural;
      case "Body Care":
        return Icons.water_drop;
      case "Aromatherapy":
        return Icons.air;
      default:
        return Icons.category;
    }
  }

  Color getBgColor(String title) {
    switch (title) {
      case "Wellness Packages":
        return Color(0xFF8D6E63); // Brown
      case "Massage Therapy":
        return Color(0xFFA1887F); // Lighter brown
      case "Skin & Beauty Care":
        return Color(0xFFFFB74D); // Orange-ish
      case "Full Body Care":
        return Color(0xFFFFCC80); // Light orange
      case "Hair & Scalp Treatment":
        return Color(0xFF78909C); // Blueish gray
      case "Hair Care":
        return Color(0xFF26A69A); // Teal
      case "Skincare":
        return Color(0xFFBA68C8); // Purple
      case "Body Care":
        return Color(0xFF7986CB); // Indigo
      case "Aromatherapy":
        return Color(0xFF66BB6A); // Green
      default:
        return Color(0xFF607D8B); // Blue gray
    }
  }

  String getDescription(String title) {
    switch (title) {
      case "Wellness Packages":
        return "Experience holistic wellness with curated packages for total relaxation.";
      case "Massage Therapy":
        return "Relax your body and mind with soothing massage techniques for ultimate rejuvenation.";
      case "Skin & Beauty Care":
        return "Glow naturally with expert treatments tailored to enhance your skin's radiance.";
      case "Full Body Care":
        return "Indulge in comprehensive care that revitalizes you from head to toe.";
      case "Hair & Scalp Treatment":
        return "Revive your locks with nourishing therapies for healthy, lustrous hair.";
      case "Hair Care":
        return "Premium products for all hair types and concerns.";
      case "Skincare":
        return "Effective solutions for radiant, healthy skin.";
      case "Body Care":
        return "Luxurious products to pamper your entire body.";
      case "Aromatherapy":
        return "Enhance well-being through the power of scent.";
      default:
        return "";
    }
  }
}
