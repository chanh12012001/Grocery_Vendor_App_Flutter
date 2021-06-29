import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_vendor_app_flutter/services/firebase_service.dart';

class BannerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    FirebaseServices _service = FirebaseServices();

    return StreamBuilder<QuerySnapshot>(
      stream: _service.vendorbanner.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Đã xảy ra sự cố');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Đang tải..");
        }

        return Container(
          height: 150,
          width: MediaQuery.of(context).size.width,
          child: new ListView(
            scrollDirection: Axis.horizontal,
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return Stack(
                children: [
                  SizedBox(
                    height: 180,
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      child: Image.network(document['imageUrl'], fit: BoxFit.fill,),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(Icons.delete_outline),
                        color: Colors.red,
                        onPressed: () {
                          EasyLoading.show(
                            status: 'Đang xóa...'
                          );
                          _service.deleteBanner(id: document.id);
                          EasyLoading.dismiss();
                        },
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}