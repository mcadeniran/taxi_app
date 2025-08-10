import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taxi_app/controllers/user_provider.dart';
import 'package:taxi_app/screens/social_login.dart';
import 'package:taxi_app/screens/widgets/error_message.dart';
import 'package:taxi_app/screens/widgets/input_decorator.dart';
import 'package:taxi_app/services/auth_service.dart';
import 'package:taxi_app/services/role_based_auth_gate.dart';
import 'package:taxi_app/utils/colors.dart';

import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final signInKey = GlobalKey<FormState>();
  final authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String localErrorMessage = '';
  bool isLoading = false;

  bool obscurePassword = true;

  void showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (_) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("Reset Password"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Enter your email"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Reset link sent (placeholder)"),
                  ),
                );
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void login() async {
    setState(() {
      isLoading = true;
      localErrorMessage = '';
    });
    final email = emailController.text;
    final password = passwordController.text;
    final userProvider = Provider.of<ProfileProvider>(context, listen: false);

    try {
      await authService.signInWithEmailPassword(email, password);
      await userProvider.refreshProfile();

      if (!mounted) return;

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => RoleBasedAuthGate()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = "An unexpected error occurred";

        if (e is AuthException) {
          errorMessage = e.message;
          if (e.code == 'invalid_credentials') {
            errorMessage = 'Invalid email or password';
          }
        } else if (e is PostgrestException) {
          errorMessage = "An unexpected error occurred";
        } else {
          errorMessage = "An unexpected error occurred";
        }
        setState(() {
          isLoading = false;
          localErrorMessage = errorMessage;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
      ),

      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Hero(
                  tag: 'AuthLogo',
                  child: Image.asset('assets/images/IMG_0529.PNG', height: 120),
                ),

                const SizedBox(height: 20),
                Text(
                  'WELCOME BACK',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    key: signInKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          textInputAction: TextInputAction.next,
                          validator: (email) {
                            if (email != null &&
                                !EmailValidator.validate(email)) {
                              return 'Enter a valid email';
                            } else {
                              return null;
                            }
                          },
                          style: TextStyle(
                            color: Colors.black87, // Text color
                            fontSize: 14, // Font size
                          ),
                          decoration: inputDecoration(
                            context: context,
                            hint: 'Email',
                            prefixIcon: Ion.ios_email_outline,
                            useTheme: false,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value != null && value.length < 8) {
                              return 'Enter min. 8 characters';
                            } else {
                              return null;
                            }
                          },
                          style: TextStyle(
                            color: Colors.black87, // Text color
                            fontSize: 14, // Font size
                          ),
                          decoration:
                              inputDecoration(
                                context: context,
                                hint: 'Password',
                                prefixIcon: Ph.password_thin,
                                useTheme: false,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                    () => obscurePassword = !obscurePassword,
                                  ),
                                  icon: obscurePassword
                                      ? const Icon(Icons.visibility_off)
                                      : const Icon(Icons.visibility),
                                  color: const Color(0XFF757575),
                                ),
                              ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: showForgotPasswordDialog,
                            child: const Text("Forgot Password?"),
                          ),
                        ),
                        // const SizedBox(height: 10),
                        if (localErrorMessage != '') ...[
                          ErrorMessageWidget(
                            localErrorMessage: localErrorMessage,
                          ),
                          const SizedBox(height: 10),
                        ],
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.5),
                            disabledForegroundColor: Colors.white54,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  final isValidForm = signInKey.currentState!
                                      .validate();
                                  if (isValidForm) {
                                    login();
                                  }
                                },
                          child: const Text('Login'),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Don't have an account? Sign up",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SocialLogin(),
                      ],
                    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
