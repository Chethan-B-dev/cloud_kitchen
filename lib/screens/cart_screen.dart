import 'package:cloud_kitchen/services/cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../helpers/hex_color.dart';
import '../helpers/error.dart';
import 'package:badges/badges.dart';

class CartScreen extends StatefulWidget {
  static String routeName = '/cart';
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    final snackBar = SnackBar(
      duration: Duration(seconds: 1),
      content: Text(
        'Swipe left to remove cart items',
      ),
    );
    Future(() => ScaffoldMessenger.of(context).showSnackBar(snackBar));
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> data =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    final cart = Provider.of<Cart>(context, listen: false);
    if (data != null) {
      String foodId = data['foodId'];
      String kitchenId = data['kitchenId'];
      if (cart.checkKitchenID(kitchenId)) {
        (BuildContext context) async {
          try {
            await cart.addItem(foodId);
          } catch (err) {
            ShowError.showError(err.toString(), context);
          }
        }(context);
        print('done added item to cart');
        print(cart.items);
      } else {
        ShowError.showError(
          'you Can only add food from one restaurant',
          context,
        );
      }
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFFFAFAFA),
        elevation: 8.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF3a3737),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Item Carts",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        brightness: Brightness.light,
        actions: <Widget>[
          Consumer<Cart>(
            child: IconButton(
              onPressed: null,
              icon: Icon(
                Icons.shopping_cart,
                color: Colors.black,
              ),
            ),
            builder: (context, cart, child) => Badge(
              position: BadgePosition.topEnd(top: 0, end: 3),
              animationDuration: Duration(milliseconds: 300),
              animationType: BadgeAnimationType.slide,
              badgeContent: Text(
                cart.itemCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              child: child,
            ),
          ),
          Tooltip(
            message: 'Clear Cart',
            child: IconButton(
              color: Colors.black,
              onPressed: () async {
                try {
                  await Provider.of<Cart>(context, listen: false).clear();
                } catch (err) {
                  ShowError.showError(err.toString(), context);
                }
              },
              icon: Icon(
                Icons.remove_shopping_cart_rounded,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Consumer<Cart>(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      iconSize: 25,
                      //color: Colors.red,
                      onPressed: () {},
                      icon: Icon(
                        Icons.delete,
                      ),
                    )
                  ],
                ),
              ),
              builder: (context, cart, child) {
                if (cart.itemCount == 0) {
                  return Center(
                    child: Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Text('Cart is Empty'),
                    ),
                  );
                }

                return ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: cart.itemCount,
                  itemBuilder: (ctx, index) => Dismissible(
                    background: child,
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) async {
                      try {
                        await Provider.of<Cart>(context, listen: false)
                            .removeItem(
                          cart.items.values.toList()[index].cartId,
                          cart.items.values.toList()[index].foodId,
                        );
                      } catch (err) {
                        ShowError.showError(err.toString(), context);
                      }
                    },
                    key: ValueKey(cart.items.values.toList()[index].foodId),
                    child: CartItem(
                      cartId: cart.items.values.toList()[index].cartId,
                      productid: cart.items.values.toList()[index].foodId,
                      productName: cart.items.values.toList()[index].title,
                      productPrice: cart.items.values.toList()[index].price,
                      productImage: cart.items.values.toList()[index].imageUrl,
                      productCartQuantity:
                          cart.items.values.toList()[index].quantity,
                    ),
                  ),
                );
              },
            ),
            TotalCalculationWidget(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Tooltip(
        message: "Place Order",
        child: Padding(
          padding: EdgeInsets.only(bottom: 30, right: 10),
          child: Consumer<Cart>(
            child: Icon(Icons.save),
            builder: (context, value, child) {
              return FloatingActionButton(
                child: child,
                backgroundColor: HexColor('#424242'),
                onPressed: () async {
                  if (cart.itemCount == 0) {
                    ShowError.showError(
                      'Cart is empty,Please add items before you place an order',
                      context,
                    );
                    return;
                  }
                  try {
                    await cart.placeOrder();
                    await cart.clear();
                    Navigator.of(context).pushReplacementNamed('/order-status');
                  } catch (err) {
                    ShowError.showError(err.toString(), context);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class TotalCalculationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xFFfae3e2).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Card(
        color: Colors.white,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Consumer<Cart>(
          child: Expanded(
            child: Text(
              "Total",
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF3a3a3b),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          builder: (context, cart, ch) {
            if (cart.itemCount == 0) {
              return Container();
            }

            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(
                left: 25,
                right: 30,
                top: 10,
                bottom: 10,
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    itemCount: cart.itemCount,
                    itemBuilder: (ctx, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                cart.items.values.toList()[index].title,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF3a3a3b),
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.center,
                              child: Text(
                                "x${cart.items.values.toList()[index].quantity}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF3a3a3b),
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '\u20B9 ' +
                                    cart.items.values
                                        .toList()[index]
                                        .price
                                        .toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF3a3a3b),
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ch,
                      Expanded(
                        child: Text(
                          '\u20B9 ' + cart.totalAmount.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.pink,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final String productName;
  final String productid;
  final String cartId;
  final num productPrice;
  final String productImage;
  final num productCartQuantity;

  const CartItem({
    Key key,
    @required this.productName,
    @required this.productid,
    @required this.cartId,
    @required this.productPrice,
    @required this.productImage,
    @required this.productCartQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xFFfae3e2).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Card(
        color: Colors.white,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: double.infinity,
                    minHeight: double.infinity,
                  ),
                  child: Image.network(
                    productImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          productName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '\u20B9 ' + productPrice.toStringAsFixed(2),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        alignment: Alignment.center,
                        child: AddToCartMenu(
                          productCartQuantity,
                          productid,
                          cartId,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AddToCartMenu extends StatelessWidget {
  final int productCounter;
  final String productId;
  final String cartId;

  const AddToCartMenu(this.productCounter, this.productId, this.cartId);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: IconButton(
              onPressed: () async {
                try {
                  await Provider.of<Cart>(context, listen: false)
                      .decQuantity(productId, cartId);
                } catch (err) {
                  ShowError.showError(err.toString(), context);
                }
              },
              icon: Icon(Icons.remove),
              color: Colors.black,
              iconSize: 14,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => print('hello'),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  productCounter.toString(),
                ),
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () async {
                try {
                  await Provider.of<Cart>(context, listen: false)
                      .addItem(productId);
                } catch (err) {
                  ShowError.showError(err.toString(), context);
                }
              },
              icon: Icon(Icons.add),
              color: Color(0xFFfd2c2c),
              iconSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
