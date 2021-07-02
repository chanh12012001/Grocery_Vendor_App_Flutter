import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grocery_vendor_app_flutter/screens/banner_screen.dart';
import 'package:grocery_vendor_app_flutter/screens/coupon_screen.dart';
import 'package:grocery_vendor_app_flutter/screens/login_screen.dart';
import 'package:grocery_vendor_app_flutter/screens/order_screen.dart';
import 'package:grocery_vendor_app_flutter/screens/product_screen.dart';

class DrawerServices{

  BuildContext context;

  Widget drawerScreen(title,context){
    if(title == 'Sản phẩm'){
      return ProductScreen();
    }
    if(title == 'Quảng cáo'){
      return BannerScreen();
    }
    if(title == 'Mã giảm giá'){
      return CouponScreen();
    }
    if(title == 'Đơn đặt hàng'){
      return OrderScreen();
    }
    if(title == 'Đăng xuất'){
      SchedulerBinding.instance.addPostFrameCallback((_) {
        FirebaseAuth.instance.signOut().then((value) {
          FirebaseAuth.instance.authStateChanges().listen((User user) {
            if(user==null){
              return Navigator.pushReplacementNamed(context, LoginScreen.id);
            }
          });
        });
        Navigator.push(context, new MaterialPageRoute(
                builder: (context) => LoginScreen()));
      });
    }
    return ProductScreen();
  }
}