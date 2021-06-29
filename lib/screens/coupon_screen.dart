import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app_flutter/screens/add_edit_coupon_screen.dart';
import 'package:grocery_vendor_app_flutter/services/firebase_service.dart';
import 'package:intl/intl.dart';

class CouponScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    return Scaffold(
      body: Container(
        child: StreamBuilder(
          stream: _services.coupons.where('sellerId', isEqualTo: _services.user.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Xảy ra sự cố');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            return new Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        color: Theme.of(context).primaryColor,
                        child: Text('Thêm mã giảm giá mới', style: TextStyle(color: Colors.white),),
                        onPressed: () {
                          Navigator.pushNamed(context, AddEditCoupon.id);
                        },
                      ),
                    ),
                  ],
                ),
                FittedBox(
                  child: DataTable(columns: <DataColumn>[
                    DataColumn(label: Text('Tiêu đề')),
                    DataColumn(label: Text('Tỷ lệ')),
                    DataColumn(label: Text('Trạng thái')),
                    DataColumn(label: Text('Thông tin')),
                    DataColumn(label: Text('Expiry')),
                  ], rows: _couponList(snapshot.data, context)),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  List<DataRow> _couponList(QuerySnapshot snapshot, context){
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document) {
      if (document != null) {
        var date = document['Expiry'];
        var expiry = DateFormat.yMMMd().add_jm().format(date.toDate());
        return DataRow(cells: [
          DataCell(Text(document['title'])),
          DataCell(Text(document['discountRate'].toString())),
          DataCell(Text(document['active'] ? 'Active' : 'Inactive'),),
          DataCell(Text(expiry.toString())),
          DataCell(IconButton(
            icon: Icon(
                Icons.info_outline_rounded),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditCoupon(document: document)));
                },
          ),
          ),
        ]);
      }}
    ).toList();
    return newList;
  }
}
