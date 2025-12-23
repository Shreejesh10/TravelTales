import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child:
                  Image.asset(
                    'lib/core/ui/resources/drawable/TravelTalesFull.png',
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
                  onPressed: () {

                  },
                ),
                const SizedBox(height: 4),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      SharedRes.strings(context).dont_have_an_account,
                      style: TextStyle(
                        fontSize: compactDimens.middle1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                        onPressed: (){},
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
    );
  }
}
