import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:my_spa/services/api_service.dart';

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({super.key});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  // API service instance
  final ApiService _apiService = ApiService();

  late String title;
  late List<dynamic> items;
  late bool isService;
  int selectedItemIndex = 0;
  DateTime selectedDate = DateTime.now();
  String selectedTime = '10:00 AM';
  int selectedDuration = 60;
  int quantity = 1;
  bool isFavorite = false;

  // Available time slots
  final List<String> availableTimeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM'
  ];

  // Extended descriptions for each category
  final Map<String, String> extendedDescriptions = {
    // Services descriptions
    'Swedish Massage':
        'Experience the epitome of relaxation with our Swedish Massage, a classic technique that uses long, flowing strokes to improve circulation and ease tension. This gentle yet effective treatment combines kneading, circular movements, and passive joint movements to soothe tired muscles and stimulate the nervous system. Our skilled therapists adapt the pressure to your preference, ensuring a personalized experience that alleviates stress while promoting overall wellness. Perfect for first-time spa-goers and those seeking a truly calming experience that will leave you rejuvenated from head to toe.',

    'Deep Tissue Massage':
        'Our Deep Tissue Massage targets the inner layers of muscles and connective tissues using slow, deliberate strokes and firm pressure. This therapeutic treatment works exceptionally well for chronic aches and pain, addressing issues like stiff neck, lower back tightness, and sore shoulders. Our certified therapists apply specialized techniques to untangle complex knots and release trapped tension in problem areas. The focused pressure helps break down adhesions (bands of rigid tissue) that can cause discomfort, inflammation, and restricted movement, promoting faster healing and improved mobility for lasting relief.',

    'Hot Stone Massage':
        'The Hot Stone Massage is a luxurious therapy that melts away tension, eases muscle stiffness, and increases circulation throughout your body. Smooth, heated basalt stones are placed on specific points along your energy meridians, complemented by traditional massage techniques that incorporate the stones as an extension of the therapist\'s hands. The warmth of the stones penetrates deep into the muscles, allowing more intensive work on problem areas without excessive pressure. This deeply soothing treatment induces a state of profound relaxation while delivering therapeutic benefits that continue well after your session.',

    'Deep Cleansing Facial':
        'Our signature Deep Cleansing Facial is a comprehensive treatment designed to purify and revitalize your complexion from within. Beginning with a detailed skin analysis, this multi-step facial includes gentle cleansing, enzymatic exfoliation, steam therapy, and professional extraction to remove impurities and unclog pores. Our estheticians use medical-grade equipment and premium products tailored to your skin type. A customized mask and hydrating serums restore balance while targeted massage techniques stimulate circulation and promote lymphatic drainage. Ideal for all skin types, especially those prone to congestion or dullness, this facial leaves your skin noticeably clearer and more radiant.',

    'Anti-Aging Facial':
        'Turn back the clock with our advanced Anti-Aging Facial, specially formulated to address fine lines, wrinkles, and loss of elasticity. Using cutting-edge skincare technology and clinical-strength products, this rejuvenating treatment combines powerful antioxidants, peptides, and botanical extracts to stimulate collagen production and cell renewal. Our expert estheticians incorporate specialized massage techniques that improve microcirculation while high-performance serums deliver active ingredients deep into the skin. The session includes LED light therapy to further enhance results. Experience immediate lifting and firming effects with lasting results that improve with regular treatments.',

    'Complete Body Treatment':
        'The Complete Body Treatment is our most comprehensive spa experience, offering head-to-toe rejuvenation in one luxurious session. This transformative journey begins with a full-body exfoliation using custom-blended scrubs to remove dead skin cells, followed by a detoxifying wrap that draws out impurities while infusing the skin with minerals and nutrients. While cocooned, enjoy a soothing scalp massage to release tension. Once unwrapped, a customized massage using aromatherapy oils addresses your specific needs, and a mini-facial completes this ultimate pampering session. This 120-minute ritual leaves you completely refreshed and revitalized, with benefits that extend well beyond your visit.',

    'Body Scrub & Wrap':
        'Reveal your skin\'s natural radiance with our Body Scrub & Wrap treatment, a two-step process for ultimate skin renewal and deep relaxation. The invigorating scrub combines fine natural exfoliants—such as mineral-rich sea salts or organic sugar crystals—with nourishing oils to gently remove dead skin cells and stimulate circulation. Following this, a mineral-rich body wrap using premium marine extracts, clay, or botanical concentrates detoxifies while infusing moisture deep into the skin. This cocooning experience not only improves skin texture and appearance but also promotes a sense of deep relaxation and wellbeing that continues well after your session.',

    'Scalp Therapy':
        'Our specialized Scalp Therapy treatment addresses the root of healthy hair by focusing on the scalp\'s condition and overall wellness. Beginning with a thorough analysis, this therapeutic session combines stimulating massage techniques with nutrient-rich oils specifically chosen for your hair type and concerns. Using precision finger pressure, our therapists work to release tension in the cranial muscles while improving blood flow to follicles. The treatment includes exfoliation to remove buildup and application of a customized treatment mask that penetrates deeply to nourish hair follicles and balance the scalp\'s natural oils. The experience concludes with a warm oil infusion that leaves your scalp revitalized and your mind wonderfully calm.',

    'Hair Mask Treatment':
        'Restore vitality and shine to damaged or stressed hair with our intensive Hair Mask Treatment, a professional-grade therapy that transforms your hair from within. The session begins with a detailed hair analysis followed by a clarifying rinse to remove product buildup and prepare the hair shaft for maximum absorption. Our specialists then apply a deeply conditioning mask customized to your specific hair concerns, whether it\'s dryness, breakage, frizz, or color preservation. Enhanced with steam or infrared heat technology to maximize penetration of restorative ingredients, the mask is complemented by a relaxing scalp and shoulder massage. The result is noticeably softer, stronger, and more manageable hair with renewed luster and resilience against environmental stressors.',

    // Original product descriptions remain unchanged
    'Professional Shampoos':
        'Our collection of Professional Shampoos represents the pinnacle of hair cleansing technology, formulated by expert trichologists to address specific hair concerns while maintaining optimal scalp health. Each shampoo contains a proprietary blend of natural extracts, proteins, and conditioning agents that work in harmony to cleanse without stripping essential oils. Free from harsh sulfates and parabens, these pH-balanced formulations are gentle enough for daily use yet effective enough to remove buildup and environmental pollutants, leaving hair noticeably healthier with each wash.',

    'Nourishing Conditioners':
        'Experience hair transformation with our range of Nourishing Conditioners, scientifically developed to restore moisture balance and enhance hair structure from within. These advanced formulations combine hydrolyzed proteins that penetrate the hair shaft with protective emollients that seal the cuticle. Rich in natural oils, vitamins, and botanical extracts, they target specific concerns from dryness and breakage to color protection and volume enhancement. Regular use results in remarkably smoother, stronger hair with improved elasticity and a silky, manageable finish.',

    'Facial Cleansers':
        'Our premium Facial Cleansers collection represents a new paradigm in skin purification, with formulations that respect the skin\'s delicate microbiome while effectively removing impurities. Developed through advanced cosmetic science, each cleanser combines gentle surfactants with nourishing ingredients that maintain your skin\'s natural moisture barrier. Whether your concern is excess oil, sensitivity, aging, or environmental protection, these pH-optimized cleansers work beyond the surface to promote long-term skin health, leaving your complexion refreshed, balanced, and receptive to subsequent treatments.',

    'Toners & Serums':
        'Transform your skincare routine with our revolutionary Toners & Serums, featuring concentrated actives that deliver visible results through advanced delivery systems. Our alcohol-free toners rebalance the skin\'s pH while providing the first layer of hydration with humectants and botanical extracts. The companion serums utilize liposomal technology to carry powerful ingredients like peptides, antioxidants, and hyaluronic acid to their optimal depth in the skin. This scientifically formulated duo works synergistically to address specific concerns from hyperpigmentation to loss of firmness, revealing healthier, more radiant skin day after day.',

    'Moisturizers':
        'Our cutting-edge Moisturizers represent the perfect synthesis of science and nature, developed to provide multi-dimensional hydration that adapts to your skin\'s changing needs. Using a proprietary complex of humectants, emollients, and occlusive agents, these formulations create a breathable moisture matrix that provides immediate relief from dryness while strengthening the skin\'s natural barrier function over time. Enhanced with bioactive ingredients like ceramides, peptides, and botanical extracts, each moisturizer delivers targeted benefits beyond hydration, from environmental protection to cellular regeneration, resulting in a complexion that looks and feels remarkably healthier.',

    'Luxury Body Oils':
        'Indulge in sensorial luxury with our exceptional Body Oils, where rare botanical extracts meet cutting-edge cosmetic science. Each oil in our collection features a unique blend of cold-pressed base oils selected for their specific skin-nurturing properties, from rapid absorption to deep nourishment. Enhanced with therapeutic-grade essential oils and fat-soluble vitamins, these silky formulations penetrate beyond the surface to restore lipid balance and improve skin elasticity. The transformative textures leave no greasy residue, instead imparting a subtle, healthy glow and a delicate fragrance that evolves uniquely with your body chemistry.',

    'Body Scrubs':
        'Elevate your exfoliation ritual with our premium Body Scrubs, meticulously crafted to revitalize skin texture while delivering therapeutic benefits. These dual-action formulations combine precisely calibrated exfoliants—from biodegradable jojoba beads to mineral-rich sea salts—with nourishing butters and oils that replenish moisture as they polish. The innovative suspension system ensures the perfect distribution of particles, preventing micro-tears while effectively removing dulling surface cells. Beyond physical renewal, each scrub variant incorporates aromatherapeutic elements that transform your shower into a multi-sensory experience, leaving skin remarkably soft, receptive to subsequent treatments, and visibly revitalized.',

    'Essential Oils':
        'Our exclusive collection of Essential Oils represents the pinnacle of aromatic purity and therapeutic potency. Each oil is meticulously extracted through appropriate methods—steam distillation, cold-pressing, or CO2 extraction—to preserve the complete botanical fingerprint and ensure maximum efficacy. Sourced from regions renowned for optimal growing conditions and subjected to rigorous testing for both authenticity and purity, these concentrated plant essences deliver specific wellness benefits from stress reduction to respiratory support. Whether used in diffusion, topical applications (when properly diluted), or custom blends, these professional-grade oils offer an unparalleled olfactory experience while supporting both physical and emotional wellbeing.',

    'Diffusers':
        'Transform your personal environment with our innovative Diffusers, engineered to optimize the therapeutic benefits of aromatherapy through precise fragrance distribution. Utilizing advanced ultrasonic technology, these devices break essential oils into microscopic particles that remain suspended in the air for extended periods without heat degradation, preserving their complete therapeutic profile. Featuring customizable mist intensity, timer functions, and subtle LED options, each diffuser is designed as both a functional wellness tool and an elegant decor element. The whisper-quiet operation and auto-shutoff safety features allow for worry-free enjoyment of aromatic benefits throughout day and night, creating spaces that nurture both body and mind.'
  };

  // Benefits mapped to each category type
  final Map<String, List<String>> categoryBenefits = {
    'Massage Therapy': [
      'Relieves muscle tension and chronic pain',
      'Improves blood circulation and lymphatic flow',
      'Reduces stress hormones and anxiety levels',
      'Enhances immune function and overall wellbeing',
      'Promotes better sleep quality and recovery'
    ],
    'Skin & Beauty Care': [
      'Deep cleanses pores and removes impurities',
      'Stimulates collagen production for firmer skin',
      'Improves skin tone and reduces pigmentation',
      'Hydrates and restores skin barrier function',
      'Provides protection from environmental damage'
    ],
    'Full Body Care': [
      'Exfoliates and renews skin cells across the entire body',
      'Detoxifies through improved circulation and lymphatic drainage',
      'Balances energy and relieves whole-body tension',
      'Hydrates skin deeply for lasting softness',
      'Creates a sense of holistic rejuvenation'
    ],
    'Hair & Scalp Treatment': [
      'Strengthens hair follicles and prevents hair loss',
      'Balances scalp oils and treats dandruff issues',
      'Stimulates blood flow for healthier hair growth',
      'Repairs damaged hair structure and split ends',
      'Adds shine and improves manageability'
    ],
    'Hair Care': [
      'Cleanses while maintaining natural moisture balance',
      'Strengthens hair structure and prevents breakage',
      'Protects color and prevents UV damage',
      'Improves texture and manageability',
      'Adds volume and enhances natural shine'
    ],
    'Skincare': [
      'Deeply purifies while maintaining skin\'s pH balance',
      'Accelerates cell turnover for renewed complexion',
      'Delivers targeted active ingredients for specific concerns',
      'Strengthens skin\'s natural defense mechanisms',
      'Provides optimal hydration for all skin types'
    ],
    'Body Care': [
      'Nourishes skin with essential vitamins and minerals',
      'Improves elasticity and firmness',
      'Creates protective barrier against environmental stressors',
      'Promotes even tone and texture',
      'Provides long-lasting hydration without greasiness'
    ],
    'Aromatherapy': [
      'Reduces stress and anxiety through olfactory pathways',
      'Improves sleep quality and aids relaxation',
      'Enhances mood and mental clarity',
      'Supports respiratory health and immune function',
      'Creates personalized wellness experiences'
    ],
    'Wellness Packages': [
      'Provides comprehensive care for body, mind and spirit',
      'Creates synergistic benefits through combined therapies',
      'Delivers deeper relaxation through extended treatment time',
      'Addresses multiple wellness concerns in one session',
      'Offers exceptional value for complete rejuvenation'
    ]
  };

  @override
  void initState() {
    super.initState();

    // Get arguments passed from category page
    final args = Get.arguments as Map<String, dynamic>;
    title = args['title'] as String;
    items = args['items'] as List<dynamic>;
    isService = args['isService'] as bool;

    // Initialize duration for services
    if (isService) {
      selectedDuration = 60;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get item price with proper formatting
    String itemPrice =
        isService ? '\$${120 + (selectedDuration - 60) * 2}' : '\$45';

    // Get appropriate action button text
    String actionButtonText = isService ? 'Book Appointment' : 'Add to Cart';

    // Get current item name for extended description lookup
    String currentItemName = items[selectedItemIndex]['name'];

    // Get category-specific benefits
    List<String> benefits =
        categoryBenefits[title] ?? categoryBenefits['Massage Therapy']!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null),
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });

                      // Show confirmation
                      final message = isFavorite
                          ? 'Added to favorites'
                          : 'Removed from favorites';

                      Get.snackbar(
                        'Favorites',
                        message,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.black87,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 1),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item selector (horizontal list)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedItemIndex = index;
                              });
                            },
                            child: Container(
                              width: 180,
                              margin: const EdgeInsets.only(
                                  right: 12, top: 10, bottom: 10),
                              decoration: BoxDecoration(
                                color: selectedItemIndex == index
                                    ? Colors.brown.shade300
                                    : Colors.brown.shade100,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  if (selectedItemIndex == index)
                                    BoxShadow(
                                      color: Colors.brown.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  items[index]['name'],
                                  style: TextStyle(
                                    color: selectedItemIndex == index
                                        ? Colors.white
                                        : Colors.brown.shade700,
                                    fontWeight: selectedItemIndex == index
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontFamily: 'Urbanist',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Main image
                    Hero(
                      tag: "item_${items[selectedItemIndex]['name']}",
                      child: Container(
                        height: 250,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            items[selectedItemIndex]['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title and price
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              items[selectedItemIndex]['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.brown.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              itemPrice,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown.shade700,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Rating
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '4.8',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(120 reviews)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            // Use extended description if available, otherwise fall back to original
                            extendedDescriptions[currentItemName] ??
                                items[selectedItemIndex]['description'],
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.grey.shade700,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Duration section - for services only
                    if (isService)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Duration',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildDurationOption('30 min', 30),
                                const SizedBox(width: 12),
                                _buildDurationOption('60 min', 60),
                                const SizedBox(width: 12),
                                _buildDurationOption('90 min', 90),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // Quantity section - for products only
                    if (!isService)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (quantity > 1) quantity--;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.remove,
                                            size: 20,
                                            color: quantity > 1
                                                ? Colors.black
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        child: Text(
                                          '$quantity',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (quantity < 10) quantity++;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: const Icon(
                                            Icons.add,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Benefits & Goodness
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Benefits & Goodness',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...benefits
                              .map((benefit) => _buildBenefitItem(benefit)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Bottom action bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (isService) {
                          _showBookingDialog();
                        } else {
                          _addToCart();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8D6E63),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        actionButtonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.green.shade700,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              benefit,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                fontFamily: 'Urbanist',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationOption(String label, int duration) {
    bool isSelected = selectedDuration == duration;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDuration = duration;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.brown.shade700 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
          border: isSelected
              ? null
              : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Urbanist',
          ),
        ),
      ),
    );
  }

  void _showBookingDialog() {
    // Initialize dialog state
    DateTime selectedAppointmentDate = DateTime.now();
    String selectedTimeSlot = availableTimeSlots[2]; // Default to 11:00 AM
    bool isProcessing = false;

    // Generate available dates (today + next 4 days = 5 days total)
    List<DateTime> availableDates = List.generate(5, (index) {
      return DateTime.now().add(Duration(days: index));
    });

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dialog header with image
                    Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image:
                                  AssetImage(items[selectedItemIndex]['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Book Appointment',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                items[selectedItemIndex]['name'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date selection cards (horizontal list)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: availableDates.length,
                        itemBuilder: (context, index) {
                          final date = availableDates[index];
                          final isToday = date.day == DateTime.now().day &&
                              date.month == DateTime.now().month &&
                              date.year == DateTime.now().year;
                          final isSelected =
                              date.day == selectedAppointmentDate.day &&
                                  date.month == selectedAppointmentDate.month;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAppointmentDate = date;
                              });
                            },
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF8D6E63)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF8D6E63)
                                      : Colors.grey.shade300,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: const Color(0xFF8D6E63)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('EEE').format(date),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat('d').format(date),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (isToday)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.3)
                                            : const Color(0xFF8D6E63)
                                                .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Today',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF8D6E63),
                                          fontFamily: 'Urbanist',
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Selected date display
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      width: double.infinity,
                      child: Text(
                        'Selected: ${DateFormat('EEEE, MMMM d, yyyy').format(selectedAppointmentDate)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Time slots selection
                    const Text(
                      'Available Time Slots',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Time slots grid layout
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: availableTimeSlots.map((timeSlot) {
                        final isSelected = selectedTimeSlot == timeSlot;

                        // Random availability for demo purposes
                        // In production, this would come from your backend
                        final bool isAvailable = math.Random().nextBool();

                        return GestureDetector(
                          onTap: isAvailable
                              ? () {
                                  setState(() {
                                    selectedTimeSlot = timeSlot;
                                  });
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF8D6E63)
                                  : isAvailable
                                      ? Colors.white
                                      : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF8D6E63)
                                    : isAvailable
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade200,
                              ),
                            ),
                            child: Text(
                              timeSlot,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : isAvailable
                                        ? Colors.black
                                        : Colors.grey.shade400,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),

                    // Duration reminder
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your session will last $selectedDuration minutes',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.amber.shade800,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Get.back();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isProcessing
                                ? null
                                : () async {
                                    // Set processing state to avoid multiple submissions
                                    setState(() {
                                      isProcessing = true;
                                    });

                                    // TODO: In a real app, get the actual user ID from authentication
                                    final userId =
                                        1; // Dummy user ID for testing

                                    // Calculate price based on duration
                                    final price =
                                        120 + (selectedDuration - 60) * 2;

                                    // Format date and time for better display
                                    final dateStr = DateFormat('MMMM d, yyyy')
                                        .format(selectedAppointmentDate);

                                    try {
                                      // Call API to book appointment
                                      final result =
                                          await _apiService.bookAppointment({
                                        'user_id': userId,
                                        'service_name': items[selectedItemIndex]
                                            ['name'],
                                        'service_category':
                                            title, // category name
                                        'appointment_date':
                                            DateFormat('yyyy-MM-dd').format(
                                                selectedAppointmentDate),
                                        'appointment_time': selectedTimeSlot,
                                        'duration': selectedDuration,
                                        'price': price.toDouble(),
                                      });

                                      // Close dialog
                                      Get.back();

                                      if (result['success']) {
                                        // Show success message
                                        Get.snackbar(
                                          'Success',
                                          'Appointment booked for $dateStr at $selectedTimeSlot',
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                          duration: const Duration(seconds: 3),
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      } else {
                                        // Show error message
                                        Get.snackbar(
                                          'Error',
                                          'Failed to book appointment: ${result['message']}',
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                          duration: const Duration(seconds: 3),
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      }
                                    } catch (e) {
                                      // Close dialog
                                      Get.back();

                                      // Show error message
                                      Get.snackbar(
                                        'Error',
                                        'Failed to book appointment: $e',
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                        duration: const Duration(seconds: 3),
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8D6E63),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Confirm',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _addToCart() async {
    // TODO: In a real app, get the actual user ID from authentication
    final userId = 1; // Dummy user ID for testing

    try {
      // Set product details
      final productName = items[selectedItemIndex]['name'];
      final price = 45.0; // Fixed price for products in the demo

      // Call API to add to cart
      final result = await _apiService.addToCart({
        'user_id': userId,
        'product_name': productName,
        'product_category': title, // category name
        'quantity': quantity,
        'price': price,
        'image_path': items[selectedItemIndex]['image'],
      });

      if (result['success']) {
        // Show success message
        Get.snackbar(
          'Success',
          '$productName added to your cart',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        // Show error message
        Get.snackbar(
          'Error',
          'Failed to add to cart: ${result['message']}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to add to cart: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
