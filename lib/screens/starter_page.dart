import 'package:cloud_kitchen/screens/restaurant_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class StarterPage extends StatefulWidget {
  @override
  _StarterPageState createState() => _StarterPageState();
}

class _StarterPageState extends State<StarterPage>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  bool _textVisible = true;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));

    _animation =
        Tween<double>(begin: 1.0, end: 25.0).animate(_animationController);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  void _onTap() {
    setState(() {
      _textVisible = false;
    });

    _animationController.forward().then((f) => Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.fade, child: RestaurantOverview())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(
                    'https://i.pinimg.com/originals/f4/6d/ac/f46dac364207e409b17506fc4543bc0e.jpg'),
                fit: BoxFit.cover)),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [
            Colors.black.withOpacity(.9),
            Colors.black.withOpacity(.8),
            Colors.black.withOpacity(.2),
          ])),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Home cooked meals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "This App was designed as a mini-project by 6th sem MCE Students.",
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.4,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                ScaleTransition(
                    scale: _animation,
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                                colors: [Colors.yellow, Colors.orange])),
                        child: AnimatedOpacity(
                          opacity: _textVisible ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 50),
                          child: MaterialButton(
                            onPressed: () => _onTap(),
                            minWidth: double.infinity,
                            child: Text(
                              "Start",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ))),
                SizedBox(
                  height: 30,
                ),
                AnimatedOpacity(
                  opacity: _textVisible ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 50),
                  child: Align(
                    child: Text(
                      "A taste of home",
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
