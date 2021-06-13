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
              return const Text('Add menu items');
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return Text(snapshot.data);
            }
            return const LinearProgressIndicator();
          },
        ),
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
                      child: Image.network(
                        'https://image.flaticon.com/icons/png/512/450/450210.png',
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
            ),
          );
        },
      ),
    );
  }
}

class RestaurantDetailTile extends StatelessWidget {
  final String id;
  final String kitchenID;
  final String name;
  final String imageUrl;
  final double price;
  final bool isVeg;

  const RestaurantDetailTile({
    Key key,
    @required this.id,
    @required this.kitchenID,
    @required this.name,
    @required this.imageUrl,
    @required this.price,
    @required this.isVeg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Card(
        color: Colors.white,
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
                    Container(
                      height: 200,
                      width: double.infinity,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
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
                            color: isVeg ? Colors.green : Colors.red,
                            size: 36,
                          ),
                          Icon(
                            Icons.circle,
                            color: isVeg ? Colors.green : Colors.red,
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
                            final cart =
                                Provider.of<Cart>(context, listen: false);
                            if (!await cart.checkKitchenID(kitchenID)) {
                              ShowError.showError(
                                'can not add food from multiple kitchens into cart',
                                context,
                              );
                              return;
                            }

                            Navigator.of(context).pushNamed(
                              '/cart',
                              arguments: {
                                'foodId': id,
                                'kitchenId': kitchenID,
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.add_shopping_cart_rounded,
                            color: Colors.pinkAccent,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(left: 5, top: 5),
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Color(0xFF6e6e71),
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
                          '\u20B9 ' + price.toString(),
                          style: const TextStyle(
                            color: Color(0xFF6e6e71),
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
