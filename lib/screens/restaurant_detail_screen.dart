import 'package:flutter/material.dart';
import '../screens/cart_screen.dart';

class RestaurantDetail extends StatefulWidget {
  static String routeName = '/details';
  @override
  _RestaurantDetailState createState() => _RestaurantDetailState();
}

class _RestaurantDetailState extends State<RestaurantDetail> {
  @override
  Widget build(BuildContext context) {
    String id = ModalRoute.of(context).settings.arguments as String;
    final appBar = AppBar(
      title: Text('Restaurant name'),
    );

    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemBuilder: (ctx, index) {
            return BestFoodTiles(
              name: "Fried Egg",
              imageUrl: "ic_popular_food_1",
              rating: '4.9',
              numberOfRating: '200',
              price: '15.06',
              slug: "fried_egg",
            );
          },
          itemCount: 10,
        ),
      ),
    );
  }
}

class BestFoodTiles extends StatelessWidget {
  String name;
  String imageUrl;
  String rating;
  String numberOfRating;
  String price;
  String slug;

  BestFoodTiles({
    Key key,
    @required this.name,
    @required this.imageUrl,
    @required this.rating,
    @required this.numberOfRating,
    @required this.price,
    @required this.slug,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('hello world');
      },
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Card(
          color: Colors.white,
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: Container(
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Container(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFmzJPj0oOrzDyeqygSlw29cp_kQ5ZTpksGQ&usqp=CAU',
                    fit: BoxFit.cover,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(left: 5, top: 10),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/cart');
                          },
                          icon: Icon(
                            Icons.shopping_cart,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(left: 5, top: 5),
                        child: Text(
                          name,
                          style: TextStyle(
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
                        padding: EdgeInsets.only(left: 5, top: 5, right: 5),
                        child: Text(
                          '\$' + price,
                          style: TextStyle(
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
