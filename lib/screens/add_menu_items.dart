import 'package:cloud_kitchen/helpers/error.dart';
import 'package:cloud_kitchen/services/kitchens.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMenuItems extends StatefulWidget {
  const AddMenuItems({Key key}) : super(key: key);

  static String routeName = '/add-menu-items';

  @override
  _AddMenuItemsState createState() => _AddMenuItemsState();
}

class _AddMenuItemsState extends State<AddMenuItems> {
  bool isNonVeg = false;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    final snackBar = SnackBar(
      content: Text(
        'Swipe left to remove food item',
      ),
    );
    Future(() => ScaffoldMessenger.of(context).showSnackBar(snackBar));
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: FutureBuilder(
          future: Kitchens().kitchenName,
          builder: (ctx, snapshot) {
            if (snapshot.hasError) {
              return Text('Add menu items');
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return Text(snapshot.data);
            }
            return LinearProgressIndicator();
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/food');
            },
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FutureBuilder(
              future: Kitchens().foodItems,
              builder: (ctx, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Something went wrong',
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: snapshot.data,
                  builder: (context, streamSnapshot) {
                    if (streamSnapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (streamSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (streamSnapshot.data.docs.length == 0) {
                      return Container(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Text(
                          'Please add some food items to the menu',
                        ),
                      );
                    }

                    return ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: streamSnapshot.data.docs.length,
                      itemBuilder: (ctx, index) {
                        return Dismissible(
                          direction: DismissDirection.endToStart,
                          key: ValueKey(
                            streamSnapshot.data.docs[index]['createdAt'],
                          ),
                          onDismissed: (_) async {
                            try {
                              await Kitchens().deleteFood(
                                  streamSnapshot.data.docs[index].id);
                            } catch (err) {
                              ShowError.showError(err.toString(), context);
                            }
                          },
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
                          child: Card(
                            elevation: 8.0,
                            child: InkWell(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 5,
                                ),
                                height: deviceSize.height * 0.1,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 32,
                                      backgroundImage: NetworkImage(
                                        streamSnapshot.data.docs[index]
                                            ['imageUrl'],
                                      ),
                                    ),
                                    Container(
                                      width: deviceSize.width * 0.65,
                                      padding: const EdgeInsets.all(5),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  streamSnapshot
                                                      .data.docs[index]['name'],
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      '\u20B9 ' +
                                                          streamSnapshot
                                                              .data
                                                              .docs[index]
                                                                  ['price']
                                                              .toString(),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          if (streamSnapshot.data.docs[index]
                                              ['isVeg'])
                                            Text('Veg'),
                                          Container(
                                            alignment: Alignment.center,
                                            child: Switch(
                                              value: !streamSnapshot
                                                  .data.docs[index]['isVeg'],
                                              onChanged: (_) {},
                                              activeTrackColor: Colors.red,
                                              activeColor: Colors.red,
                                              inactiveTrackColor: Colors.green,
                                              inactiveThumbColor: Colors.green,
                                            ),
                                          ),
                                          if (!streamSnapshot.data.docs[index]
                                              ['isVeg'])
                                            Text('Non Veg'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
