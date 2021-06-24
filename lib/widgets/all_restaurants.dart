import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_kitchen/helpers/loading_card.dart';
import 'package:cloud_kitchen/services/kitchens.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class AllRestaurants extends StatefulWidget {
  final String searchQuery;

  const AllRestaurants(this.searchQuery);
  @override
  _AllRestaurantsState createState() => _AllRestaurantsState();
}

class _AllRestaurantsState extends State<AllRestaurants> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: AllRestaurantsTitle(),
        ),
        Expanded(
          child: AllRestaurantsList(widget.searchQuery.toLowerCase()),
        ),
      ],
    );
  }
}

class AllRestaurantsTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: const Text(
        "All Restaurants",
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class AllRestaurantsTile extends StatefulWidget {
  final String id;
  final String name;
  final String imageUrl;
  final num rating;
  final num numberOfRating;

  const AllRestaurantsTile({
    Key key,
    @required this.id,
    @required this.name,
    @required this.imageUrl,
    @required this.rating,
    @required this.numberOfRating,
  }) : super(key: key);

  @override
  _AllRestaurantsTileState createState() => _AllRestaurantsTileState();
}

class _AllRestaurantsTileState extends State<AllRestaurantsTile> {
  @override
  Widget build(BuildContext context) {
    num actualRating = 0.0;

    if (widget.numberOfRating != 0) {
      setState(() {
        actualRating = widget.rating.toInt() / widget.numberOfRating.toInt();
      });
    }

    return Container(
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
          onTap: () {
            Navigator.of(context).pushNamed(
              '/details',
              arguments: widget.id,
            );
          },
          child: Container(
            width: double.infinity,
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: FadeInImage(
                    fit: BoxFit.cover,
                    height: 200,
                    placeholder: AssetImage(
                      'assets/images/place.png',
                    ),
                    image: NetworkImage(
                      widget.imageUrl,
                    ),
                  ),
                  // child: Image.network(
                  //   widget.imageUrl,
                  //   fit: BoxFit.cover,
                  //   height: 200,
                  // ),
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.only(left: 5, top: 5),
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            if (actualRating != 0.0)
                              Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 5, top: 5),
                                child: Text(
                                  actualRating.toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.only(top: 3, left: 5),
                              child: SmoothStarRating(
                                borderColor: Colors.white,
                                isReadOnly: true,
                                color: Colors.yellow,
                                rating: actualRating,
                                size: 10,
                                starCount: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Tooltip(
                        message: 'Number of people rated',
                        child: Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            widget.numberOfRating.toStringAsFixed(0),
                            style: const TextStyle(
                              color: Colors.white,
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
      ),
    );
  }
}

class AllRestaurantsList extends StatelessWidget {
  final String searchQuery;

  AllRestaurantsList(this.searchQuery);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: (searchQuery != "" && searchQuery != null)
          ? Kitchens().searchKitchen(searchQuery)
          : Kitchens().allKitchens,
      builder: (context, streamSnapshot) {
        if (streamSnapshot.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return LoadingCard();
        }

        if (streamSnapshot.data.docs.length == 0) {
          return const Center(
            child: Text('wow such empty'),
          );
        }

        return ListView.builder(
          itemCount: streamSnapshot.data.docs.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) => AllRestaurantsTile(
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
