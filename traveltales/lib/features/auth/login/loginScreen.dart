import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/app_flushbar.dart';
import 'package:traveltales/core/ui/components/textField/emailTextField.dart';
import 'package:traveltales/core/ui/components/textField/passwordTextField.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';
import 'package:traveltales/features/auth/login/authProvider.dart';

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
  bool _hasHandledRouteMessage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasHandledRouteMessage) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final successMessage = args['successMessage'];
      if (successMessage is String && successMessage.trim().isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          AppFlushbar.success(context, successMessage);
        });
      }
    }

    _hasHandledRouteMessage = true;
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.loginUser(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (!success) {
      AppFlushbar.error(
        context,
        authProvider.errorMessage ?? '',
        fallbackMessage: "Check your email and password and try again",
      );
      return;
    }

    if (authProvider.role == "company") {
      Navigator.pushReplacementNamed(
        context,
        RouteName.companyDashboardScreen,
      );
    } else if (authProvider.role == "admin") {
      Navigator.pushReplacementNamed(
        context,
        RouteName.adminDashboardScreen,
      );
    } else {
      if (authProvider.hasCompletedPreference) {
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
  Widget build(BuildContext context,) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;

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
                                enabled: !isLoading,
                                labelText: SharedRes.strings(context).email,
                                hintText: SharedRes.strings(context).enterEmail,

                              ),

                              const SizedBox(height: 24),

                              PasswordTextField(
                                controller: _passwordController,
                                enabled: !isLoading,
                                labelText: SharedRes.strings(context).password,
                                hintText: SharedRes.strings(context).enterPassword,
                              ),

                              const SizedBox(height: 24),

                              AppButton(
                                text: isLoading
                                    ? "Loading..."
                                    : SharedRes.strings(context).login,
                                onPressed: isLoading ? null : _submit,
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
                                      onPressed: isLoading
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
