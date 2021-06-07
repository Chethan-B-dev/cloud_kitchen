import 'package:flutter/material.dart';

class NewRestaurants extends StatefulWidget {
  @override
  _NewRestaurantsState createState() => _NewRestaurantsState();
}

class _NewRestaurantsState extends State<NewRestaurants> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      width: double.infinity,
      child: Column(
        children: <Widget>[
          PopularFoodTitle(),
          Flexible(
            child: NewRestaurantItems(),
          ),
        ],
      ),
    );
  }
}

class PopularFoodTiles extends StatelessWidget {
  String name;
  String imageUrl;
  String rating;
  String numberOfRating;
  String price;
  String slug;

  PopularFoodTiles(
      {Key key,
      @required this.name,
      @required this.imageUrl,
      @required this.rating,
      @required this.numberOfRating,
      @required this.price,
      @required this.slug})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/details',
          arguments: '1',
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Container(
          width: 200,
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      alignment: Alignment.topRight,
                      width: double.infinity,
                      padding: EdgeInsets.only(right: 5, top: 5),
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white70,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFfae3e2),
                                blurRadius: 25.0,
                                offset: Offset(0.0, 0.75),
                              ),
                            ]),
                        child: Icon(
                          Icons.favorite,
                          color: Color(0xFFfb3132),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Center(
                      child: Image.network(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFmzJPj0oOrzDyeqygSlw29cp_kQ5ZTpksGQ&usqp=CAU',
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.only(left: 5, top: 5),
                    child: Text(name,
                        style: TextStyle(
                            color: Color(0xFF6e6e71),
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(left: 5, top: 5),
                        child: Text(rating,
                            style: TextStyle(
                                color: Color(0xFF6e6e71),
                                fontSize: 10,
                                fontWeight: FontWeight.w400)),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 3, left: 5),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.star,
                              size: 10,
                              color: Color(0xFFfb3132),
                            ),
                            Icon(
                              Icons.star,
                              size: 10,
                              color: Color(0xFFfb3132),
                            ),
                            Icon(
                              Icons.star,
                              size: 10,
                              color: Color(0xFFfb3132),
                            ),
                            Icon(
                              Icons.star,
                              size: 10,
                              color: Color(0xFFfb3132),
                            ),
                            Icon(
                              Icons.star,
                              size: 10,
                              color: Color(0xFF9b9b9c),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.only(left: 5, top: 5, right: 5),
                    child: Text(
                      '\$' + price,
                      style: TextStyle(
                        color: Color(0xFF6e6e71),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PopularFoodTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Text(
        "New Restaurants",
        style: TextStyle(
          fontSize: 20,
          color: Color(0xFF3a3a3b),
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class NewRestaurantItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        PopularFoodTiles(
            name: "Fried Egg",
            imageUrl: "ic_popular_food_1",
            rating: '4.9',
            numberOfRating: '200',
            price: '15.06',
            slug: "fried_egg"),
        PopularFoodTiles(
            name: "Mixed Vegetable",
            imageUrl: "ic_popular_food_3",
            rating: "4.9",
            numberOfRating: "100",
            price: "17.03",
            slug: ""),
        PopularFoodTiles(
            name: "Salad With Chicken",
            imageUrl: "ic_popular_food_4",
            rating: "4.0",
            numberOfRating: "50",
            price: "11.00",
            slug: ""),
      ],
    );
  }
}
