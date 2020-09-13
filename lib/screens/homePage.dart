import 'package:canteen_food_ordering_app/apis/foodAPIs.dart';
import 'package:canteen_food_ordering_app/notifiers/authNotifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:canteen_food_ordering_app/models/food.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> cartIds = new List<String>();
  
  @override
  void initState() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);

    getUserDetails(authNotifier);
    getCart(authNotifier.userDetails.uuid);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cassia'),
      ),
      body: 
      SingleChildScrollView(
        physics: ScrollPhysics(),
          child: Column(
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('items').where('total_qty', isGreaterThan: 0).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData && snapshot.data.documents.length > 0) {
                  return Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child:ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, int index) {
                      final item = snapshot.data.documents[index];
                      Food data = new Food(item.documentID, item['item_name'], item['total_qty'], item['price']);
                      return ListTile(
                        title: Text(data.itemName ?? ''),
                        subtitle: Text('cost: ${data.price.toString()}'),
                        trailing: IconButton(
                          icon: cartIds.contains(data.id)? new Icon(Icons.remove):new Icon(Icons.add),
                          onPressed: () async{
                            cartIds.contains(data.id)? 
                            await removeFromCart(data, context) : await addToCart(data, context);
                            setState(() {
                              getCart(authNotifier.userDetails.uuid);
                            });
                          },
                        )
                      );
                    }),
                  );
                } else {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text("No Items to display"),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void getCart(String uuid) async{
    List<String> ids = new List<String>();
    DocumentSnapshot snapshot = await Firestore.instance.collection('carts').document(uuid).get();
    var data = snapshot.data['items'];
    for(var i=0; i<data.length; i++){
      ids.add(data[i]['item_id']);
    }
    setState(() {
      cartIds = ids;
    });
  }
}
