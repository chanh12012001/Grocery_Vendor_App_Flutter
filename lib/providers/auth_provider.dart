import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class AuthProvider extends ChangeNotifier {
  File image;
  bool isPicAvail = false;
  String pickerError = '';
  String error = '';

  //shop data
  double shopLatitude;
  double shopLongitude;
  String shopAddress;
  String placeName;
  String email;

  //-----------------------Reduce image size-----------------------------
  Future<File> getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery,imageQuality: 20);
    if (pickedFile != null) {
      this.image = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickerError = 'Không có ảnh nào được chọn.';
      notifyListeners();
    }
    return this.image;
  }
  //-----------------------Reduce image size-----------------------------


  Future getCurrentAddress() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    this.shopLatitude = _locationData.latitude;
    this.shopLongitude = _locationData.longitude;
    notifyListeners();

    final coordinates = new Coordinates(_locationData.latitude, _locationData.longitude);
    var _addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var shopAddress = _addresses.first;
    this.shopAddress = shopAddress.addressLine;
    this.placeName = shopAddress.featureName;
    notifyListeners();
    return shopAddress;
  }

  //----------------register vendor using email----------------
  Future<UserCredential> registerVendor(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        this.error = 'The password provided is too weak.';
        notifyListeners();
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        this.error = 'The account already exists for that email.';
        notifyListeners();
      }
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e);
    }
    return userCredential;
  }
  //----------------register vendor using email----------------


  //---------------------------Login----------------------------
  Future<UserCredential> loginVendor(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      this.error=e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.code;
      notifyListeners();
      print(e);
    }
    return userCredential;
  }
  //---------------------------Login----------------------------


  //----------------------Reset password------------------------
  Future<void> resetPassword(email) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      this.error=e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.code;
      notifyListeners();
      print(e);
    }
    return userCredential;
  }
  //----------------------Reset password------------------------


  //--------------------Save vendor data to Firestore-------------------
  Future<void> saveVendorDataToDb(
      {String url, String shopName, String mobile, String dialog}) {
    User user = FirebaseAuth.instance.currentUser;
    DocumentReference _vendors = FirebaseFirestore.instance.collection('vendors').doc(user.uid);
    _vendors.set({
      'uid':user.uid,
      'shopName':shopName,
      'mobile':mobile,
      'email':this.email,
      'dialog': dialog,
      'address' : '${this.placeName}: ${this.shopAddress}',
      'location': GeoPoint(this.shopLatitude, this.shopLongitude),
      'shopOpen': true,
      'rating':0.00,
      'totalRating':0,
      'isTopPicked':false,
      'imageUrl':url,
      'accVerified':false,
    }).whenComplete(()async{
      //Gửi mail đến cho admin
      await FlutterEmailSender.send(mail);
    });
    return null;
  }
//--------------------Save vendor data to Firestore-------------------
}

final Email mail = Email(
  body: 'Nội dung email',
  subject: 'Chủ đề',
  recipients: ['chanh12012001@gmail.com'],
  cc: ['cc@example.com'],
  bcc: ['bcc@example.com'],
  isHTML: false,
);


