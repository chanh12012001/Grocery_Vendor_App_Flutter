import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_vendor_app_flutter/providers/product_provider.dart';
import 'package:grocery_vendor_app_flutter/services/firebase_service.dart';
import 'package:grocery_vendor_app_flutter/widgets/banner_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BannerScreen extends StatefulWidget {
  @override
  _BannerScreenState createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> {

  FirebaseServices _services = FirebaseServices();
  bool _visible = false;
  File _image;
  var _imagePathText = TextEditingController();

  @override
  Widget build(BuildContext context) {

    var _provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BannerCard(),
          Divider(
            thickness: 3,
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Center(
              child: Text(
                'THÊM QUẢNG CÁO MỚI',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      color: Colors.grey[200],
                      child: _image!=null
                          ? Image.file(_image,fit: BoxFit.fill,)
                          : Center(child: Text('Không có ảnh nào được chọn'),),
                    ),
                  ),
                  TextFormField(
                    controller: _imagePathText,
                    enabled: false,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: _visible ? false : true,
                    child: Row(
                      children: [
                        Expanded(
                          child: FlatButton(
                            color: Theme.of(context).primaryColor,
                            child: Text(
                              'Thêm quảng cáo mới',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _visible=true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _visible,
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: FlatButton(
                                  color: Theme.of(context).primaryColor,
                                  child: Text(
                                    'Tải ảnh lên',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    getBannerImage().then((value){
                                      if(_image!=null){
                                        setState(() {
                                          _imagePathText.text = _image.path;
                                        });
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: AbsorbPointer(
                                  absorbing: _image!=null ? false : true,
                                  child: FlatButton(
                                    color: _image!=null ? Theme.of(context).primaryColor : Colors.grey,
                                    child: Text(
                                      'Lưu',
                                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      EasyLoading.show( status: 'Đang lưu...');
                                      uploadBannerImage(_image.path,_provider.shopName).then((url){
                                        if(url!=null){
                                          //Lưu đường dẫn quảng cáo vào firestore
                                          _services.saveBanner(url);
                                          setState(() {
                                            _imagePathText.clear();
                                            _image = null;
                                          });
                                          EasyLoading.dismiss();
                                          _provider.alertDialog(
                                            context: context,
                                            title: 'Tải quảng cáo lên',
                                            content: 'Tải ảnh quảng cáo thành công',
                                          );
                                        }else{
                                          EasyLoading.dismiss();
                                          _provider.alertDialog(
                                            context: context,
                                            title: 'Tải quảng cáo lên',
                                            content: 'Tải thất bại',
                                          );
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: FlatButton(
                                  color: Colors.black54,
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _visible=false;
                                      _imagePathText.clear();
                                      _image=null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<File> getBannerImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('Không có ảnh nào được chọn.');
    }
    return _image;
  }

  Future<String> uploadBannerImage(filePath,shopName) async {
    File file = File(filePath);
    var timeStamp = Timestamp.now().millisecondsSinceEpoch;

    FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      await _storage.ref('vendorbanner/$shopName/$timeStamp').putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }
    //Sau khi tải tệp lên, cần đến đường dẫn url của tệp để lưu trong DB
    String downloadURL = await _storage
        .ref('vendorbanner/$shopName/$timeStamp').getDownloadURL();
    return downloadURL;
  }
}
