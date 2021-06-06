import 'package:flutter/material.dart';

class BestFoodWidget extends StatefulWidget {
  @override
  _BestFoodWidgetState createState() => _BestFoodWidgetState();
}

class _BestFoodWidgetState extends State<BestFoodWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: BestFoodTitle(),
        ),
        Expanded(
          child: BestFoodList(),
        ),
      ],
    );
  }
}

class BestFoodTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Text(
        "All Restaurants",
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

class BestFoodTiles extends StatelessWidget {
  String name;
  String imageUrl;
  String rating;
  String numberOfRating;
  String price;
  String slug;

  BestFoodTiles(
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
      onTap: () {},
      child: Column(
        children: <Widget>[
          Container(
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
                        width: double.infinity,
                        child: Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFmzJPj0oOrzDyeqygSlw29cp_kQ5ZTpksGQ&usqp=CAU',
                          fit: BoxFit.cover,
                        )),
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
          ),
        ],
      ),
    );
  }
}

class BestFoodList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        BestFoodTiles(
            name: "Fried Egg",
            imageUrl: "ic_best_food_8",
            rating: '4.9',
            numberOfRating: '200',
            price: '15.06',
            slug: "fried_egg"),
        BestFoodTiles(
            name: "Mixed vegetable",
            imageUrl: "ic_best_food_9",
            rating: "4.9",
            numberOfRating: "100",
            price: "17.03",
            slug: ""),
        BestFoodTiles(
            name: "Salad with chicken meat",
            imageUrl: "ic_best_food_10",
            rating: "4.0",
            numberOfRating: "50",
            price: "11.00",
            slug: ""),
        BestFoodTiles(
            name: "New mixed salad",
            imageUrl: "ic_best_food_5",
            rating: "4.00",
            numberOfRating: "100",
            price: "11.10",
            slug: ""),
        BestFoodTiles(
            name: "Red meat with salad",
            imageUrl: "ic_best_food_1",
            rating: "4.6",
            numberOfRating: "150",
            price: "12.00",
            slug: ""),
        BestFoodTiles(
            name: "New mixed salad",
            imageUrl: "ic_best_food_2",
            rating: "4.00",
            numberOfRating: "100",
            price: "11.10",
            slug: ""),
        BestFoodTiles(
            name: "Potato with meat fry",
            imageUrl: "ic_best_food_3",
            rating: "4.2",
            numberOfRating: "70",
            price: "23.0",
            slug: ""),
        BestFoodTiles(
            name: "Fried Egg",
            imageUrl: "ic_best_food_4",
            rating: '4.9',
            numberOfRating: '200',
            price: '15.06',
            slug: "fried_egg"),
        BestFoodTiles(
            name: "Red meat with salad",
            imageUrl: "ic_best_food_5",
            rating: "4.6",
            numberOfRating: "150",
            price: "12.00",
            slug: ""),
        BestFoodTiles(
            name: "Red meat with salad",
            imageUrl: "ic_best_food_6",
            rating: "4.6",
            numberOfRating: "150",
            price: "12.00",
            slug: ""),
        BestFoodTiles(
            name: "Red meat with salad",
            imageUrl: "ic_best_food_7",
            rating: "4.6",
            numberOfRating: "150",
            price: "12.00",
            slug: ""),
      ],
    );
  }
}
