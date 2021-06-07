import 'package:cloud_kitchen/helpers/hex_color.dart';
import 'package:flutter/material.dart';

enum OrderStatusEnum { done, not_done }

class OrderStatus extends StatefulWidget {
  const OrderStatus({Key key}) : super(key: key);

  static String routeName = '/order-status';

  @override
  _OrderStatusState createState() => _OrderStatusState();
}

class _OrderStatusState extends State<OrderStatus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Status'),
      ),
      body: Column(
        children: <Widget>[
          OrderStatusItem(
            title: 'Order placed',
            subtitle: 'We have recieved your order',
            image:
                'https://cdn4.iconfinder.com/data/icons/web-development-63/64/z-43-512.png',
            status: OrderStatusEnum.done,
          ),
          OrderStatusItem(
            title: 'Order confirmed',
            subtitle: 'Your Order has been confirmed',
            image: 'https://image.flaticon.com/icons/png/128/3496/3496155.png',
            status: OrderStatusEnum.not_done,
          ),
          OrderStatusItem(
            title: 'Order Processed',
            subtitle: 'We are preparing your food',
            image:
                'https://cdn.iconscout.com/icon/premium/png-256-thumb/preparing-food-1082095.png',
            status: OrderStatusEnum.not_done,
          ),
          OrderStatusItem(
            title: 'Ready to pickup',
            subtitle: 'Your order is ready for pickup',
            image:
                'https://cdn0.iconfinder.com/data/icons/lined-shipping-3/64/Box_check_delivering_package_pickup_pin_shipping-512.png',
            status: OrderStatusEnum.not_done,
          )
        ],
      ),
    );
  }
}

class OrderStatusItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final OrderStatusEnum status;
  final String image;
  const OrderStatusItem({
    Key key,
    this.title,
    this.subtitle,
    this.status,
    this.image,
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
              selected: true,
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
