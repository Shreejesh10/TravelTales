import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/textField/emailTextField.dart';
import 'package:traveltales/core/ui/components/textField/passwordTextField.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

import '../../../core/ui/components/button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
      await login(email, password);

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        RouteName.dashBoardScreen,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
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
                    child:
                    Image.asset(
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
                    enabled: true,
                    labelText: SharedRes.strings(context).email,
                    hintText: SharedRes.strings(context).enterEmail,
                  ),
                  const SizedBox(height: 24),
                  PasswordTextField(
                    controller: _passwordController,
                    enabled: true,
                    labelText: SharedRes.strings(context).password,
                    hintText: SharedRes.strings(context).enterPassword,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: SharedRes.strings(context).login,
                    onPressed: _submit
                  ),
                  const SizedBox(height: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        SharedRes.strings(context).noAccount,
                        style: TextStyle(
                          fontSize: compactDimens.middle1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                          onPressed: (){
                            Navigator.pushNamed(context, AuthRouteName.signupScreen);
                          },
                          child: Text(
                            SharedRes.strings(context).signup,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          )
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
