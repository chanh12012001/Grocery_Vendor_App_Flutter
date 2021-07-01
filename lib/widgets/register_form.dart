import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app_flutter/providers/auth_provider.dart';
import 'package:grocery_vendor_app_flutter/screens/home_screen.dart';
import 'package:provider/provider.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  var _emailTextController = TextEditingController();
  var _passwordTextController = TextEditingController();
  var _cPasswordTextController = TextEditingController();
  var _addressTextController = TextEditingController();
  var _nameTextController = TextEditingController();
  var _dialogTextController = TextEditingController();
  String email;
  String password;
  String shopName;
  String mobile;
  bool _isLoading = false;

  Future<String> uploadFile(filePath) async {
    File file = File(filePath);

    FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      await _storage.ref('uploads/shopProfilePic/${_nameTextController.text}').putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }

    //Sau khi tải tệp lên, cần đến đường dẫn url của tệp để lưu trong DB
    String downloadURL = await _storage.ref('uploads/shopProfilePic/${_nameTextController.text}').getDownloadURL();
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    scaffoldMessage(message){
      return ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }

    return _isLoading ? CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
    ) : Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Vui lòng nhập tên shop';
                }
                setState(() {
                  _nameTextController.text=value;
                });
                setState(() {
                  shopName=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.add_business),
                labelText: 'Tên cửa hàng',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              keyboardType: TextInputType.phone,
              maxLength: 10, //Số điện thoại 10 số
              validator: (value) {
                if (value.isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                setState(() {
                  mobile=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixText: '+84',
                prefixIcon: Icon(Icons.phone_android),
                labelText: 'Số điện thoại',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              controller: _emailTextController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Vui lòng nhập Email';
                }
                final bool _isValid = EmailValidator.validate(_emailTextController.text);
                if(!_isValid){
                  return 'Email không đúng định dạng';
                }
                setState(() {
                  email=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                labelText: 'Email',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              obscureText: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                if(value.length < 6){
                  return 'Mật khẩu tối đa 6 ký tự';
                }
                setState(() {
                  password=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.vpn_key_outlined),
                labelText: 'Mật khẩu',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              obscureText: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu';
                }
                if(value.length < 6){
                  return 'Mật khẩu tối đa 6 ký tự';
                }
                if(_passwordTextController.text != _cPasswordTextController.text){
                  return 'Mật khẩu xác nhận không đúng';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.vpn_key_outlined),
                labelText: 'Xác nhận mật khẩu',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              maxLines: 6,
              controller: _addressTextController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Vui lòng nhấn nút điều hướng ';
                }
                if(_authData.shopLatitude==null){
                  return 'Vui lòng nhấn nút điều hướng';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.contact_mail_outlined),
                labelText: 'Địa chỉ Shop',
                suffixIcon: IconButton(
                  icon: Icon(Icons.location_searching),
                  onPressed: (){
                    _addressTextController.text='Đang định vị...\n Vui lòng đợi...';
                    _authData.getCurrentAddress().then((address){
                      if(address!=null){
                        setState(() {
                          _addressTextController.text='${_authData.placeName}\n${_authData.shopAddress}';
                        });
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Không tìm thấ địa chỉ. Vui lòng thử lại',),),);
                      }
                    });
                  },
                ),
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              onChanged: (value){
                _dialogTextController.text=value;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.comment),
                labelText: 'Shop Dialog',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(height: 20,),
          Row(
            children: [
              Expanded(
                child: FlatButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    if(_authData.isPicAvail == true){ //Đầu tiên sẽ xác nhận ảnh hồ sơ
                      if (_formKey.currentState.validate()) { // Sau đó sẽ xác thực các form
                        setState(() {
                          _isLoading=true;
                        });
                        _authData.registerVendor(email, password).then((credential){
                          if(credential.user.uid != null){
                            //người dùng đã đăng kí
                            //Tải ảnh hồ sơ lên Firestore
                            uploadFile(_authData.image.path).then((url){
                              if(url != null){
                                //Lưu mô tả shop vào DB
                                _authData.saveVendorDataToDb(
                                  url: url,
                                  mobile: mobile,
                                  shopName: shopName,
                                  dialog: _dialogTextController.text,
                                );
                                setState(() {
                                  _isLoading=false;
                                });
                                Navigator.pushReplacementNamed(context, HomeScreen.id);
                              }else{
                                scaffoldMessage('Tải ảnh hồ sơ thất bại');
                              }
                            });
                          }else{
                            //Đăng kí thất bại
                            scaffoldMessage(_authData.error);
                          }
                        });
                      }
                    }else{
                      scaffoldMessage('Cần thêm ảnh hồ sơ shop');
                    }
                  },
                  child: Text(
                    'Đăng kí',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
