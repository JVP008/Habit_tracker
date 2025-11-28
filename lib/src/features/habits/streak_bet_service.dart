import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class StreakBetService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Creates a new bet for a habit
  Future<void> createBet({
    required String habitId,
    required double amount,
    required String supervisorName,
    required String supervisorPhone, // For WhatsApp
  }) async {
    // Initialize Stripe
    // TODO: Replace with your actual Stripe Publishable Key
    Stripe.publishableKey = 'pk_test_YOUR_STRIPE_PUBLISHABLE_KEY';

    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _supabase.from('streak_bets').insert({
      'user_id': user.id,
      'habit_id': habitId,
      'amount': amount,
      'currency': 'inr', // Default to INR for now
      'supervisor_name': supervisorName,
      'supervisor_phone': supervisorPhone,
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Notify supervisor via WhatsApp
    final message =
        'Hey $supervisorName! I just bet ₹$amount that I will keep my streak for "$habitId". You are my supervisor. If I miss a day, I owe you!';
    final url =
        'https://wa.me/$supervisorPhone?text=${Uri.encodeComponent(message)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  /// Processes a lost streak (payment trigger)
  Future<void> processLostStreak(String betId, double amount) async {
    // 1. Create Payment Intent via Supabase Edge Function (mocked for now)
    // In production: call a cloud function to get client_secret
    const clientSecret = 'pi_mock_secret_123'; // Replace with real backend call

    // 2. Confirm Payment Sheet (Stripe)
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'ZenFlow StreakOrPay',
        style: ThemeMode.light,
      ),
    );

    await Stripe.instance.presentPaymentSheet();

    // 3. Update bet status
    await _supabase
        .from('streak_bets')
        .update({'status': 'paid'})
        .eq('id', betId);
  }

  /// Verifies proof (photo/text)
  Future<bool> verifyProof(String habitId, String proofPath) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false; // Or handle anonymous users

      // final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload to Supabase Storage
      // Ensure you have a bucket named 'proofs' created in your Supabase project
      /* 
      await _supabase.storage.from('proofs').upload(
        fileName,
        File(proofPath),
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      */

      // For now, we simulate success to avoid crashing if bucket doesn't exist
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      debugPrint('Proof upload failed: $e');
      return false; // Fail safe
    }
  }
}
