import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class ProductProvider with ChangeNotifier{
  String selectedCategory;
  String selectedSubCategory;
  String categoryImage;
  File image;
  String pickerError;
  String shopName;
  String productUrl;

  selectCategory(mainCategory, categoryImage){
    this.selectedCategory = mainCategory;
    this.categoryImage = categoryImage;
    notifyListeners();
  }

  selectSubCategory(selected){
    this.selectedSubCategory = selected;
    notifyListeners();
  }

  getShopName(shopName) {
    this.shopName = shopName;
    notifyListeners();
  }

  resetProvider() {
    this.selectedCategory = null;
    this.selectedSubCategory = null;
    this.categoryImage = null;
    this.image = null;
    this.productUrl = null;
    notifyListeners();
  }

  Future<String> uploadProductImage(filePath, productName) async {
    File file = File(filePath);
    var timeStamp = Timestamp.now().millisecondsSinceEpoch;

    FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      await _storage.ref('productImage/${this.shopName}/$productName$timeStamp').putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e.code);
    }

    String downloadURL = await _storage
        .ref('productImage/${this.shopName}/$productName$timeStamp').getDownloadURL();
    this.productUrl = downloadURL;
    notifyListeners();
    return downloadURL;
  }

  Future<File> getProductImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      this.image = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickerError = 'Chưa chọn hình ảnh';
      notifyListeners();
    }
    return this.image;
  }

  aleftDialog({context, title, content}) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(child: Text('OK'), onPressed: () {
              Navigator.pop(context);
            },),
          ],
        );
      },
    );
  }


  //save product data to firestore
  Future<void> saveProductDataToDb({productName, description, price, comparedPrice, collection, brand, sku, weight, tax, stockQty, lowStockQty, context}){
    var timeStamp = DateTime.now().millisecondsSinceEpoch;
    User user = FirebaseAuth.instance.currentUser;

    CollectionReference _product = FirebaseFirestore.instance.collection('products');
    try{
      _product.doc(timeStamp.toString()).set({
        'seller' : {'shopName' : this.shopName, 'sellerUid' : user.uid},
        'productName' : productName,
        'description' : description,
        'price' : price,
        'comparedPrice' : comparedPrice,
        'collection' : collection,
        'brand' : brand,
        'sku' : sku,
        'category' : {'mainCategory' : this.selectedCategory, 'subCategory' : this.selectedSubCategory, 'categoryImage' : this.categoryImage},
        'weight' : weight,
        'tax' : tax,
        'stockQty' : stockQty,
        'lowStockQty' : lowStockQty,
        'published' : false,
        'productId' : timeStamp.toString(),
        'productImage' : this.productUrl
      });
      this.aleftDialog(
        context: context,
        title: 'Lưu dữ liệu',
        content: 'Chi tiết sản phẩm lưu thành công'
      );
    } catch(e) {
      this.aleftDialog(
          context: context,
          title: 'Lưu dữ liệu',
          content: '${e.toString()}'
      );
    }
    return null;
  }


  Future<void> updateProduct({
    productName,
    description,
    price,
    comparedPrice,
    collection,
    brand,
    sku,
    weight,
    tax,
    stockQty,
    lowStockQty,
    context,
    productId,
    image,
    category,
    subCategory,
    categoryImage}  ){
    CollectionReference _product = FirebaseFirestore.instance.collection('products');

    try{
      _product.doc(productId).update({
        'productName' : productName,
        'description' : description,
        'price' : price,
        'comparedPrice' : comparedPrice,
        'collection' : collection,
        'brand' : brand,
        'sku' : sku,
        'category' : {'mainCategory' :category, 'subCategory' : subCategory, 'categoryImage' : this.categoryImage == null ? categoryImage : this.categoryImage},
        'weight' : weight,
        'tax' : tax,
        'stockQty' : stockQty,
        'lowStockQty' : lowStockQty,
        'productImage' : this.productUrl == null ? image : this.productUrl
      });
      this.aleftDialog(
          context: context,
          title: 'Lưu dữ liệu',
          content: 'Chi tiết sản phẩm lưu thành công'
      );
    } catch(e) {
      this.aleftDialog(
          context: context,
          title: 'Lưu dữ liệu',
          content: '${e.toString()}'
      );
    }
    return null;
  }
}