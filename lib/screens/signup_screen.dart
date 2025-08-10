import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taxi_app/controllers/user_provider.dart';
import 'package:taxi_app/screens/login_screen.dart';
import 'package:taxi_app/screens/widgets/error_message.dart';
import 'package:taxi_app/screens/widgets/input_decorator.dart';
import 'package:taxi_app/services/auth_service.dart';
import 'package:taxi_app/services/role_based_auth_gate.dart';
import 'package:taxi_app/utils/colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final signupKey = GlobalKey<FormState>();
  final authService = AuthService();
  String role = 'rider';

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String localErrorMessage = '';
  bool isLoading = false;

  bool obscurePassword = true;
  bool obscureRePassword = true;
  File? licenseImage;

  Future<void> pickLicenseImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        licenseImage = File(picked.path);
      });
    }
  }

  void resetLicenseImage() {
    setState(() {
      licenseImage = null;
    });
  }

  void signUp() async {
    setState(() {
      isLoading = true;
      localErrorMessage = '';
    });

    if (!mounted) return;
    final userProvider = Provider.of<ProfileProvider>(context, listen: false);
    try {
      await authService.signUpWithEmailPassword(
        email: emailController.text,
        password: passwordController.text,
        fullName: nameController.text,
        role: role,
      );

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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
      ),
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
                  'REGISTER',
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
                    key: signupKey,
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    child: Column(
                      children: [
                        Theme(
                          data: ThemeData.light(), // 👈 forces light theme
                          child: DropdownButtonFormField<String>(
                            value: role,
                            decoration: const InputDecoration(
                              labelText: "Use App as",
                            ),
                            style: TextStyle(
                              color: Colors.black87, // Text color
                              fontSize: 14, // Font size
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'rider',
                                child: Text('Rider'),
                              ),
                              DropdownMenuItem(
                                value: 'driver',
                                child: Text('Driver'),
                              ),
                            ],
                            onChanged: (val) => setState(() => role = val!),
                          ),
                        ),

                        const SizedBox(height: 12),
                        TextFormField(
                          controller: nameController,
                          decoration: inputDecoration(
                            context: context,
                            useTheme: false,
                            hint: 'Username',
                            prefixIcon: Ph.user_thin,
                          ),
                          style: TextStyle(
                            color: Colors.black87, // Text color
                            fontSize: 14, // Font size
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val != null && val.isEmpty) {
                              return 'Username cannot be empty';
                            }
                            if (val != null && val.length < 3) {
                              return 'Username must be at least 3 characterrs.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: emailController,
                          style: TextStyle(
                            color: Colors.black87, // Text color
                            fontSize: 14, // Font size
                          ),
                          decoration: inputDecoration(
                            context: context,
                            useTheme: false,
                            hint: 'Email',
                            prefixIcon: Ion.ios_email_outline,
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (val) =>
                              val!.isEmpty ? "Enter email" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: passwordController,
                          style: TextStyle(
                            color: Colors.black87, // Text color
                            fontSize: 14, // Font size
                          ),
                          decoration:
                              inputDecoration(
                                context: context,
                                useTheme: false,
                                hint: 'Password',
                                prefixIcon: Ph.password_thin,
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
                          obscureText: obscurePassword,
                          validator: (val) =>
                              val!.length < 8 ? "Min 8 characters" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: confirmPasswordController,
                          style: TextStyle(
                            color: Colors.black87, // Text color
                            fontSize: 14, // Font size
                          ),
                          decoration:
                              inputDecoration(
                                context: context,
                                useTheme: false,
                                hint: 'Confirm Password',
                                prefixIcon: Ph.password_thin,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                    () =>
                                        obscureRePassword = !obscureRePassword,
                                  ),
                                  icon: obscureRePassword
                                      ? const Icon(Icons.visibility_off)
                                      : const Icon(Icons.visibility),
                                  color: const Color(0XFF757575),
                                ),
                              ),
                          obscureText: obscureRePassword,
                          validator: (value) {
                            if (value != null && value.length < 8) {
                              return 'Enter min. 8 characters';
                            } else if (passwordController.text.trim() !=
                                confirmPasswordController.text.trim()) {
                              return "Your passwords do NOT match";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00009A),
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
                                  final isValidForm = signupKey.currentState!
                                      .validate();
                                  if (isValidForm) {
                                    signUp();
                                  }
                                },
                          child: const Text("Sign Up"),
                        ),
                        const SizedBox(height: 10),
                        if (localErrorMessage != '') ...[
                          ErrorMessageWidget(
                            localErrorMessage: localErrorMessage,
                          ),
                          const SizedBox(height: 10),
                        ],
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Already have an account? Sign in",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        // SocialLogin(),
                      ],
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
