// lib/providers/profile_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  Profile? _profile;
  bool _isLoading = true;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;

  ProfileProvider() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _profile = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      _profile = Profile.fromMap(data);
    } catch (e) {
      _profile = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    _isLoading = true;
    notifyListeners();
    await _loadProfile();
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}
