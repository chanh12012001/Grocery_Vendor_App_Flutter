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
    'Sản phẩm nổi bật',
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
  bool _track=false;

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
                        icon: Icon(
                          Icons.save,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Lưu',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if(_formKey.currentState.validate()){
                            //chỉ khi điền trường cần thiết
                            if(_categoryTextController.text.isNotEmpty){
                              if(_subCategoryTextController.text.isNotEmpty){
                                if(_image!=null){
                                  //upload ảnh lên storage
                                  EasyLoading.show(status: 'Đang lưu...');
                                  _provider.uploadProductImage(_image.path, productName).then((url){
                                    if(url!=null){
                                      //upload dữ liệu sản phẩm lên firestore
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
                                          productName: productName
                                      );

                                      // xóa tất cả giá trị hiện có sau khi sản phẩm được lưu
                                      setState(() {
                                        _formKey.currentState.reset();
                                        _comparedPriceTextController.clear();
                                        dropdownValue = null;
                                        _subCategoryTextController.clear();
                                        _categoryTextController.clear();
                                        _brandTextController.clear();
                                        _track = false;
                                        _image = null;
                                        _visible=false;
                                      });

                                    }else{
                                      //Upload thất bại
                                      _provider.alertDialog(
                                        context: context,
                                        title: 'TẢI ẢNH LÊN',
                                        content: 'Tải ảnh sản phẩm thất bại',
                                      );
                                    }
                                  });

                                }else{
                                  //image not selected
                                  _provider.alertDialog(
                                    context: context,
                                    title: 'ẢNH SẢN PHẨM',
                                    content: 'Ảnh sản phẩm chưa được chọn',
                                  );
                                }

                              }else{
                                _provider.alertDialog(
                                    context: context,
                                    title: 'Danh mục phụ',
                                    content: 'Danh mục phụ chưa được chọn'
                                );

                              }
                            }else{
                              _provider.alertDialog(
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
                  Tab(
                    text: 'CHUNG',
                  ),
                  Tab(
                    text: 'TỒN KHO',
                  ),
                ],
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
                                    validator: (value){
                                      if(value.isEmpty){
                                        return  'Vui lòng nhập tên sản phẩm';
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
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ),

                                  TextFormField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    maxLength: 500,
                                    validator: (value){
                                      if(value.isEmpty){
                                        return  'Vui lòng nhập mô tả';
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
                                          color: Colors.grey[300],
                                        ),
                                      ),
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
                                            child: _image == null
                                                ? Text('Chọn ảnh')
                                                : Image.file(_image),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  TextFormField(
                                    validator: (value){
                                      if(value.isEmpty){
                                        return  'Vui lòng nhập giá bán';
                                      }
                                      setState(() {
                                        price = double.parse(value);
                                      });
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Giá*', //Giá bán cuối
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ),

                                  TextFormField(
                                    controller: _comparedPriceTextController,
                                    validator: (value){
                                      //Không bắt buộc
                                      if(price > double.parse(value)) { //Gía so sánh phải cao hơn
                                        return 'Giá so sánh nên cao hơn giá ra thị trường';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Giá so sánh ',
                                      //Price before discount
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ),

                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Bộ sưu tập',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        DropdownButton<String>(
                                          hint: Text('Chọn Bộ sưu tập'),
                                          value: dropdownValue,
                                          icon: Icon(Icons.arrow_drop_down),
                                          onChanged: (String value) {
                                            setState(() {
                                              dropdownValue = value;
                                            });
                                          },
                                          items: _collections
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),

                                  TextFormField(
                                    controller: _brandTextController,
                                    decoration: InputDecoration(
                                      //Không bắt buộc
                                      labelText: 'Nhãn hiệu',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ),

                                  TextFormField(
                                    validator: (value){
                                      if(value.isEmpty){
                                        return 'Vui lòng nhập mã sản phẩm';
                                      }
                                      setState(() {
                                        sku = value;
                                      });
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Mã sản phẩm',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 10),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Danh mục',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: AbsorbPointer(
                                            absorbing: true, //Chặn người dùng nhập tên danh mục theo cách thủ công tức phải chọn
                                            child: TextFormField(
                                              controller: _categoryTextController,
                                              validator: (value){
                                                if(value.isEmpty){
                                                  return 'Chọn tên danh mục';
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'Chưa chọn',
                                                //Item code
                                                labelStyle:
                                                TextStyle(color: Colors.grey),
                                                enabledBorder:
                                                UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.grey[300],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit_outlined),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return CategoryList();
                                                }).whenComplete(() {
                                              setState(() {
                                                _categoryTextController.text = _provider.selectedCategory;
                                                _visible = true;
                                              });
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ),

                                  Visibility(
                                    visible: _visible,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 20),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Danh mục phụ',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: AbsorbPointer(
                                              absorbing: true,
                                              child: TextFormField(
                                                controller: _subCategoryTextController,
                                                validator: (value){
                                                  if(value.isEmpty){
                                                    return 'Vui lòng chọn danh mục phụ';
                                                  }
                                                  return null;
                                                },
                                                decoration: InputDecoration(
                                                  hintText: 'Chưa chọn',
                                                  //Item code
                                                  labelStyle: TextStyle(
                                                      color: Colors.grey
                                                  ),
                                                  enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors.grey[300],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit_outlined),
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return SubCategoryList();
                                                  }).whenComplete(() {
                                                setState(() {
                                                  _subCategoryTextController.text = _provider.selectedSubCategory;
                                                });
                                              });
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    validator: (value){
                                      if(value.isEmpty){
                                        return 'Vui lòng nhập trọng lượng sản phẩm';
                                      }
                                      setState(() {
                                        weight = value;
                                      });
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Trọng lượng.  Vd:- Kg, gm,..',
                                      //Item code
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    validator: (value){
                                      if(value.isEmpty){
                                        return 'Vui lòng nhập thuế (%)';
                                      }
                                      setState(() {
                                        tax = double.parse(value);
                                      });
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Thuế (%)',
                                      labelStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: Text('Theo dõi hàng tồn kho'),
                                activeColor: Theme.of(context).primaryColor,
                                subtitle: Text(
                                  'BẬT để theo dõi hàng tồn kho',
                                  style: TextStyle(
                                      color: Colors.grey,fontSize: 12
                                  ),
                                ),
                                value: _track,
                                onChanged: (selected){
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
                                              labelText: 'Số lượng tồn*',
                                              labelStyle: TextStyle(color: Colors.grey),
                                              enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                            ),
                                          ),
                                          TextFormField(
                                            //not compulsory
                                            keyboardType: TextInputType.number,
                                            controller: _lowStockTextController,
                                            decoration: InputDecoration(
                                              labelText: 'Số lượng còn lại', //Item code
                                              labelStyle: TextStyle(color: Colors.grey),
                                              enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300],
                                                ),
                                              ),
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
                        )
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
