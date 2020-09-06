import 'package:canteen_food_ordering_app/apis/foodAPIs.dart';
import 'package:canteen_food_ordering_app/notifiers/authNotifier.dart';
import 'package:canteen_food_ordering_app/widgets/customRaisedButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  signOutUser() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    if (authNotifier.user != null) {
      signOut(authNotifier, context);
    }
  }

  @override
  void initState() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);

    getUserDetails(authNotifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Food Lab'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              signOutUser();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 30, right: 10),
                ),
              ],
            ),
            // authNotifier.userDetails.profilePic != null
            //     ? CircleAvatar(
            //         radius: 40.0,
            //         backgroundImage:
            //             NetworkImage(authNotifier.userDetails.profilePic),
            //         backgroundColor: Colors.transparent,
            //       )
            //     : 
            Container(
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              width: 100,
              child: Icon(
                Icons.person,
                size: 70,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            authNotifier.userDetails.displayName != null
                ? Text(
                    authNotifier.userDetails.displayName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontFamily: 'MuseoModerno',
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text("You don't have a user name"),
            SizedBox(
              height: 10,
            ),
            // authNotifier.userDetails.bio != null
            // ? Text(
            //     authNotifier.userDetails.bio,
            //     style: TextStyle(fontSize: 15),
            //   )
            // : 
            Text(
              "Balance: 0 INR",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'MuseoModerno',
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (BuildContext context) {
                //     return EditProfile();
                //   }),
                // );
              },
              child: CustomRaisedButton(buttonText: 'Add Money'),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Order History",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'MuseoModerno',
              ),
              textAlign: TextAlign.left,
            ),
            // StreamBuilder<QuerySnapshot>(
            //   stream: Firestore.instance
            //       .collection('foods')
            //       .where('userUuidOfPost',
            //           isEqualTo: authNotifier.userDetails.uuid)
            //       .snapshots(),
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData && snapshot.data.documents.length > 0) {
            //       return Padding(
            //         padding: EdgeInsets.symmetric(horizontal: 20),
            //         child: GridView.builder(
            //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //               crossAxisCount: 3),
            //           shrinkWrap: true,
            //           physics: NeverScrollableScrollPhysics(),
            //           itemCount: snapshot.data.documents.length,
            //           itemBuilder: (context, index) {
            //             return Padding(
            //               padding:
            //                   EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            //               child: GestureDetector(
            //                 child: ClipRRect(
            //                   borderRadius: BorderRadius.circular(15),
            //                   child: Container(
            //                     child: Image.network(
            //                       snapshot.data.documents[index]['img'],
            //                       fit: BoxFit.cover,
            //                     ),
            //                   ),
            //                 ),
            //                 onTap: () {
            //                   Navigator.push(
            //                     context,
            //                     MaterialPageRoute(
            //                       builder: (BuildContext context) {
            //                         return FoodDetailPage(
            //                           imgUrl: snapshot.data.documents[index]
            //                               ['img'],
            //                           imageName: snapshot.data.documents[index]
            //                               ['name'],
            //                           imageCaption: snapshot
            //                               .data.documents[index]['caption'],
            //                           createdTimeOfPost: snapshot
            //                               .data.documents[index]['createdAt']
            //                               .toDate(),
            //                         );
            //                       },
            //                     ),
            //                   );
            //                 },
            //               ),
            //             );
            //           },
            //         ),
            //       );
            //     } else {
            //       return Container(
            //         padding: EdgeInsets.symmetric(vertical: 20),
            //         width: MediaQuery.of(context).size.width * 0.6,
            //         child: Image.asset('images/undraw_cooking_lyxy.png'),
            //       );
            //     }
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
