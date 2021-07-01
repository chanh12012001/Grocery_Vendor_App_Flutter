import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app_flutter/providers/auth_provider.dart';
import 'package:grocery_vendor_app_flutter/screens/login_screen.dart';
import 'package:provider/provider.dart';

class ResetPassword extends StatefulWidget {
  static const String id = 'reset-screen';
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  var _emailTextController = TextEditingController();
  String email;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('images/forgot.png',height: 250,),
                SizedBox(height: 20,),
                RichText(text: TextSpan(
                    text: '',
                    children: [
                      TextSpan(
                          text: 'Quên mât khẩu ' ,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                      ),
                      TextSpan(
                          text : 'Đừng lo lắng! Nhập lại email đăng kí. Chúng tôi sẽ gửi bạn 1 email để lấy lại mật khẩu',
                          style :TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                      ),
                    ]
                ),),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _emailTextController,
                  validator: (value){
                    if(value.isEmpty){
                      return 'Vui lòng nhâp Email';
                    }
                    final bool _isValid = EmailValidator.validate(_emailTextController.text);
                    if(!_isValid){
                      return 'Định dạng email không hợp lệ ';
                    }
                    setState(() {
                      email=value;
                    });
                    return null;
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(),
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 2),
                    ),
                    focusColor: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(
                      child: FlatButton(
                        onPressed: (){
                          if(_formKey.currentState.validate()){
                            setState(() {
                              _loading=true;
                            });
                            _authData.resetPassword(email);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(
                                    'Vui lòng kiểm tra Email ${_emailTextController.text}'),
                                ),
                            );
                          }
                          Navigator.pushReplacementNamed(context, LoginScreen.id);
                        },
                        color: Theme.of(context).primaryColor,
                        child: _loading
                            ? LinearProgressIndicator()
                            : Text('Reset Password',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
