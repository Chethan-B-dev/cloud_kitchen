import 'package:cloud_kitchen/helpers/error.dart';
import 'package:cloud_kitchen/helpers/hex_color.dart';
import 'package:cloud_kitchen/helpers/loading_card.dart';
import 'package:cloud_kitchen/services/users.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

enum OrderStatusEnum { done, not_done }
enum OrderStatusValue {
  order_placed,
  order_confirmed,
  order_processed,
  ready_to_pickup,
}

class OrderStatus extends StatefulWidget {
  const OrderStatus({Key key}) : super(key: key);

  static String routeName = '/order-status';

  @override
  _OrderStatusState createState() => _OrderStatusState();
}

class _OrderStatusState extends State<OrderStatus> {
  var rating = 0.0;
  String kitchenId;
  bool rateButtonVisible = false;
  String orderStatus;
  void showNow() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: Container(
            height: 250,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Rate Restaurant',
                    style: Theme.of(context).textTheme.title,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SmoothStarRating(
                    rating: rating,
                    size: 45,
                    starCount: 5,
                    onRated: (value) {
                      setState(() {
                        rating = value;
                      });
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RaisedButton.icon(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () async {
                          print("Rating is $rating");
                          try {
                            await Users()
                                .completeOrder(kitchenId, false, rating);
                            Navigator.of(context)
                                .pushNamed('/restaurants', arguments: rating);
                          } catch (err) {
                            ShowError.showError(err.toString(), context);
                          }
                          Navigator.of(context)
                              .pushNamed('/restaurants', arguments: rating);
                        },
                        icon: Icon(Icons.rate_review_sharp),
                        label: Text(
                          'Rate',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      RaisedButton.icon(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () async {
                          try {
                            await Users().completeOrder(kitchenId, true, null);
                            Navigator.of(context)
                                .pushNamed('/restaurants', arguments: rating);
                          } catch (err) {
                            ShowError.showError(err.toString(), context);
                          }
                        },
                        icon: Icon(Icons.door_back),
                        label: Text(
                          'skip',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    kitchenId = ModalRoute.of(context).settings.arguments as String;

    return StreamBuilder<Map>(
      stream: Users().orderStatus(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Something Went Wrong'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingCard();
        }

        kitchenId = snapshot.data?.keys?.toList()[0] as String;

        orderStatus = snapshot.data?.values?.toList()[0] as String;

        List<OrderStatusEnum> status = [];

        OrderStatusValue.values.forEach((v) {
          if (v.index > int.parse(orderStatus)) {
            status.add(OrderStatusEnum.not_done);
          } else {
            status.add(OrderStatusEnum.done);
          }
        });

        List<bool> selected = [false, false, false, false];

        selected[int.parse(orderStatus)] = true;

        return Scaffold(
          appBar: AppBar(
            title: Text('Order status'),
          ),
          body: Column(
            children: <Widget>[
              OrderStatusItem(
                title: 'Order placed',
                subtitle: 'We have recieved your order',
                image:
                    'https://cdn4.iconfinder.com/data/icons/web-development-63/64/z-43-512.png',
                status: status[0],
                selected: selected[0],
              ),
              OrderStatusItem(
                title: 'Order confirmed',
                subtitle: 'Your Order has been confirmed',
                image:
                    'https://image.flaticon.com/icons/png/128/3496/3496155.png',
                status: status[1],
                selected: selected[1],
              ),
              OrderStatusItem(
                title: 'Order Processed',
                subtitle: 'We are preparing your food',
                image:
                    'https://cdn.iconscout.com/icon/premium/png-256-thumb/preparing-food-1082095.png',
                status: status[2],
                selected: selected[2],
              ),
              OrderStatusItem(
                title: 'Ready to pickup',
                subtitle: 'Your order is ready for pickup',
                image:
                    'https://cdn0.iconfinder.com/data/icons/lined-shipping-3/64/Box_check_delivering_package_pickup_pin_shipping-512.png',
                status: status[3],
                selected: selected[3],
              )
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton: Visibility(
            visible: orderStatus == "3" ? true : false,
            child: Tooltip(
              message: "Rate Restaurant",
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30, right: 10),
                child: FloatingActionButton(
                  child: Icon(Icons.rate_review),
                  backgroundColor: HexColor('#424242'),
                  onPressed: showNow,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class OrderStatusItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final OrderStatusEnum status;
  final String image;
  final bool selected;
  const OrderStatusItem({
    Key key,
    this.title,
    this.subtitle,
    this.status,
    this.image,
    this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          alignment: Alignment.center,
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: ListTile(
              selectedTileColor: HexColor('#EEEEEE'),
              leading: status == OrderStatusEnum.done
                  ? Icon(Icons.done_all_rounded)
                  : CircularProgressIndicator(),
              title: Text(
                title,
                textScaleFactor: 1.5,
                style: TextStyle(color: Colors.black),
              ),
              //trailing: Icon(Icons.done),
              subtitle: Text(
                subtitle,
                style: TextStyle(color: Colors.black),
              ),
              selected: selected,
              trailing: Image.network(
                image,
                fit: BoxFit.cover,
              ),
              onTap: () {},
            ),
          ),
        ),
      ),
    );
  }
}
