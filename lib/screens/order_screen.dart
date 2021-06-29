import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_vendor_app_flutter/providers/order_provider.dart';
import 'package:grocery_vendor_app_flutter/services/order_services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {

  OrderServices _orderServices = OrderServices();
  User user = FirebaseAuth.instance.currentUser;

  int tag = 0;
  List<String> options = [
    'Tất cả',
    'Đã đặt',
    'Đã chấp nhận',
    'Picked up',
    'Đang giao hàng',
    'Đã giao'
  ];

  @override
  Widget build(BuildContext context) {

    var _orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Text(
                'My Orders',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Container(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ChipsChoice<int>.single(
              choiceStyle: C2ChoiceStyle(
                borderRadius: BorderRadius.all(Radius.circular(3)),
              ),
              value: tag,
              onChanged: (val) {
                if (val == 0) {
                  setState(() {
                    _orderProvider.status = null;
                  });
                }
                setState(() {
                  tag = val;
                  _orderProvider.status = options[val];
                });
              },
              choiceItems: C2Choice.listFrom<int, String>(
                source: options,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
            ),
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _orderServices.orders
                  .where('seller.sellerId', isEqualTo: user.uid).where('orderStatus', isEqualTo: tag > 0 ?  _orderProvider.status : null)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Xảy ra sự cố ');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(),);
                }
                if (snapshot.data.size==0){
                  //TODO: No orders creen
                  return Center(
                    child: Text(tag > 0 ? 'Không có ${options[tag]} order' : 'No Orders. Continue Shopping'),
                  );
                }

                return Expanded(
                  child: new ListView(
                    padding: EdgeInsets.zero,
                    children: snapshot.data.docs
                        .map((DocumentSnapshot document) {
                      return new Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            ListTile(
                              horizontalTitleGap: 0,
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 14,
                                child: Icon(
                                  CupertinoIcons.square_list,
                                  size: 18,
                                  //thay thế dòng color cho customerapp
                                  color: document['orderStatus'] == 'Đã từ chối' ? Colors.red : document['orderStatus'] == 'Đã chấp nhận' ? Colors.blueGrey[400] : Colors.orange,
                                ),
                              ),
                              title: Text(
                                document['orderStatus'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: document['orderStatus'] == 'Đã từ chối' ? Colors.red : document['orderStatus'] == 'Đã chấp nhận' ? Colors.blueGrey[400] : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'On ${DateFormat.yMMMd().format(DateTime.parse(document['timestamp']))}',
                                style: TextStyle(fontSize: 12),
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Phương thức thanh toán: ${document['cod'] == true ? 'Tiền mặt sau khi nhận hàng' : 'Thanh toán online'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Tổng tiền: \$${document['total'].toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            ExpansionTile(
                              title: Text(
                                'Mô tả đơn hàng',
                                style: TextStyle(
                                  fontSize: 10, color: Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                'Xem chi tiết đơn hàng',
                                style: TextStyle(
                                  fontSize: 12, color: Colors.grey),
                                ),
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (BuildContext context, int index){
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Image.network(
                                          document['products'][index]['productImage']
                                        ),
                                      ),
                                      title: Text(
                                        document['products'][index]['productName'],
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      subtitle: Text(
                                        '${document['products'][index]['qty']} x ${document['products'][index]['price'].toStringAsFixed(0)} = ${document['products'][index]['total'].toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: document['products'].length,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                                  child: Card(
                                    elevation: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Người bán: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                document['seller']['shopName'],
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          if (int.parse(document['discount']) > 0)
                                            Container(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Discount',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        document['discount'],
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(height: 10,),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Discount Code: ',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        document['discountCode'],
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Delivery Fee: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                document['deliveryFee'].toString(),
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Divider(
                              height: 3,
                              color: Colors.grey,
                            ),
                            document['orderStatus'] == 'Đã chấp nhận' ?
                                Container(
                                  color: Colors.grey[300],
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(40,8,40,8),
                                    child: FlatButton(
                                      color: Colors.orangeAccent,
                                      child: Text('Assign delivery boy', style: TextStyle(color: Colors.white),),
                                      onPressed: () {
                                        print('Assign delivery boy');
                                      },
                                    ),
                                  ),
                                ) :
                            Container(
                              color: Colors.grey[300],
                              height: 50,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FlatButton(
                                        color: Colors.blueGrey,
                                        child: Text('Chấp nhận', style: TextStyle(color: Colors.white),),
                                        onPressed: () {
                                          showDialog('Chấp nhận đơn hàng', 'Đã chấp nhận', document.id);
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: AbsorbPointer(
                                        absorbing: document['orderStatus'] == 'Đã từ chối' ? true : false,
                                        child: FlatButton(
                                          color: document['orderStatus'] == 'Đã từ chối' ? Colors.grey : Colors.red,
                                          child: Text('Từ chối', style: TextStyle(color: Colors.white),),
                                          onPressed: () {
                                            showDialog('Từ chối đơn hàng', 'Đã từ chối', document.id);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 3,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  showDialog(title, status, documentId){
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text('Bạn có chắn chắn ?'),
            actions: [
              FlatButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  EasyLoading.show(status: 'Đang cập nhật trạng thái');
                  status == 'Đã chấp nhận' ? _orderServices.updateOrderStatus(documentId, status).then((value){
                    EasyLoading.showSuccess('Cập nhật thành công');
                  }) : _orderServices.updateOrderStatus(documentId, status).then((value){
                    EasyLoading.showSuccess('Cập nhật thành công');
                  });
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
    );
  }
}
