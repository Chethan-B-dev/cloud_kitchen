import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_kitchen/helpers/loading_card.dart';
import 'package:cloud_kitchen/services/kitchens.dart';
import 'package:cloud_kitchen/services/orders.dart';
import 'package:flutter/material.dart';

class CheckOrders extends StatefulWidget {
  const CheckOrders({Key key}) : super(key: key);

  static String routeName = '/check-orders';

  @override
  _CheckOrdersState createState() => _CheckOrdersState();
}

class _CheckOrdersState extends State<CheckOrders> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FutureBuilder<QuerySnapshot>(
              future: Orders().orderList,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Something went wrong'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingCard();
                }

                return ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (ctx, index) {
                    final foodList =
                        json.decode(snapshot.data.docs[index]['items'])
                            as Map<String, dynamic>;

                    return Card(
                      elevation: 8.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 5,
                        ),
                        height: deviceSize.height * 0.3,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      snapshot.data.docs[index]['username'] +
                                          ' - ' +
                                          snapshot.data.docs[index]['userId'],
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  PopupMenuButton(
                                    onSelected: (value) async {
                                      await Orders().updateOrderStatus(value,
                                          snapshot.data.docs[index]['userId']);
                                    },
                                    icon: Tooltip(
                                      message: 'Update order status',
                                      child: const Icon(
                                        Icons.more_vert,
                                      ),
                                    ),
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry>[
                                      const PopupMenuItem(
                                        value: 1,
                                        child: ListTile(
                                          leading: Icon(Icons.add),
                                          title: const Text('Order recieved'),
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 2,
                                        child: ListTile(
                                          leading: Icon(Icons.anchor),
                                          title: const Text('Order Processed'),
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 3,
                                        child: ListTile(
                                          leading: Icon(Icons.article),
                                          title: const Text('Ready for pickup'),
                                        ),
                                      ),
                                      const PopupMenuDivider(),
                                      const PopupMenuItem(
                                        value: 4,
                                        child: ListTile(
                                          leading: Icon(Icons.delete_outline),
                                          title: const Text('Delete'),
                                        ),
                                      ),
                                      // const PopupMenuItem(child: Text('Item B')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      ListView.builder(
                                        primary: false,
                                        shrinkWrap: true,
                                        itemCount: foodList.length,
                                        itemBuilder: (ctx, index) {
                                          return FutureBuilder(
                                            future: Kitchens().foodNameFromId(
                                              foodList.keys.toList()[index],
                                            ),
                                            builder: (context, fsnapshot) {
                                              if (fsnapshot.hasError) {
                                                return Center(
                                                  child: Text(
                                                      'Something went wrong'),
                                                );
                                              }

                                              if (fsnapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return LoadingCard();
                                              }

                                              return Container(
                                                height: deviceSize.height * 0.1,
                                                child: Card(
                                                  child: InkWell(
                                                    onTap: () {},
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              fsnapshot.data,
                                                            ),
                                                          ),
                                                          Text(
                                                            'x' +
                                                                foodList.values
                                                                    .toList()[
                                                                        index]
                                                                    .toString(),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
