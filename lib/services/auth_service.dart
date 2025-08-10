import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taxi_app/controllers/user_provider.dart';
import 'package:taxi_app/models/profile.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      password: password,
      email: email,
    );
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    return await _supabase.auth
        .signUp(password: password, email: email)
        .then(
          (val) async => await _supabase.from('profiles').insert({
            'id': val.user?.id,
            'display_name': fullName,
            'role': role,
          }),
        );
  }

  // Sign out
  Future<void> signOut(BuildContext context) async {
    await _supabase.auth.signOut();
    if (context.mounted) {
      Provider.of<ProfileProvider>(context, listen: false).clearProfile();
    }
  }

  // Get user email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  // Get user profile
  Future<Profile?> getMyProfile() async {
    final res = await _supabase
        .from('profiles')
        .select()
        .eq('id', _supabase.auth.currentUser!.id)
        .single();

    Profile profile = Profile.fromMap(res);

    return profile;
  }
}
