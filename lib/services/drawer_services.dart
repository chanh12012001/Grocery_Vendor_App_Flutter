import 'package:flutter/cupertino.dart';
import 'package:grocery_vendor_app_flutter/screens/add_edit_coupon_screen.dart';
import 'package:grocery_vendor_app_flutter/screens/banner_screen.dart';
import 'package:grocery_vendor_app_flutter/screens/coupon_screen.dart';
import 'package:grocery_vendor_app_flutter/screens/dashboard_screen.dart';
import 'package:grocery_vendor_app_flutter/screens/order_screen.dart';
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
    if(title == 'Mã giảm giá') {
      return CouponScreen();
    }

    if(title == 'Đơn đặt hàng') {
      return OrderScreen();
    }
    return MainScreen();
  }
}