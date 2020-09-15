import 'package:canteen_food_ordering_app/apis/foodAPIs.dart';
import 'package:canteen_food_ordering_app/notifiers/authNotifier.dart';
import 'package:canteen_food_ordering_app/screens/adminHome.dart';
import 'package:canteen_food_ordering_app/screens/login.dart';
import 'package:canteen_food_ordering_app/screens/navigationBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:foodlab/api/food_api.dart';
// import 'package:foodlab/screens/login_signup_page.dart';
// import 'package:foodlab/notifier/auth_notifier.dart';
// import 'package:foodlab/screens/navigation_bar.dart';
// import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    initializeCurrentUser(authNotifier, context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(255, 138, 120, 1),
              Color.fromRGBO(255, 114, 117, 1),
              Color.fromRGBO(255, 63, 111, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Cassia',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'MuseoModerno',
              ),
            ),
            Text(
              '',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 17,
                color: Color.fromRGBO(252, 188, 126, 1),
              ),
            ),
            SizedBox(
              height: 140,
            ),
            GestureDetector(
              onTap: () {
                (authNotifier.user == null)? Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (BuildContext context) {
                    return LoginPage();
                  })) : 
                (authNotifier.userDetails == null) ? print('wait') : 
                  (authNotifier.userDetails.role == 'admin')? 
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (BuildContext context) {
                        return AdminHomePage();       
                      },
                    )):  Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (BuildContext context) {
                        return NavigationBarPage(selectedIndex: 1);       
                      },
                    ));
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Explore",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(255, 63, 111, 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
