// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:taxi_app/controllers/user_provider.dart';
// import 'package:taxi_app/screens/customer_home.dart';
// import 'package:taxi_app/screens/driver_home.dart';
// import 'package:taxi_app/screens/login_screen.dart';

// class RoleBasedAuthGate extends StatelessWidget {
//   const RoleBasedAuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final profileProvider = Provider.of<ProfileProvider>(context);

//     if (profileProvider.isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator.adaptive()),
//       );
//     }

//     final profile = profileProvider.profile;

//     if (profile == null) {
//       return const LoginScreen();
//     }

//     return profile.role == 'driver' ? const DriverHome() : const CustomerHome();
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/profile_provider.dart';
import 'package:taxi_app/screens/customer_home.dart';
import 'package:taxi_app/screens/driver_home.dart';
import 'package:taxi_app/screens/login_screen.dart';

class RoleBasedAuthGate extends StatelessWidget {
  const RoleBasedAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    if (profileProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final profile = profileProvider.profile;

    if (profile == null) {
      return const LoginScreen();
    }

    return profile.role == 'driver' ? const DriverHome() : const CustomerHome();
  }
}
