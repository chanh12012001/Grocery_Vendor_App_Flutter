import 'package:flutter/material.dart';
import 'package:grocery_vendor_app_flutter/screens/add_new_product_screen.dart';
import 'package:grocery_vendor_app_flutter/widgets/published_product.dart';
import 'package:grocery_vendor_app_flutter/widgets/unpublished_product.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Material(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Container(
                        child: Row(
                          children: [
                            Text('Sản phẩm'),
                            SizedBox(width: 10,),
                            CircleAvatar(
                              backgroundColor: Colors.black54,
                              maxRadius: 8,
                              child: FittedBox(
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text(
                                    '20',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    FlatButton.icon(
                      color: Theme.of(context).primaryColor,
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text('Thêm mới', style: TextStyle(color: Colors.white),),
                      onPressed: () {
                        Navigator.pushNamed(context, AddNewProduct.id);
                      },
                    ),
                  ],
                ),
              ),
            ),
            TabBar(
              indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.black54,
              tabs: [
                Tab(text: 'Đã phát hành',),
                Tab(text: 'Chưa phát hành',)
              ]
            ),
            Expanded(
              child: Container(
                child: TabBarView(
                  children: [
                    PublishedProducts(),
                    UnPublishedProducts(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
