import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Subscription types available in the app
enum SubscriptionType {
  none,
  premium,
  ads,
}

/// Manages subscription and onboarding state
class SubscriptionState extends ChangeNotifier {
  static const String _onboardingKey = 'onboarding_completed';
  static const String _subscriptionKey = 'subscription_type';

  bool _onboardingCompleted = false;
  SubscriptionType _subscriptionType = SubscriptionType.none;

  bool get onboardingCompleted => _onboardingCompleted;
  SubscriptionType get subscriptionType => _subscriptionType;
  bool get isPremium => _subscriptionType == SubscriptionType.premium;
  bool get hasAds => _subscriptionType == SubscriptionType.ads;

  /// Initialize and load saved state
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingCompleted = prefs.getBool(_onboardingKey) ?? false;
    final typeIndex = prefs.getInt(_subscriptionKey) ?? 0;
    _subscriptionType = SubscriptionType.values[typeIndex];
    notifyListeners();
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    _onboardingCompleted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    notifyListeners();
  }

  /// Set subscription type
  Future<void> setSubscriptionType(SubscriptionType type) async {
    _subscriptionType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_subscriptionKey, type.index);
    notifyListeners();
  }

  /// Reset onboarding and subscription (for testing)
  Future<void> reset() async {
    _onboardingCompleted = false;
    _subscriptionType = SubscriptionType.none;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
    await prefs.remove(_subscriptionKey);
    notifyListeners();
  }
}
