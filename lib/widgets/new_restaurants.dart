import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_kitchen/helpers/loading_card.dart';
import 'package:cloud_kitchen/services/kitchens.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class NewRestaurants extends StatefulWidget {
  final String searchQuery;

  const NewRestaurants(this.searchQuery);

  @override
  _NewRestaurantsState createState() => _NewRestaurantsState();
}

class _NewRestaurantsState extends State<NewRestaurants> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 5,
        bottom: 5,
      ),
      width: double.infinity,
      child: Column(
        children: <Widget>[
          NewRestaurantsTitle(),
          Flexible(
            child: NewRestaurantItems(widget.searchQuery.toLowerCase()),
          ),
        ],
      ),
    );
  }
}

class NewRestaurantTile extends StatelessWidget {
  final String id;
  final String name;
  final String imageUrl;
  final num rating;
  final num numberOfRating;

  const NewRestaurantTile({
    Key key,
    @required this.id,
    @required this.name,
    @required this.imageUrl,
    @required this.rating,
    @required this.numberOfRating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    num actualRating = 0.0;

    if (numberOfRating != 0) {
      actualRating = rating.toInt() / numberOfRating.toInt();
    }

    return Card(
      color: Colors.white,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(
            5.0,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/details',
            arguments: id,
          );
        },
        child: Container(
          width: 200,
          child: Column(
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  height: 130,
                ),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.only(left: 5, top: 5),
                child: Text(
                  name,
                  style: TextStyle(
                    color: Color(0xFF6e6e71),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(left: 5, top: 5),
                          child: Text(
                            actualRating.toStringAsFixed(2),
                            style: TextStyle(
                              color: Color(0xFF6e6e71),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 3, left: 5),
                          child: SmoothStarRating(
                            color: Colors.red,
                            rating: actualRating,
                            size: 10,
                            starCount: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Tooltip(
                      message: 'Number of people rated',
                      child: Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 5),
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          numberOfRating.toStringAsFixed(0),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
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

class NewRestaurantsTitle extends StatelessWidget {
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
  final String searchQuery;

  NewRestaurantItems(this.searchQuery);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: (searchQuery != "" && searchQuery != null)
          ? Kitchens().searchKitchen(searchQuery)
          : Kitchens().newKitchens,
      builder: (context, streamSnapshot) {
        if (streamSnapshot.hasError) {
          return Text('Something went wrong');
        }

        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return LoadingCard();
        }

        if (streamSnapshot.data.docs.length == 0) {
          return Center(
            child: Text('wow such empty'),
          );
        }

        print(streamSnapshot.data.docs);

        return ListView.builder(
          itemCount: streamSnapshot.data.docs.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) => NewRestaurantTile(
            id: streamSnapshot.data.docs[index].id,
            name: streamSnapshot.data.docs[index]['kname'],
            imageUrl: streamSnapshot.data.docs[index]['imageUrl'],
            rating: streamSnapshot.data.docs[index]['rating'],
            numberOfRating: streamSnapshot.data.docs[index]['noOfRating'],
          ),
        );
      },
    );
  }
}
