import 'package:flutter/material.dart';

class AddMenuItems extends StatefulWidget {
  const AddMenuItems({Key key}) : super(key: key);

  static String routeName = '/add-menu-items';

  @override
  _AddMenuItemsState createState() => _AddMenuItemsState();
}

class _AddMenuItemsState extends State<AddMenuItems> {
  bool isNonVeg = true;
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Menu Items',
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/food');
            },
            icon: Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (ctx, index) {
                return Card(
                  elevation: 8.0,
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                      height: deviceSize.height * 0.1,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage: NetworkImage(
                                'https://post.greatist.com/wp-content/uploads/2020/09/healthy-eating-ingredients-1200x628-facebook-1200x628.jpg'),
                          ),
                          Container(
                            // decoration: BoxDecoration(
                            //   border: Border.all(
                            //     color: Colors.red,
                            //   ),
                            // ),
                            width: deviceSize.width * 0.65,
                            padding: EdgeInsets.all(5),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Chicken manchuri',
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Text(
                                            '\u20B9 15.00',
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (!isNonVeg) Text('Veg'),
                                Container(
                                  // decoration: BoxDecoration(
                                  //   border: Border.all(
                                  //     color: Colors.red,
                                  //   ),
                                  // ),
                                  alignment: Alignment.center,
                                  child: Switch(
                                    value: isNonVeg ? true : false,
                                    onChanged: null,
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
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
