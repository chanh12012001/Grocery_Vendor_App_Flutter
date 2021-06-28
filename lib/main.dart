import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app_flutter/providers/auth_provider.dart';
import 'package:grocery_vendor_app_flutter/providers/product_provider.dart';
import 'package:grocery_vendor_app_flutter/screens/add_new_product_screen.dart';
import 'package:grocery_vendor_app_flutter/screens/home_screen.dart';
import 'package:grocery_vendor_app_flutter/screens/login_screen.dart';
import 'package:grocery_vendor_app_flutter/screens/register_screen.dart';
import 'package:grocery_vendor_app_flutter/screens/reset_password_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Provider.debugCheckInvalidValueType = null;
  runApp(MultiProvider(
    providers: [
      Provider(create: (_) => AuthProvider()),
      Provider(create: (_) => ProductProvider()),
    ],
    child: MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Color(0xFF84c225),
            fontFamily: 'Lato'
        ),
        builder: EasyLoading.init(),
        initialRoute: SplashScreen.id,
        routes: {
          SplashScreen.id : (context) => SplashScreen(),
          RegisterScreen.id : (context) => RegisterScreen(),
          HomeScreen.id : (context) => HomeScreen(),
          LoginScreen.id : (context) => LoginScreen(),
          ResetPassword.id : (context) => ResetPassword(),
          AddNewProduct.id : (context) => AddNewProduct(),
        }
    );
  }
}
