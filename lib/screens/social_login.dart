import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SocialLogin extends StatelessWidget {
  const SocialLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('or login with'),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 10),
        SignInButton(Buttons.google, onPressed: () {}),
        const SizedBox(height: 10),
        SignInButton(Buttons.apple, onPressed: () {}),
      ],
    );
  }
}
