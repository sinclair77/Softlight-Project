// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softlightstudio/models/subscription_state.dart';

import 'package:softlightstudio/main.dart';

void main() {
  setUp(() {
    // Initialize fake shared preferences for testing
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App loads and shows onboarding on first launch',
      (WidgetTester tester) async {
    // Create a fresh subscription state
    final subscriptionState = SubscriptionState();
    await subscriptionState.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(SoftlightStudioApp(subscriptionState: subscriptionState));
    await tester.pumpAndSettle();

    // Verify that onboarding appears
    expect(find.text('PROFESSIONAL PHOTO EDITING'), findsOneWidget);
  });

  testWidgets('App shows main screen after onboarding',
      (WidgetTester tester) async {
    // Create subscription state and mark onboarding as completed
    final subscriptionState = SubscriptionState();
    await subscriptionState.initialize();
    await subscriptionState.completeOnboarding();
    await subscriptionState.setSubscriptionType(SubscriptionType.premium);

    // Build our app and trigger a frame.
    await tester.pumpWidget(SoftlightStudioApp(subscriptionState: subscriptionState));
    await tester.pumpAndSettle();

    // Verify that the main app appears
    expect(find.text('SOFTLIGHT STUDIO'), findsOneWidget);
  });
}
