import 'package:cloud_firestore/cloud_firestore.dart';

class OrderServices{
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');

  Future<void>updateOrderStatus(documentId, status){
    var result = orders.doc(documentId).update({
      'orderStatus' :status,
    });
    return result;
  }
}