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
    final snackBar = const SnackBar(
      backgroundColor: Colors.cyan,
      duration: Duration(seconds: 2),
      content: const Text(
        'Swipe left to remove orders, dismissing it will complete the order for the user',
        style: TextStyle(
          color: Colors.black,
        ),
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
            FutureBuilder<Stream<QuerySnapshot>>(
              future: Orders().orderList,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingCard();
                }

                return StreamBuilder(
                    stream: snapshot.data,
                    builder: (context, streamSnapshot) {
                      if (streamSnapshot.hasError) {
                        return const Center(
                          child: Text('Something went wrong'),
                        );
                      }

                      if (streamSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return LoadingCard();
                      }

                      if (streamSnapshot.data.docs.length == 0) {
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
                                const Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: const Text(
                                    'You have no orders right now.',
                                    style: const TextStyle(
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
                        itemCount: streamSnapshot.data.docs.length,
                        itemBuilder: (ctx, index) {
                          final foodList = json.decode(
                                  streamSnapshot.data.docs[index]['items'])
                              as Map<String, dynamic>;

                          return Dismissible(
                            background: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    iconSize: 25,
                                    onPressed: () {},
                                    icon: const Icon(
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
                                  streamSnapshot.data.docs[index].id,
                                  streamSnapshot.data.docs[index]['userId'],
                                  true,
                                );
                              } catch (err) {
                                ShowError.showError(err.toString(), context);
                              }
                            },
                            direction: DismissDirection.endToStart,
                            key: ValueKey(streamSnapshot.data.docs[index].id),
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
                                              streamSnapshot.data.docs[index]
                                                      ['username'] +
                                                  ' - ' +
                                                  streamSnapshot.data
                                                      .docs[index]['userId'],
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                          PopupMenuButton(
                                            onSelected: (value) async {
                                              await Orders().updateOrderStatus(
                                                value,
                                                streamSnapshot.data.docs[index]
                                                    ['userId'],
                                                streamSnapshot
                                                    .data.docs[index].id,
                                                context,
                                              );
                                            },
                                            icon: const Tooltip(
                                              message: 'Update order status',
                                              child: const Icon(
                                                Icons.more_vert,
                                              ),
                                            ),
                                            itemBuilder:
                                                (BuildContext context) =>
                                                    <PopupMenuEntry>[
                                              const PopupMenuItem(
                                                value: 1,
                                                child: const ListTile(
                                                  leading: const Icon(
                                                    Icons.add,
                                                  ),
                                                  title: const Text(
                                                    'Order recieved',
                                                  ),
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 2,
                                                child: const ListTile(
                                                  leading: const Icon(
                                                    Icons.anchor,
                                                  ),
                                                  title: const Text(
                                                    'Order Processed',
                                                  ),
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 3,
                                                child: const ListTile(
                                                  leading: const Icon(
                                                    Icons.article,
                                                  ),
                                                  title: const Text(
                                                    'Ready for pickup',
                                                  ),
                                                ),
                                              ),
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
                                                    future: Kitchens()
                                                        .foodNameFromId(
                                                      foodList.keys
                                                          .toList()[index],
                                                    ),
                                                    builder:
                                                        (context, fsnapshot) {
                                                      if (fsnapshot.hasError) {
                                                        return const Center(
                                                          child: Text(
                                                            'Something went wrong',
                                                          ),
                                                        );
                                                      }

                                                      if (fsnapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return LoadingCard();
                                                      }

                                                      return Container(
                                                        height:
                                                            deviceSize.height *
                                                                0.1,
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
                                                                      fsnapshot
                                                                          .data,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    'x' +
                                                                        foodList
                                                                            .values
                                                                            .toList()[index]
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
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}
