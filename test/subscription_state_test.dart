import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softlightstudio/models/subscription_state.dart';

void main() {
  setUp(() {
    // Initialize fake shared preferences for testing
    SharedPreferences.setMockInitialValues({});
  });

  group('SubscriptionState', () {
    test('initializes with defaults', () async {
      final state = SubscriptionState();
      await state.initialize();

      expect(state.onboardingCompleted, false);
      expect(state.subscriptionType, SubscriptionType.none);
      expect(state.isPremium, false);
      expect(state.hasAds, false);
    });

    test('completes onboarding', () async {
      final state = SubscriptionState();
      await state.initialize();
      await state.completeOnboarding();

      expect(state.onboardingCompleted, true);
    });

    test('sets subscription to premium', () async {
      final state = SubscriptionState();
      await state.initialize();
      await state.setSubscriptionType(SubscriptionType.premium);

      expect(state.subscriptionType, SubscriptionType.premium);
      expect(state.isPremium, true);
      expect(state.hasAds, false);
    });

    test('sets subscription to ads', () async {
      final state = SubscriptionState();
      await state.initialize();
      await state.setSubscriptionType(SubscriptionType.ads);

      expect(state.subscriptionType, SubscriptionType.ads);
      expect(state.isPremium, false);
      expect(state.hasAds, true);
    });

    test('persists state across instances', () async {
      // First instance - set state
      final state1 = SubscriptionState();
      await state1.initialize();
      await state1.completeOnboarding();
      await state1.setSubscriptionType(SubscriptionType.premium);

      // Second instance - verify persisted state
      final state2 = SubscriptionState();
      await state2.initialize();

      expect(state2.onboardingCompleted, true);
      expect(state2.subscriptionType, SubscriptionType.premium);
    });

    test('resets state', () async {
      final state = SubscriptionState();
      await state.initialize();
      await state.completeOnboarding();
      await state.setSubscriptionType(SubscriptionType.premium);

      await state.reset();

      expect(state.onboardingCompleted, false);
      expect(state.subscriptionType, SubscriptionType.none);
    });
  });
}
