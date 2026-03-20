import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await login(email, password);

      final String role = result["roles"];
      final bool hasCompletedPreference = result["has_completed_preference"];

      if (!mounted) return;

      if (role == "company") {
        Navigator.pushReplacementNamed(
          context,
          RouteName.companyDashboardScreen,
        );
      } else if(role == "admin"){
        Navigator.pushReplacementNamed(
          context,
          RouteName.adminDashboardScreen,
        );
      }
      else {
        if (hasCompletedPreference) {
          Navigator.pushReplacementNamed(
            context,
            RouteName.dashBoardScreen,
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            RouteName.preferenceScreen,
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Check your email and password and try again"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double _getWelcomeFontSize(bool isWideScreen) {
    if (isWideScreen) return 54;
    return compactDimens.medium1;
  }

  double _getLogoWidth(bool isWideScreen) {
    if (isWideScreen) return 220;
    return 200.w;
  }

  double _getTopSpacing(bool isWideScreen) {
    if (isWideScreen) return 48;
    return 120.h;
  }

  double _getMaxContentWidth(bool isWideScreen) {
    if (isWideScreen) return 420;
    return double.infinity;
  }

  EdgeInsets _getHorizontalPadding(bool isWideScreen) {
    if (isWideScreen) {
      return const EdgeInsets.symmetric(horizontal: 24);
    }
    return EdgeInsets.symmetric(horizontal: compactDimens.small3);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !kIsWeb,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (!kIsWeb) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWideScreen = constraints.maxWidth >= 700;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: _getMaxContentWidth(isWideScreen),
                      ),
                      child: Padding(
                        padding: _getHorizontalPadding(isWideScreen),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: _getTopSpacing(isWideScreen)),

                              Center(
                                child: Image.asset(
                                  'assets/images/TravelTalesFull.png',
                                  width: _getLogoWidth(isWideScreen),
                                  fit: BoxFit.contain,
                                ),
                              ),

                              const SizedBox(height: 32),

                              Text(
                                SharedRes.strings(context).welcome,
                                textAlign: TextAlign.left,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  fontSize: _getWelcomeFontSize(isWideScreen),
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),

                              const SizedBox(height: 32),

                              EmailTextField(
                                controller: _emailController,
                                enabled: !_isLoading,
                                labelText: SharedRes.strings(context).email,
                                hintText: SharedRes.strings(context).enterEmail,

                              ),

                              const SizedBox(height: 24),

                              PasswordTextField(
                                controller: _passwordController,
                                enabled: !_isLoading,
                                labelText: SharedRes.strings(context).password,
                                hintText: SharedRes.strings(context).enterPassword,
                              ),

                              const SizedBox(height: 24),

                              AppButton(
                                text: _isLoading
                                    ? "Loading..."
                                    : SharedRes.strings(context).login,
                                onPressed: _isLoading ? null : _submit,
                              ),

                              const SizedBox(height: 12),

                              Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      SharedRes.strings(context).noAccount,
                                      style: TextStyle(
                                        fontSize: isWideScreen
                                            ? 16
                                            : compactDimens.middle1,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () {
                                        Navigator.pushNamed(
                                          context,
                                          AuthRouteName.signupScreen,
                                        );
                                      },
                                      child: Text(
                                        SharedRes.strings(context).signup,
                                        style: const TextStyle(
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: isWideScreen ? 32 : 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}