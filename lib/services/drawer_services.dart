import 'package:flutter/cupertino.dart';
import 'package:grocery_vendor_app_flutter/screens/banner_screen.dart';
import 'package:grocery_vendor_app_flutter/screens/dashboard_screen.dart';
import 'package:grocery_vendor_app_flutter/screens/product_screen.dart';

class DrawerServices{
  Widget drawerScreen(title) {
    if(title == 'Dashboard') {
      return MainScreen();
    }
    if(title == 'Sản phẩm') {
      return ProductScreen();
    }
    if(title == 'Quảng cáo') {
      return BannerScreen();
    }
    return MainScreen();
  }
}