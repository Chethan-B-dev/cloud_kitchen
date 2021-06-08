import 'package:flutter/material.dart';
import '../helpers/hex_color.dart';

class BecomeSeller extends StatefulWidget {
  const BecomeSeller({Key key}) : super(key: key);

  static String routeName = '/seller';

  @override
  _BecomeSellerState createState() => _BecomeSellerState();
}

class _BecomeSellerState extends State<BecomeSeller> {
  final _controller = TextEditingController();
  bool isNonVeg = false;

  void toggleSwitch(bool value) {
    setState(() {
      isNonVeg = !isNonVeg;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Become Seller'),
        actions: [
          IconButton(
            onPressed: () {
              print('clicked button');
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: deviceSize.width * 0.65,
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: false,
                    enableSuggestions: true,
                    decoration: InputDecoration(labelText: 'Kitchen Name'),
                    onChanged: (value) {
                      print(_controller.text);
                    },
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isNonVeg) Text('Veg'),
                      Container(
                        alignment: Alignment.center,
                        child: Switch(
                          value: isNonVeg,
                          onChanged: toggleSwitch,
                          activeTrackColor: Colors.redAccent,
                          activeColor: Colors.redAccent,
                          inactiveThumbColor: Colors.green,
                          inactiveTrackColor: Colors.green,
                        ),
                      ),
                      if (isNonVeg) Text('Non Veg'),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                'Seller Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 8.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.kitchen),
                        title: Text('name'),
                        subtitle: Text('hello world'),
                      ),
                      ListTile(
                        leading: Icon(Icons.kitchen),
                        title: Text('email'),
                        subtitle: Text('hello world'),
                      ),
                      ListTile(
                        leading: Icon(Icons.kitchen),
                        title: Text('location'),
                        subtitle: Text(
                            'bangaloredsaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
                      ),
                      ListTile(
                        leading: Icon(Icons.kitchen),
                        title: Text('phone number'),
                        subtitle: Text('hello world'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Tooltip(
        message: "Add Menu",
        child: Padding(
          padding: EdgeInsets.only(bottom: 30, right: 10),
          child: FloatingActionButton(
            child: Icon(Icons.menu_book_sharp),
            backgroundColor: HexColor('#424242'),
            onPressed: () {
              Navigator.of(context).pushNamed('/add-menu-items');
            },
          ),
        ),
      ),
    );
  }
}
