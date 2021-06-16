import 'package:cloud_kitchen/helpers/error.dart';
import 'package:cloud_kitchen/helpers/loading_card.dart';
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
  var _isLoading = false;
  @override
  void initState() {
    super.initState();
    final snackBar = SnackBar(
      backgroundColor: Colors.cyan,
      duration: Duration(seconds: 2),
      content: Text(
        'Swipe left to remove food items',
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
        centerTitle: true,
        title: FutureBuilder(
          future: Kitchens().kitchenName,
          builder: (ctx, snapshot) {
            if (snapshot.hasError) {
              return const Text('Add menu items');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator(
                color: Colors.yellow,
              );
            }
            return Text(snapshot.data);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/food');
            },
            icon: const Icon(
              Icons.add,
              color: Colors.yellow,
            ),
          ),
          IconButton(
            onPressed: () {
              print("edit item");
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.yellow,
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
                  return const Center(
                    child: Text(
                      'Something went wrong',
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingCard();
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: snapshot.data,
                  builder: (context, streamSnapshot) {
                    if (streamSnapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
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
                          height: MediaQuery.of(context).size.height * .6,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  'https://image.flaticon.com/icons/png/512/2007/2007606.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    'Menu is Empty, Add Some Food Items!',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w600,
                                    ),
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
                                const IconButton(
                                  onPressed: null,
                                  iconSize: 25,
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
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
                                            const Text('Veg'),
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
                                            const Text('Non Veg'),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _isLoading
          ? Container(
              margin: const EdgeInsets.only(bottom: 15, left: 10),
              alignment: Alignment.center,
              width: 40.0,
              height: 20.0,
              child: SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(
                  color: Colors.yellow,
                ),
              ),
            )
          : Tooltip(
              message: "Delete kitchen",
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30, right: 10),
                child: FloatingActionButton(
                  child: const Icon(
                    Icons.delete,
                    color: Colors.black,
                  ),
                  backgroundColor: Colors.yellow,
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text(
                        'Delete Restaurant',
                        style: const TextStyle(
                          color: Colors.yellow,
                        ),
                      ),
                      content: const Text(
                          'Are You sure you want to Delete your kitchen?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await Kitchens().deleteKitchen();
                              Navigator.of(context)
                                  .pushReplacementNamed('/restaurants');
                            } catch (err) {
                              ShowError.showError(err.toString(), context);
                            }
                          },
                          child: const Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('No'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
