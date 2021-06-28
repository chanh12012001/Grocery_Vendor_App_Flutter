import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app_flutter/screens/edit_view_product.dart';
import 'package:grocery_vendor_app_flutter/services/firebase_service.dart';

class UnPublishedProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    FirebaseServices _services = FirebaseServices();

    return Container(
      child: StreamBuilder(
        stream: _services.products.where('published', isEqualTo: false).snapshots(),
        builder: (context, snapshot){
          if (snapshot.hasError){
            return Text('Đã xảy ra lỗi');
          }
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }
          return SingleChildScrollView(
            child: FittedBox(
              child: DataTable(
                showBottomBorder: true,
                dataRowHeight: 60,
                headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                columns: <DataColumn>[
                  DataColumn(label: Expanded(child: Text('Tên'))),
                  DataColumn(label: Text('Hình ảnh')),
                  DataColumn(label: Text('Thông tin')),
                  DataColumn(label: Expanded(child: Text('Hoạt động'))),
                ],
                rows: _productDetails(snapshot.data, context),
              ),
            ),
          );
        },
      ),
    );
  }
  List<DataRow>_productDetails(QuerySnapshot snapshot, context){
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document){
      if (document != null){
        return DataRow(
          cells: [
            DataCell(
              Container(
               // width: 0,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      Text('Tên: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                      Text(document['productName'], style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Text('Mã: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
                      Text(document['sku'], style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            DataCell(
              Container(child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Row(
                  children: [
                    Image.network(document['productImage'], width: 50,),
                  ],
                ),
              ),),
            ),
            DataCell(
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditViewProduct(
                    productId: document['productId'],
                  )));
                },
                icon: Icon(Icons.info_outline),
              )
            ),
            DataCell(
              popUpButton(document.data())
            ),
          ],
        );
      }
    }).toList();
    return newList;
  }

  Widget popUpButton(data, {BuildContext context}){

    FirebaseServices _services = FirebaseServices();

    return PopupMenuButton<String>(
      onSelected: (String value) {
        if(value == 'Phát hành'){
          _services.publishProduct(
            id: data['productId']
          );
        }

        if(value == 'xóa'){
          _services.deleteProduct(
              id: data['productId']
          );
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Phát hành',
          child: ListTile(
            leading: Icon(Icons.check),
            title: Text('Phát hành'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'xóa',
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Xóa sản phẩm'),
          ),
        ),
      ],
    );
  }
}
