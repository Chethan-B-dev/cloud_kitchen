import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_kitchen/helpers/error.dart';
import 'package:cloud_kitchen/services/cart.dart';
import 'package:cloud_kitchen/services/kitchens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_placeholder_textlines/placeholder_lines.dart';
import 'package:provider/provider.dart';

class RestaurantDetail extends StatefulWidget {
  static String routeName = '/details';
  @override
  _RestaurantDetailState createState() => _RestaurantDetailState();
}

class _RestaurantDetailState extends State<RestaurantDetail> {
  @override
  Widget build(BuildContext context) {
    String kitchenId = ModalRoute.of(context).settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: Kitchens().kitchenNameFromId(kitchenId),
          builder: (ctx, snapshot) {
            if (snapshot.hasError) {
              return const Text('Menu');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator(
                color: Colors.yellow,
              );
            }
            return Text(snapshot.data);
          },
        ),
        actions: <Widget>[
          Consumer<Cart>(
            child: IconButton(
              padding: const EdgeInsets.only(right: 10),
              onPressed: () {
                Navigator.of(context).pushNamed('/cart');
              },
              icon: const Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
            ),
            builder: (context, cart, child) => Badge(
              position: BadgePosition.topEnd(top: 0, end: 3),
              animationDuration: Duration(milliseconds: 300),
              animationType: BadgeAnimationType.slide,
              badgeContent: Text(
                cart.itemCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              child: child,
            ),
          ),
          // IconButton(
          //   onPressed: () => showDialog<String>(
          //     context: context,
          //     builder: (BuildContext context) => AlertDialog(
          //       title: const Text(
          //         'Logout',
          //         style: const TextStyle(
          //           color: Colors.pink,
          //         ),
          //       ),
          //       content: const Text('Are You sure you want to logout?'),
          //       actions: <Widget>[
          //         TextButton(
          //           onPressed: () async {
          //             await Provider.of<Cart>(context, listen: false).clear();
          //             await AuthService().signOut();
          //             Navigator.popUntil(context, ModalRoute.withName("/"));
          //           },
          //           child: const Text('Yes'),
          //         ),
          //         TextButton(
          //           onPressed: () => Navigator.pop(context, 'Cancel'),
          //           child: const Text('No'),
          //         ),
          //       ],
          //     ),
          //   ),
          //   icon: const Icon(
          //     Icons.logout,
          //     size: 26.0,
          //   ),
          // )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Kitchens().kitchenFoods(kitchenId),
        builder: (context, streamSnapshot) {
          if (streamSnapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong',
              ),
            );
          }

          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return Material(
              borderRadius: BorderRadius.circular(10),
              elevation: 9,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.6),
                      ),
                      child: const Center(
                        child: const Icon(
                          Icons.photo_size_select_actual,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                    Expanded(
                      child: const PlaceholderLines(
                        count: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
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
                      child: Image.asset(
                        'assets/images/menu.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(10),
                        child: const Text(
                          'Menu is Empty!',
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
            itemCount: streamSnapshot.data.docs.length,
            itemBuilder: (ctx, index) => RestaurantDetailTile(
              id: streamSnapshot.data.docs[index].id,
              kitchenID: kitchenId,
              name: streamSnapshot.data.docs[index]['name'],
              imageUrl: streamSnapshot.data.docs[index]['imageUrl'],
              price: streamSnapshot.data.docs[index]['price'],
              isVeg: streamSnapshot.data.docs[index]['isVeg'],
              isInCart: Provider.of<Cart>(context).isInCart(
                streamSnapshot.data.docs[index].id,
              ),
            ),
          );
        },
      ),
    );
  }
}

class RestaurantDetailTile extends StatefulWidget {
  final String id;
  final String kitchenID;
  final String name;
  final String imageUrl;
  final double price;
  final bool isVeg;
  final List isInCart;

  const RestaurantDetailTile({
    Key key,
    @required this.id,
    @required this.kitchenID,
    @required this.name,
    @required this.imageUrl,
    @required this.price,
    @required this.isVeg,
    @required this.isInCart,
  }) : super(key: key);

  @override
  _RestaurantDetailTileState createState() => _RestaurantDetailTileState();
}

class _RestaurantDetailTileState extends State<RestaurantDetailTile> {
  bool _isAdded = false;
  String cartId;
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    _isAdded = widget.isInCart[0];
    cartId = widget.isInCart[1];
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Card(
        color: ThemeData.dark().cardColor,
        elevation: 8.0,
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: InkWell(
          onTap: () {},
          child: Container(
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Stack(
                  children: [
                    FadeInImage(
                      width: double.infinity,
                      fit: BoxFit.cover,
                      height: 200,
                      placeholder: AssetImage(
                        'assets/images/place.png',
                      ),
                      image: NetworkImage(
                        widget.imageUrl,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.centerRight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.crop_square_sharp,
                            color: widget.isVeg ? Colors.green : Colors.red,
                            size: 36,
                          ),
                          Icon(
                            Icons.circle,
                            color: widget.isVeg ? Colors.green : Colors.red,
                            size: 14,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(left: 5, top: 5),
                        child: IconButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            final cart =
                                Provider.of<Cart>(context, listen: false);
                            if (!await cart.checkKitchenID(widget.kitchenID)) {
                              ShowError.showError(
                                'can not add food from multiple kitchens into cart',
                                context,
                              );
                              setState(() {
                                _isLoading = false;
                              });
                              return;
                            }

                            if (!_isAdded) {
                              setState(() {
                                _isAdded = true;
                              });

                              await cart.addItem(widget.id);
                            } else {
                              await cart.removeItem(cartId, widget.id);
                              setState(() {
                                _isAdded = false;
                              });
                            }
                            setState(() {
                              _isLoading = false;
                            });

                            // Navigator.of(context).pushNamed(
                            //   '/cart',
                            //   arguments: {
                            //     'foodId': id,
                            //     'kitchenId': kitchenID,
                            //   },
                            // );
                          },
                          icon: _isLoading
                              ? Container(
                                  alignment: Alignment.center,
                                  width: 10.0,
                                  height: 10.0,
                                  child: SizedBox(
                                    height: 15,
                                    width: 10,
                                    child: CircularProgressIndicator(
                                      color: Colors.yellow,
                                    ),
                                  ),
                                )
                              : !_isAdded
                                  ? Icon(
                                      Icons.add_shopping_cart_rounded,
                                      color: Colors.yellow,
                                    )
                                  : Icon(
                                      Icons.remove_shopping_cart,
                                      color: Colors.yellow,
                                    ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(left: 5, top: 5),
                        child: Text(
                          widget.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          softWrap: true,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(left: 5, top: 5),
                        child: Text(
                          '\u20B9 ' + widget.price.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          softWrap: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
