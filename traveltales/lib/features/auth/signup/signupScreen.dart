import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/button.dart';
import 'package:traveltales/core/ui/components/textField/emailTextField.dart';
import 'package:traveltales/core/ui/components/textField/passwordTextField.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';

import '../../../core/ui/resources/theme/dimens.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await signup(email, password);

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AuthRouteName.loginScreen,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SignUp failed: $e")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 120.h),
                Center(
                  child: Image.asset(
                    'assets/images/TravelTalesFull.png',
                    width: compactDimens.loginImageSize,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      SharedRes.strings(context).welcome,
                      style: TextStyle(
                        fontSize: compactDimens.medium1,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                ),
                EmailTextField(
                  controller: _emailController,
                  labelText: SharedRes.strings(context).email,
                  hintText: SharedRes.strings(context).enterEmail,
                ),
                const SizedBox(height: 16),
                PasswordTextField(
                  controller: _passwordController,
                  labelText: SharedRes.strings(context).password,
                  hintText: SharedRes.strings(context).enterPassword,
                ),
                const SizedBox(height: 16),

                PasswordTextField(
                  controller: _confirmPasswordController,
                  labelText: SharedRes.strings(context).confirmPassword,
                  hintText: SharedRes.strings(context).enterConfirmPassword,
                  isConfirmPassword: true,
                  compareWithController: _passwordController,

                ),
                const SizedBox(height: 16),
                AppButton(text: SharedRes.strings(context).signup,
                    onPressed: _submit
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      SharedRes.strings(context).alreadyGotAnAccount,
                      style: TextStyle(
                        fontSize: compactDimens.middle1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                        onPressed: (){
                          Navigator.pushNamed(context,AuthRouteName.loginScreen);
                        },
                        child: Text(
                          SharedRes.strings(context).login,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        )
                    )
                  ],
                ),

              ],
            ),

          ),
        ),
      ),
    );
  }
}
