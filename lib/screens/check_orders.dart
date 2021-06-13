import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_kitchen/helpers/error.dart';
import 'package:cloud_kitchen/helpers/loading_card.dart';
import 'package:cloud_kitchen/services/cart.dart';
import 'package:cloud_kitchen/services/kitchens.dart';
import 'package:cloud_kitchen/services/orders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckOrders extends StatefulWidget {
  const CheckOrders({Key key}) : super(key: key);

  static String routeName = '/check-orders';

  @override
  _CheckOrdersState createState() => _CheckOrdersState();
}

class _CheckOrdersState extends State<CheckOrders> {
  @override
  void initState() {
    super.initState();
    final snackBar = SnackBar(
      duration: Duration(seconds: 1),
      content: Text(
        'Swipe left to remove orders, dismissing it will complete the order for the user',
      ),
    );
    Future(() => ScaffoldMessenger.of(context).showSnackBar(snackBar));
  }

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

                if (snapshot.data.docs.length == 0) {
                  return Center(
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      height: 500,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Image.network(
                              'https://cdn.dribbble.com/users/1168645/screenshots/3152485/no-orders_2x.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              'You have no orders right now.',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (ctx, index) {
                    final foodList =
                        json.decode(snapshot.data.docs[index]['items'])
                            as Map<String, dynamic>;

                    return Dismissible(
                      background: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              iconSize: 25,
                              //color: Colors.red,
                              onPressed: () {},
                              icon: Icon(
                                Icons.delete,
                              ),
                            )
                          ],
                        ),
                      ),
                      onDismissed: (_) async {
                        try {
                          await Provider.of<Cart>(context, listen: false)
                              .deleteOrder(
                            snapshot.data.docs[index].id,
                            snapshot.data.docs[index]['userId'],
                          );
                        } catch (err) {
                          ShowError.showError(err.toString(), context);
                        }
                      },
                      direction: DismissDirection.endToStart,
                      key: ValueKey(snapshot.data.docs[index].id),
                      child: Card(
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
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    PopupMenuButton(
                                      onSelected: (value) async {
                                        await Orders().updateOrderStatus(
                                            value,
                                            snapshot.data.docs[index]
                                                ['userId']);
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
                                            title:
                                                const Text('Order Processed'),
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 3,
                                          child: ListTile(
                                            leading: Icon(Icons.article),
                                            title:
                                                const Text('Ready for pickup'),
                                          ),
                                        ),
                                        // const PopupMenuDivider(),
                                        // const PopupMenuItem(
                                        //   value: 4,
                                        //   child: ListTile(
                                        //     leading: Icon(Icons.delete_outline),
                                        //     title: const Text('Delete'),
                                        //   ),
                                        // ),
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
                                                  height:
                                                      deviceSize.height * 0.1,
                                                  child: Card(
                                                    child: InkWell(
                                                      onTap: () {},
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
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
                                                                  foodList
                                                                      .values
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
