import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app_flutter/services/firebase_service.dart';
import 'package:grocery_vendor_app_flutter/services/order_services.dart';
import 'package:intl/intl.dart';

class OrderSummaryCard extends StatefulWidget {
  final DocumentSnapshot document;

  OrderSummaryCard(this.document);

  @override
  _OrderSummaryCardState createState() => _OrderSummaryCardState();
}

class _OrderSummaryCardState extends State<OrderSummaryCard> {
  OrderServices _orderServices = OrderServices();
  FirebaseServices _services = FirebaseServices();

  DocumentSnapshot _customer;

  @override
  void initState() {
    _services
        .getCustomerDetails(widget.document['userId'])
        .then((value) {
      if (value != null) {
        setState(() {
          _customer = value;
        });
      } else {
        print('Không có dữ liệu');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          //order status
          ListTile(
            horizontalTitleGap: 0,
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 14,
              child: _orderServices.statusIcon(widget.document),
            ),
            title: Text(
              widget.document['orderStatus'],
              style: TextStyle(
                  fontSize: 12,
                  color: _orderServices.statusColor(widget.document),
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'On ${DateFormat.yMMMd().format(DateTime.parse(widget.document['timestamp']))}',
              style: TextStyle(fontSize: 12),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Phương thức thanh toán : ${widget.document['cod'] == true ? 'Thanh toán trực tuyến' : 'Thanh toán trực tiếp'}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tổng : ${widget.document['total'].toStringAsFixed(0)} \đồng',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          //------------------Customer details--------------------
          _customer != null ? ListTile(
            title: Row(
              children: [
                Text(
                  'Khách hàng: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_customer['firstName']} ${_customer['lastName']}',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              _customer['address'],
              style: TextStyle(fontSize: 12),
              maxLines: 1,
            ),

            trailing:  InkWell(
              onTap: () {
                _orderServices.launchCall('Gọi:${_customer['number']}');
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(4)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 2, bottom: 2),
                  child: Icon(
                    Icons.phone_in_talk,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ) : Container(),
          //------------------Customer details--------------------


          //----------------------Order details----------------------
          ExpansionTile(
            title: Text(
              'Mô tả đơn hàng',
              style: TextStyle(fontSize: 10, color: Colors.black),
            ),
            subtitle: Text(
              'Xem mô tả đơn hàng',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Image.network(widget.document['products'][index]['productImage']),
                    ),
                    title: Text(
                      widget.document['products'][index]['productName'],
                      style: TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      '${widget.document['products'][index]['qty']} x ${widget.document['products'][index]['price'].toStringAsFixed(0)}\đ = ${widget.document['products'][index]['total'].toStringAsFixed(0)}\đ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
                itemCount: widget.document['products'].length,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('Người bán : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                            ),
                            Text(
                              widget.document['seller']['shopName'],
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
                        if (int.parse(widget.document['discount']) > 0) //Sẽ hiển thị khi sử dụng mã giảm giá
                          Container(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Discount : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      '${widget.document['discount']}',
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
                                Row(
                                  children: [
                                    Text(
                                      'Mã giảm: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${widget.document['discountCode']}',
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
                              'Phí vận chuyển: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${widget.document['deliveryFee'].toString()}\đ',
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
              )
            ],
          ),
          //----------------------Order details----------------------

          Divider(
            height: 3,
            color: Colors.grey,
          ),
          _orderServices.statusContainer(widget.document, context),

          Divider(
            height: 3,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}