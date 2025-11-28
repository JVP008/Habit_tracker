import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';
import 'package:habit_tracker/src/core/database/database_service.dart';

class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  final Logger _logger = Logger();
  final DatabaseService _dbService = DatabaseService();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product IDs
  static const String _monthlyPremiumId = 'zenflow_premium_monthly';
  static const String _yearlyPremiumId = 'zenflow_premium_yearly';
  static const String _lifetimePremiumId = 'zenflow_premium_lifetime';

  // Premium features
  static const List<String> premiumFeatures = [
    'Unlimited habits',
    'Advanced analytics and insights',
    'Custom themes and layouts',
    'Priority customer support',
    'Export data functionality',
    'Ad-free experience',
    'Advanced reminders',
    'Social features',
    'Cloud sync',
    'Early access to new features',
  ];

  bool _isInitialized = false;
  List<ProductDetails> _products = [];

  /// Initialize the premium service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Check if in-app purchases are available
      final bool isAvailable = await _inAppPurchase.isAvailable();
      if (!isAvailable) {
        _logger.w('In-app purchases not available on this device');
        return false;
      }

      // Listen to purchase updates
      _subscription = _inAppPurchase.purchaseStream.listen(
        _listenToPurchaseUpdated,
        onDone: () => _logger.i('Purchase stream closed'),
        onError: (error) => _logger.e('Purchase stream error: $error'),
      );

      // Load products
      await _loadProducts();

      // Restore previous purchases
      await _restorePurchases();

      _isInitialized = true;
      _logger.i('Premium service initialized successfully');
      return true;
    } catch (e) {
      _logger.e('Failed to initialize premium service: $e');
      return false;
    }
  }

  /// Load available products
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails({
            _monthlyPremiumId,
            _yearlyPremiumId,
            _lifetimePremiumId,
          });

      if (response.notFoundIDs.isNotEmpty) {
        _logger.w('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      _logger.i('Loaded ${_products.length} products');
    } catch (e) {
      _logger.e('Failed to load products: $e');
    }
  }

  /// Restore previous purchases
  Future<void> _restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      _logger.e('Failed to restore purchases: $e');
    }
  }

  /// Listen to purchase updates
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// Handle a purchase
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    try {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _logger.i('Purchase pending: ${purchaseDetails.productID}');
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _completePurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          _logger.e('Purchase error: ${purchaseDetails.error}');
          break;
        case PurchaseStatus.canceled:
          _logger.i('Purchase canceled: ${purchaseDetails.productID}');
          break;
      }
    } catch (e) {
      _logger.e('Error handling purchase: $e');
    }
  }

  /// Complete a purchase
  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    try {
      // Verify purchase with platform stores (Apple/Google)
      final bool isValid = await _verifyPurchase(purchaseDetails);

      if (isValid) {
        // Update user's premium status
        await _grantPremiumAccess(purchaseDetails);

        // Complete the purchase
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }

        _logger.i('Purchase completed: ${purchaseDetails.productID}');
      } else {
        _logger.e('Purchase verification failed: ${purchaseDetails.productID}');
      }
    } catch (e) {
      _logger.e('Error completing purchase: $e');
    }
  }

  /// Verify purchase with platform stores
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      // In a real app, you would verify the purchase receipt with Apple/Google servers
      // For now, we'll accept all purchases (you should implement proper verification)

      if (Platform.isIOS) {
        // Verify with Apple App Store
        return await _verifyApplePurchase(purchaseDetails);
      } else if (Platform.isAndroid) {
        // Verify with Google Play Store
        return await _verifyGooglePurchase(purchaseDetails);
      }

      return false;
    } catch (e) {
      _logger.e('Purchase verification error: $e');
      return false;
    }
  }

  /// Verify Apple purchase
  Future<bool> _verifyApplePurchase(PurchaseDetails purchaseDetails) async {
    // Implement Apple receipt verification
    // You would send the receipt data to Apple's servers for verification
    // For now, return true (you should implement proper verification)
    return true;
  }

  /// Verify Google purchase
  Future<bool> _verifyGooglePurchase(PurchaseDetails purchaseDetails) async {
    // Implement Google Play receipt verification
    // You would send the purchase token to Google Play for verification
    // For now, return true (you should implement proper verification)
    return true;
  }

  /// Grant premium access to user
  Future<void> _grantPremiumAccess(PurchaseDetails purchaseDetails) async {
    try {
      // Get current user (you'd get this from your auth service)
      final userId = 'current_user_id'; // Replace with actual user ID

      final db = _dbService.db;

      // Calculate subscription expiry
      DateTime? expiryDate;
      if (purchaseDetails.productID == _monthlyPremiumId) {
        expiryDate = DateTime.now().add(const Duration(days: 30));
      } else if (purchaseDetails.productID == _yearlyPremiumId) {
        expiryDate = DateTime.now().add(const Duration(days: 365));
      }
      // Lifetime doesn't expire

      // Update user's premium status
      await db.update(
        'users',
        {
          'is_premium': 1,
          'subscription_expiry': expiryDate?.millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      // Store purchase record
      await db.insert('purchases', {
        'user_id': userId,
        'product_id': purchaseDetails.productID,
        'purchase_token': purchaseDetails.purchaseID,
        'purchase_date': DateTime.now().millisecondsSinceEpoch,
        'expiry_date': expiryDate?.millisecondsSinceEpoch,
        'status': 'active',
      });

      _logger.i('Premium access granted to user $userId');
    } catch (e) {
      _logger.e('Failed to grant premium access: $e');
    }
  }

  /// Purchase premium subscription
  Future<bool> purchasePremium(String productId) async {
    if (!_isInitialized) await initialize();

    try {
      final ProductDetails product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found: $productId'),
      );

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (success) {
        _logger.i('Purchase initiated for $productId');
        return true;
      } else {
        _logger.w('Purchase failed for $productId');
        return false;
      }
    } catch (e) {
      _logger.e('Error purchasing premium: $e');
      return false;
    }
  }

  /// Check if user has premium access
  Future<bool> isUserPremium(String userId) async {
    try {
      final db = _dbService.db;

      final users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        columns: ['is_premium', 'subscription_expiry'],
        limit: 1,
      );

      if (users.isEmpty) return false;

      final user = users.first;
      final isPremium = user['is_premium'] as int? ?? 0;

      if (isPremium == 0) return false;

      // Check if subscription has expired
      final expiryTimestamp = user['subscription_expiry'] as int?;
      if (expiryTimestamp == null) return true; // Lifetime subscription

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      return expiryDate.isAfter(DateTime.now());
    } catch (e) {
      _logger.e('Error checking premium status: $e');
      return false;
    }
  }

  /// Get available premium products
  List<ProductDetails> getAvailableProducts() {
    return _products;
  }

  /// Get premium features
  List<String> getPremiumFeatures() {
    return premiumFeatures;
  }

  /// Get subscription pricing
  Map<String, String> getSubscriptionPricing() {
    final pricing = <String, String>{};

    for (final product in _products) {
      pricing[product.id] = product.price;
    }

    return pricing;
  }

  /// Cancel premium subscription
  Future<bool> cancelPremiumSubscription(String userId) async {
    try {
      // In a real app, you would handle subscription cancellation through the platform
      // For now, we'll just update the database

      final db = _dbService.db;

      await db.update(
        'users',
        {
          'is_premium': 0,
          'subscription_expiry': null,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      _logger.i('Premium subscription cancelled for user $userId');
      return true;
    } catch (e) {
      _logger.e('Error cancelling premium subscription: $e');
      return false;
    }
  }

  /// Get purchase history for user
  Future<List<PurchaseRecord>> getPurchaseHistory(String userId) async {
    try {
      final db = _dbService.db;

      final purchases = await db.query(
        'purchases',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'purchase_date DESC',
      );

      return purchases
          .map(
            (purchase) => PurchaseRecord(
              productId: purchase['product_id'] as String,
              purchaseDate: DateTime.fromMillisecondsSinceEpoch(
                purchase['purchase_date'] as int,
              ),
              expiryDate: purchase['expiry_date'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                      purchase['expiry_date'] as int,
                    )
                  : null,
              status: purchase['status'] as String,
            ),
          )
          .toList();
    } catch (e) {
      _logger.e('Error getting purchase history: $e');
      return [];
    }
  }

  /// Check if feature is available for user
  Future<bool> isFeatureAvailable(String userId, PremiumFeature feature) async {
    final isPremium = await isUserPremium(userId);

    if (isPremium) return true;

    // Check if feature is available for free users
    switch (feature) {
      case PremiumFeature.unlimitedHabits:
        return false; // Premium only
      case PremiumFeature.advancedAnalytics:
        return false; // Premium only
      case PremiumFeature.customThemes:
        return false; // Premium only
      case PremiumFeature.prioritySupport:
        return false; // Premium only
      case PremiumFeature.dataExport:
        return false; // Premium only
      case PremiumFeature.adFree:
        return false; // Premium only
      case PremiumFeature.advancedReminders:
        return false; // Premium only
      case PremiumFeature.socialFeatures:
        return true; // Available for free users
      case PremiumFeature.cloudSync:
        return false; // Premium only
      case PremiumFeature.earlyAccess:
        return false; // Premium only
    }
  }

  /// Dispose the service
  void dispose() {
    _subscription.cancel();
  }
}

// Premium features enum
enum PremiumFeature {
  unlimitedHabits,
  advancedAnalytics,
  customThemes,
  prioritySupport,
  dataExport,
  adFree,
  advancedReminders,
  socialFeatures,
  cloudSync,
  earlyAccess,
}

// Purchase record model
class PurchaseRecord {
  final String productId;
  final DateTime purchaseDate;
  final DateTime? expiryDate;
  final String status;

  const PurchaseRecord({
    required this.productId,
    required this.purchaseDate,
    this.expiryDate,
    required this.status,
  });
}
