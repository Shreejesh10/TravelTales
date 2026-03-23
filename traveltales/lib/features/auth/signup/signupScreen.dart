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
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool isCompany = false;
  List<bool> isSelected = [true, false]; // [User, Company]

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userName = _userNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final roles = isCompany ? "company" : "customer";


    try {
      await signup(email, password, userName, roles);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCompany
                ? "Your Account is undergoing review, wait till admin verify your account"
                : "User account created successfully",
          ),
        ),
      );

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
    final primary = Theme.of(context).colorScheme.primary;

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        SharedRes.strings(context).welcome,
                        style: TextStyle(
                          fontSize: compactDimens.medium1,
                          fontWeight: FontWeight.w500,
                          color: primary,
                        ),
                      ),

                      ToggleButtons(
                        isSelected: isSelected,
                        onPressed: (index) {
                          setState(() {
                            for (int i = 0; i < isSelected.length; i++) {
                              isSelected[i] = i == index;
                            }
                            isCompany = index == 1;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        selectedColor: Colors.white,
                        fillColor: primary,
                        color: primary,
                        constraints: BoxConstraints(
                          minHeight: 25.h,
                          minWidth: 40.w,
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: const Text("Customer"),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: const Text("Company"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                EmailTextField(
                  controller: _emailController,
                  labelText: SharedRes.strings(context).email,
                  hintText: SharedRes.strings(context).enterEmail,
                ),

                const SizedBox(height: 16),

                const Text(
                  "Username",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _userNameController,
                  decoration: const InputDecoration(
                    hintText: "Enter username",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Username is required";
                    }
                    return null;
                  },
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

                const SizedBox(height: 20),

                AppButton(
                  text: SharedRes.strings(context).signup,
                  onPressed: _submit,
                ),

                const SizedBox(height: 12),

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
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AuthRouteName.loginScreen,
                        );
                      },
                      child: Text(
                        SharedRes.strings(context).login,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
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