import 'package:flutter/material.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();

}
class LoginScreenState extends State<LoginScreen>{
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
        child:Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'lib/core/ui/resources/drawable/TravelTalesFull.png',
                    width: compactDimens.loginImageSize,
                  ),

                )
              ],
            ),


          ),
        )
    );
  }

}