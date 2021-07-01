import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_vendor_app_flutter/services/firebase_service.dart';
import 'package:grocery_vendor_app_flutter/services/order_services.dart';

class DeliveryBoysList extends StatefulWidget {
  final DocumentSnapshot document;
  DeliveryBoysList(this.document);

  @override
  _DeliveryBoysListState createState() => _DeliveryBoysListState();
}

class _DeliveryBoysListState extends State<DeliveryBoysList> {
  FirebaseServices _services = FirebaseServices();
  OrderServices _orderServices = OrderServices();
  GeoPoint _shopLocation;

  @override
  void initState() {
    _services.getShopDetails().then((value) {
      if (value != null) {
        if (mounted) {
          setState(() {
            _shopLocation = value['location'];
          });
        }
      } else {
        print('Không có dữ liệu');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(
                  'Chọn người giao hàng',
                  style: TextStyle(color: Colors.white),
                ),
                iconTheme: IconThemeData(
                    color: Colors.white),
              ),
              Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _services.boys
                      .where('accVerified', isEqualTo: true)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Đã xảy ra sự cố');
                    }

                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return new ListView(
                      shrinkWrap: true,
                      children:
                      snapshot.data.docs.map((DocumentSnapshot document) {
                        GeoPoint location = document['location'];
                        double distanceInMeters = _shopLocation == null
                            ? 0.0
                            : Geolocator.distanceBetween(
                            _shopLocation.latitude,
                            _shopLocation.longitude,
                            location.latitude,
                            location.longitude) / 1000;
                        if (distanceInMeters > 10) {
                          return Container();
                          //Chỉ hiển thị những người giao hàng gần nhất, trong 10 km
                        }
                        return Column(
                          children: [
                            new ListTile(
                              onTap: (){
                                EasyLoading.show(status: 'Đang xác nhận người giao hàng');
                                _services.selectBoys(
                                    orderId: widget.document.id,
                                    phone: document['mobile'],
                                    name: document['name'],
                                    location: document['location'],
                                    image: document['imageUrl'],
                                    email: document['email']
                                ).then((value) {
                                  EasyLoading.showSuccess('Đã xác nhận người giao hàng');
                                  Navigator.pop(context);
                                });
                              },
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Image.network(document['imageUrl']),
                              ),
                              title: new Text(document['name']),
                              subtitle: new Text('${distanceInMeters.toStringAsFixed(0)} Km'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.map,color: Theme.of(context).primaryColor,),
                                    onPressed: (){
                                      GeoPoint location = document['location'];
                                      _orderServices.launchMap(location, document['name']);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.phone,color: Theme.of(context).primaryColor),
                                    onPressed: (){
                                      _orderServices.launchCall('Gọi: ${document['mobile']}');
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 2,color: Colors.grey,)
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              )
            ],
          )
      ),
    );
  }
}

