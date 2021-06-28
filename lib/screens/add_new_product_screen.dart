import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_vendor_app_flutter/providers/product_provider.dart';
import 'package:grocery_vendor_app_flutter/widgets/category_list.dart';
import 'package:provider/provider.dart';

class AddNewProduct extends StatefulWidget {
  static const String id = 'addnewproduct-screen';

  @override
  _AddNewProductState createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {

  final _formKey = GlobalKey<FormState>();

  List<String> _collections = [
    'Sản phẩm đặc trưng',
    'Bán chạy nhất',
    'Được thêm gần đây'
  ];
  String dropdownValue;

  var _categoryTextController = TextEditingController();
  var _subCategoryTextController = TextEditingController();
  var _comparedPriceTextController = TextEditingController();
  var _brandTextController = TextEditingController();
  var _lowStockTextController = TextEditingController();
  var _stockTextController = TextEditingController();
  File _image;
  bool _visible = false;
  bool _track = false;

  String productName;
  String description;
  double price;
  double comparedPrice;
  String sku;
  String weight;
  double tax;

  @override
  Widget build(BuildContext context) {

    var _provider = Provider.of<ProductProvider>(context);

    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Material(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          child: Text('Sản phẩm / Thêm'),
                        ),
                      ),
                      FlatButton.icon(
                        color: Theme.of(context).primaryColor,
                        icon: Icon(Icons.save, color: Colors.white),
                        label: Text('Lưu', style: TextStyle(color: Colors.white),),
                        onPressed: () {
                          if (_formKey.currentState.validate()){
                            if (_categoryTextController.text.isNotEmpty){
                              if (_subCategoryTextController.text.isNotEmpty){
                                if (_image != null){
                                  EasyLoading.show(status: 'Đang lưu...');
                                  _provider.uploadProductImage(_image.path, productName).then((url) {
                                    if (url != null){
                                      //upload profuct data to firestore
                                      EasyLoading.dismiss();
                                      _provider.saveProductDataToDb(
                                        context: context,
                                        comparedPrice: int.parse(_comparedPriceTextController.text),
                                        brand: _brandTextController.text,
                                        collection: dropdownValue,
                                        description: description,
                                        lowStockQty: int.parse(_lowStockTextController.text),
                                        price: price,
                                        sku: sku,
                                        stockQty: int.parse(_stockTextController.text),
                                        tax: tax,
                                        weight: weight,
                                        productName: productName,
                                      );

                                      setState(() {
                                        //clear after save
                                        _formKey.currentState.reset();
                                        _comparedPriceTextController.clear();
                                        dropdownValue = null;
                                        _subCategoryTextController.clear();
                                        _categoryTextController.clear();
                                        _brandTextController.clear();
                                        _track = false;
                                        _image = null;
                                        _visible = false;
                                      });

                                    } else {
                                      _provider.aleftDialog(
                                        context: context,
                                        title: 'Upload hình ảnh',
                                        content: 'Upload thất bại',
                                      );
                                    }
                                  });
                                }else{
                                  _provider.aleftDialog(
                                    context: context,
                                    title: 'Hình ảnh sản phẩm',
                                    content: 'Chưa chọn hình ảnh',
                                  );
                                }
                              }else{
                                _provider.aleftDialog(
                                    context: context,
                                    title: 'Danh mục phụ',
                                    content: 'Danh mục phụ chưa được chọn'
                                );
                              }
                            }else{
                              _provider.aleftDialog(
                                context: context,
                                title: 'Danh mục chính',
                                content: 'Danh mục chính chưa được chọn'
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              TabBar(
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.black54,
                  tabs: [
                    Tab(text: 'Chung',),
                    Tab(text: 'Tồn kho',)
                  ]
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: TabBarView(
                      children: [
                        ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    validator: (value) {
                                      if (value.isEmpty){
                                        return 'Vui lòng nhập tên sản phẩm';
                                      }
                                      setState(() {
                                        productName = value;
                                      });
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Tên sản phẩm*',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]
                                        )
                                      )
                                    ),
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    maxLength: 500,
                                    validator: (value) {
                                      if (value.isEmpty){
                                        return 'Vui lòng nhập mô tả sản phẩm';
                                      }
                                      setState(() {
                                        description = value;
                                      });
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'Thông tin sản phẩm*',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]
                                            )
                                        )
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        _provider.getProductImage().then((image) {
                                          setState(() {
                                            _image = image;
                                          });
                                        });
                                      },
                                      child: SizedBox(
                                        width: 150,
                                        height: 150,
                                        child: Card(
                                          child: Center(
                                            child: _image == null ? Text('Chọn hình ảnh') : Image.file(_image),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      if (value.isEmpty){
                                        return 'Vui lòng nhập giá sản phẩm';
                                      }
                                      setState(() {
                                        price = double.parse(value);
                                      });
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        labelText: 'Giá*',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]
                                            )
                                        )
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _comparedPriceTextController,
                                    validator: (value) {
                                      if (price > double.parse(value)) {
                                        return 'Giá khuyến mãi nên thấp hơn giá so sánh';
                                      }
                                      setState(() {
                                        comparedPrice = double.parse(value);
                                      });
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        labelText: 'Giá cả so sánh*',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]
                                            )
                                        )
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        Text('Bộ sưu tập', style: TextStyle(color: Colors.grey),),
                                        SizedBox(width: 10,),
                                        DropdownButton(
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
                                  TextFormField(
                                    controller: _brandTextController,
                                    decoration: InputDecoration(
                                        labelText: 'Nhãn hiệu',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]
                                            )
                                        )
                                    ),
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      if (value.isEmpty){
                                        return 'Vui lòng nhập mã sản phẩm';
                                      }
                                      setState(() {
                                        sku = value;
                                      });
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'Mã sản phẩm*',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]
                                            )
                                        )
                                    ),
                                  ),
                                  Padding(
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
                                        IconButton(
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
                                  TextFormField(
                                    validator: (value) {
                                      if (value.isEmpty){
                                        return 'Vui lòng nhập khối lượng';
                                      }
                                      setState(() {
                                        weight = value;
                                      });
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'Khối lượng',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]
                                            )
                                        )
                                    ),
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      if (value.isEmpty){
                                        return 'Vui lòng nhập thuế (%)';
                                      }
                                      setState(() {
                                        tax = double.parse(value);
                                      });
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        labelText: 'Thuế %',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]
                                            )
                                        )
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: Text('Theo dõi hàng tồn kho'),
                                activeColor: Theme.of(context).primaryColor,
                                subtitle: Text(
                                  'Bật để theo dõi hàng tồn kho',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                value: _track,
                                onChanged: (selected) {
                                 setState(() {
                                   _track = !_track;
                                 });
                                },
                              ),
                              Visibility(
                                visible: _track,
                                child: SizedBox(
                                  height: 300,
                                  width: double.infinity,
                                  child: Card(
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: _stockTextController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                                labelText: 'Số lượng tồn kho*',
                                                labelStyle: TextStyle(color: Colors.grey),
                                                enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey[300]
                                                    )
                                                )
                                            ),
                                          ),
                                          TextField(
                                            keyboardType: TextInputType.number,
                                            controller: _lowStockTextController,
                                            decoration: InputDecoration(
                                                labelText: 'Số lượng tồn kho sắp hết',
                                                labelStyle: TextStyle(color: Colors.grey),
                                                enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey[300]
                                                    )
                                                )
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
