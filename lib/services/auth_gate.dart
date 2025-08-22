// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:taxi_app/screens/login_screen.dart';
// import 'package:taxi_app/services/role_based_auth_gate.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: Supabase.instance.client.auth.onAuthStateChange,
//       builder: (context, snapshot) {
//         // Loading
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator.adaptive()),
//           );
//         }
//         final session = snapshot.hasData ? snapshot.data!.session : null;

//         if (session != null) {
//           return RoleBasedAuthGate();
//         } else {
//           return LoginScreen();
//         }
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taxi_app/screens/login_screen.dart';
import 'package:taxi_app/services/role_based_auth_gate.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still waiting for Firebase to give initial user state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          return const RoleBasedAuthGate();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
