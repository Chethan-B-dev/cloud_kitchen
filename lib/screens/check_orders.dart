import 'package:firebase_auth/firebase_auth.dart';
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
            ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (ctx, index) {
                return Card(
                  elevation: 8.0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                    height: deviceSize.height * 0.3,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Name - ${FirebaseAuth.instance.currentUser.uid}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              PopupMenuButton(
                                icon: Tooltip(
                                  message: 'Update order status',
                                  child: const Icon(
                                    Icons.more_vert,
                                  ),
                                ),
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry>[
                                  const PopupMenuItem(
                                    child: ListTile(
                                      leading: Icon(Icons.add),
                                      title: const Text('Order recieved'),
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    child: ListTile(
                                      leading: Icon(Icons.anchor),
                                      title: const Text('Order Processed'),
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    child: ListTile(
                                      leading: Icon(Icons.article),
                                      title: const Text('Ready for pickup'),
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
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
                            // decoration: BoxDecoration(
                            //   border: Border.all(
                            //     color: Colors.red,
                            //   ),
                            // ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListView.builder(
                                    primary: false,
                                    shrinkWrap: true,
                                    itemCount: 13,
                                    itemBuilder: (ctx, index) {
                                      return Container(
                                        height: deviceSize.height * 0.1,
                                        child: Card(
                                          child: InkWell(
                                            onTap: () {},
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'chicken biriyani masala',
                                                    ),
                                                  ),
                                                  Text(
                                                    'x2',
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
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
            ),
          ],
        ),
      ),
    );
  }
}
