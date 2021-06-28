import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_vendor_app_flutter/providers/product_provider.dart';
import 'package:grocery_vendor_app_flutter/services/firebase_service.dart';
import 'package:grocery_vendor_app_flutter/widgets/category_list.dart';
import 'package:provider/provider.dart';

class EditViewProduct extends StatefulWidget {
  final String productId;
  EditViewProduct({this.productId});

  @override
  _EditViewProductState createState() => _EditViewProductState();
}

class _EditViewProductState extends State<EditViewProduct> {

  FirebaseServices _services = FirebaseServices();
  final _formKey = GlobalKey<FormState>();

  List<String> _collections = [
    'Sản phẩm đặc trưng',
    'Bán chạy nhất',
    'Được thêm gần đây'
  ];
  String dropdownValue;

  var _brandText = TextEditingController();
  var _skuText = TextEditingController();
  var _productNameText = TextEditingController();
  var _weightText = TextEditingController();
  var _priceText = TextEditingController();
  var _comparedPriceText = TextEditingController();
  var _descriptionText = TextEditingController();
  var _categoryTextController = TextEditingController();
  var _subCategoryTextController = TextEditingController();
  var _stockTextController = TextEditingController();
  var _lowStockTextController = TextEditingController();
  var _taxTextController = TextEditingController();
  DocumentSnapshot doc;
  double discount;
  String image;
  String categoryImage;
  File _image;
  bool _visible = false;
  bool _editing = true;

  @override
  void initState() {
    getProductDetails();
    super.initState();
  }

  Future<void> getProductDetails() async {
    _services.products.doc(widget.productId).get().then((DocumentSnapshot document) {
      if (document.exists){
        setState(() {
          doc = document;
          _brandText.text =document['brand'];
          _skuText.text =document['sku'];
          _productNameText.text =document['productName'];
          _weightText.text =document['weight'];
          _priceText.text =document['price'].toString();
          _comparedPriceText.text =document['comparedPrice'].toString();
          var difference = int.parse(_comparedPriceText.text) - double.parse(_priceText.text);
          discount = (difference / int.parse(_comparedPriceText.text)*100);
          image = document['productImage'];
          _descriptionText.text =document['description'];
          _categoryTextController.text =document['category']['mainCategory'];
          _subCategoryTextController.text =document['category']['subCategory'];
          dropdownValue =document['collection'];
          _stockTextController.text =document['stockQty'].toString();
          _lowStockTextController.text =document['lowStockQty'].toString();
          _taxTextController.text =document['tax'].toString();
          //categoryImage =document['categoryImage'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    var _provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        actions: [
          FlatButton(
            child: Text('Sửa', style: TextStyle(color: Colors.white),),
            onPressed: () {
              setState(() {
                _editing = false;
              });
            },
          ),
        ],
      ),
      bottomSheet: Container(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Text(
                    'Hủy bỏ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AbsorbPointer(
                absorbing: _editing,
                child: InkWell(
                  onTap: (){
                    if (_formKey.currentState.validate()){
                      EasyLoading.show(status: 'Đang lưu...');
                      if (_image != null) {
                        _provider.uploadProductImage(_image.path, _productNameText.text).then((url) {
                          if (url != null){
                            EasyLoading.dismiss();
                            _provider.updateProduct(
                              context: context,
                              productName: _productNameText.text,
                              weight: _weightText.text,
                              tax: double.parse(_taxTextController.text),
                              stockQty: int.parse(_stockTextController.text),
                              sku: _skuText.text,
                              price: double.parse(_priceText.text),
                              lowStockQty: int.parse(_lowStockTextController.text),
                              description: _descriptionText.text,
                              collection: dropdownValue,
                              brand: _brandText.text,
                              comparedPrice: int.parse(_comparedPriceText.text),
                              productId: widget.productId,
                              image: image,
                              category: _categoryTextController.text,
                              subCategory: _subCategoryTextController.text,
                              categoryImage: categoryImage,
                            );
                          }
                        });
                      } else {
                        _provider.updateProduct(
                          context: context,
                          productName: _productNameText.text,
                          weight: _weightText.text,
                          tax: double.parse(_taxTextController.text),
                          stockQty: int.parse(_stockTextController.text),
                          sku: _skuText.text,
                          price: double.parse(_priceText.text),
                          lowStockQty: int.parse(_lowStockTextController.text),
                          description: _descriptionText.text,
                          collection: dropdownValue,
                          brand: _brandText.text,
                          comparedPrice: int.parse(_comparedPriceText.text),
                          productId: widget.productId,
                          image: image,
                          category: _categoryTextController.text,
                          subCategory: _subCategoryTextController.text,
                          categoryImage: categoryImage,
                        );
                        EasyLoading.dismiss();
                      }
                      _provider.resetProvider();
                    }
                  },
                  child: Container(
                    color: Colors.pinkAccent,
                    child: Center(
                      child: Text(
                        'Lưu',
                        style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: doc == null ? Center(child: CircularProgressIndicator()) : Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ListView(
            children: [
              AbsorbPointer(
                absorbing: _editing,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width:80,
                          height: 30,
                          child: TextFormField(
                            controller: _brandText,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 10, right: 10),
                              hintText: 'Nhãn hiệu',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Theme.of(context).primaryColor.withOpacity(.1),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Mã: '),
                            Container(
                              width: 50,
                              child: TextFormField(
                                controller: _skuText,
                                style: TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                      child: TextFormField(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none
                        ),
                        controller: _productNameText,
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: TextFormField(
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none
                        ),
                        controller: _weightText,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 100,
                          child: TextFormField(
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                prefixText: '\VNĐ ',
                            ),
                            controller: _priceText,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(width: 30,),
                        Container(
                          width: 100,
                          child: TextFormField(
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                prefixText: '\VNĐ ',
                            ),
                            controller: _comparedPriceText,
                            style: TextStyle(fontSize: 15, decoration: TextDecoration.lineThrough),

                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.red
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Text('${discount.toStringAsFixed(0)}% OFF', style: TextStyle(color: Colors.white)),
                          ),
                        ),

                      ],
                    ),
                    Text(
                      'Bao gồm tất cả các loại thuế',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    InkWell(
                      onTap: (){
                        _provider.getProductImage().then((image) {
                          setState(() {
                            _image = image;
                          });
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _image != null
                            ? Image.file(_image, height: 300,)
                            : Image.network(image,height: 300,),
                      ),
                    ),
                    Text('Thông tin sản phẩm', style: TextStyle(fontSize: 20),),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: TextFormField(
                        maxLines: null,
                        controller: _descriptionText,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                        decoration: InputDecoration(border: InputBorder.none,),
                      ),
                    ),
                    Padding (
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Row(
                        children: [
                          Text(
                            'Danh mục',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: AbsorbPointer(
                              absorbing: true, //this will block user entering category name manually
                              child: TextFormField(
                                controller: _categoryTextController,
                                validator: (value) {
                                  if (value.isEmpty){
                                    return 'Vui lòng chọn tên danh mục';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    hintText: 'Không được chọn',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]
                                        )
                                    )
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: _editing ? false : true,
                            child: IconButton(
                              icon: Icon(Icons.edit_outlined),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context){
                                    return CategoryList();
                                  },
                                ).whenComplete(() {
                                  setState(() {
                                    _categoryTextController.text = _provider.selectedCategory;
                                    _visible = true;
                                  });
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _visible,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        child: Row(
                          children: [
                            Text(
                              'Danh mục phụ',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: AbsorbPointer(
                                absorbing: true,
                                child: TextFormField(
                                  controller: _subCategoryTextController,
                                  validator: (value) {
                                    if (value.isEmpty){
                                      return 'Vui lòng chọn tên danh mục phụ';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      hintText: 'Không được chọn',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey[300]
                                          )
                                      )
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit_outlined),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context){
                                    return SubCategoryList();
                                  },
                                ).whenComplete(() {
                                  setState(() {
                                    _subCategoryTextController.text = _provider.selectedSubCategory;
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Text('Bộ sưu tập', style: TextStyle(color: Colors.grey),),
                          SizedBox(width: 10,),
                          DropdownButton<String>(
                            hint: Text('Chọn bộ sưu tập'),
                            value: dropdownValue,
                            icon: Icon(Icons.arrow_drop_down),
                            onChanged: (String value) {
                              setState(() {
                                dropdownValue = value;
                              });
                            },
                            items: _collections.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text('Lưu trữ: '),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none
                            ),
                            controller: _stockTextController,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Hàng sắp hết: '),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none
                            ),
                            controller: _lowStockTextController,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Thuế (%):  '),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none
                            ),
                            controller: _taxTextController,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 60,)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
