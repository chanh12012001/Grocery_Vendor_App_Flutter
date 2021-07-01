import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ProductProvider with ChangeNotifier {
  String selectedCategory;
  String selectedSubCategory;
  String categoryImage;
  File image;
  String pickerError;
  String shopName;
  String productUrl;

  selectCategory(mainCategory,categoryImage) {
    this.selectedCategory = mainCategory;
    this.categoryImage = categoryImage;
    notifyListeners();
  }

  selectSubCategory(selected) {
    this.selectedSubCategory = selected;
    notifyListeners();
  }

  getShopName(shopName){
    this.shopName = shopName;
    notifyListeners();
  }

  //-----------Reset Data-------------
  resetProvider(){
    this.selectedCategory = null;
    this.selectedSubCategory = null;
    this.categoryImage = null;
    this.image=null;
    this.productUrl = null;
    notifyListeners();
  }
  //-----------Reset Data-------------


  //--------------------Upload product image----------------------------
  Future<String> uploadProductImage(filePath, productName) async {
    File file = File(filePath); //Đường dẫn tệp tải lên
    var timeStamp = Timestamp.now().millisecondsSinceEpoch;

    FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      await _storage.ref('productImage/${this.shopName}/$productName$timeStamp').putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }
    //Sau khi tải tệp lên, cần đến đường dẫn url của tệp để lưu vào DB
    String downloadURL = await _storage
        .ref('productImage/${this.shopName}/$productName$timeStamp').getDownloadURL();
    this.productUrl = downloadURL;
    notifyListeners();
    return downloadURL;
  }
  //--------------------Upload product image----------------------------


  //--------------------Get product image----------------------------
  Future<File> getProductImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      this.image = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickerError = 'Không có ảnh nào được chọn.';
      print('Không có ảnh nào được chọn.');
      notifyListeners();
    }
    return this.image;
  }
  //--------------------Get product image----------------------------


  //----------------------------Dialog---------------------------------
  alertDialog({context, title, content}) {
    showCupertinoDialog(context: context, builder: (BuildContext context){
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(child: Text('OK'),onPressed: (){
            Navigator.pop(context);
          },),
        ],
      );
    });
  }
  //----------------------------Dialog---------------------------------


  //----------------------Save product data to firestore----------------------
  Future<void>saveProductDataToDb({productName, description, price, comparedPrice, collection, brand, sku, weight, tax, stockQty, lowStockQty, context}){
    var timeStamp = DateTime.now().microsecondsSinceEpoch; //dùng làm ID sản phẩm
    User user = FirebaseAuth.instance.currentUser;
    CollectionReference _products = FirebaseFirestore.instance.collection('products');
    try{
      _products.doc(timeStamp.toString()).set({
        'seller' : {'shopName' : this.shopName,'sellerUid' :user.uid },
        'productName' : productName,
        'description' : description,
        'price':price,
        'comparedPrice' : comparedPrice,
        'collection' : collection,
        'brand' : brand,
        'sku' : sku,
        'category' : {'mainCategory' : this.selectedCategory,'subCategory' : this.selectedSubCategory,'categoryImage' : this.categoryImage},
        'weight' : weight,
        'tax' : tax,
        'stockQty':stockQty,
        'lowStockQty' : lowStockQty,
        'published' : false,
        'productId' : timeStamp.toString(),
        'productImage' : this.productUrl
      });
      this.alertDialog(
        context: context,
        title: 'LƯU DỮ LIỆU',
        content: 'Lưu thành công chi tiết sản phẩm!',
      );
    }catch(e){
      this.alertDialog(
          context: context,
          title: 'LƯU DỮ LIỆU',
          content: '${e.toString()}'
      );

    }
    return null;
  }
  //----------------------Save product data to firestore----------------------


  //--------------------Update product data to firestore----------------------
  Future<void>updateProduct({productName, description, price, comparedPrice, collection, brand, sku, weight, tax, stockQty, lowStockQty, context, productId, image, category, subCategory, categoryImage,}){
    CollectionReference _products = FirebaseFirestore.instance.collection('products');
    try{
      _products.doc(productId).update({
        'productName' : productName,
        'description' : description,
        'price':price,
        'comparedPrice' : comparedPrice,
        'collection' : collection,
        'brand' : brand,
        'sku' : sku,
        'category' : {'mainCategory' : category,'subCategory' : subCategory,'categoryImage' : this.categoryImage ==null ? categoryImage : this.categoryImage},
        'weight' : weight,
        'tax' : tax,
        'stockQty':stockQty,
        'lowStockQty' : lowStockQty,
        'productImage' : this.productUrl ==null ? image : this.productUrl
      });
      this.alertDialog(
        context: context,
        title: 'LƯU DỮ LIỆU',
        content: 'Lưu thành công chi tiết sản phẩm!',
      );
    }catch(e){
      this.alertDialog(
          context: context,
          title: 'LƯU DỮ LIỆU',
          content: '${e.toString()}'
      );

    }
    return null;
  }
  //--------------------Update product data to firestore----------------------

}