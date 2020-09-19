import 'package:canteen_food_ordering_app/apis/foodAPIs.dart';
import 'package:canteen_food_ordering_app/models/cart.dart';
import 'package:canteen_food_ordering_app/notifiers/authNotifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  @override
  void initState() {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    getUserDetails(authNotifier);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      // ignore: unrelated_type_equality_checks
      body: (authNotifier.userDetails.uuid == Null) ? Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        width: MediaQuery.of(context).size.width * 0.6,
        child: Text("No Items to display"),
      ) : cartList(context)
    );
  }

  Widget cartList(context){
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    return SingleChildScrollView(
      physics: ScrollPhysics(),
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('carts').document(authNotifier.userDetails.uuid).collection('items').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot1) {
                if (snapshot1.hasData && snapshot1.data.documents.length > 0 ) {
                  List<String> foodIds = new List<String>();
                  Map<String, int> count = new Map<String, int>();
                  snapshot1.data.documents.forEach((item) {
                    foodIds.add(item.documentID);
                    count[item.documentID] = item.data['count'];
                  });
                  return dataDisplay(context, authNotifier.userDetails.uuid, foodIds, count);
                } else {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text("No Items to display"),
                  );
                }
              } ,
            ),
        ],
      ),
    );
  }

  Widget dataDisplay(BuildContext context, String uid, List<String> foodIds, Map<String, int> count){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('items').where(FieldPath.documentId, whereIn: foodIds).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData && snapshot.data.documents.length > 0 ) {
          List<Cart> _cartItems = new List<Cart>();
          snapshot.data.documents.forEach((item) {
            _cartItems.add(Cart(item.documentID, count[item.documentID], item.data['item_name'], item.data['total_qty'], item.data['price']));
          });
          if (_cartItems.length > 0){
            return Container(
              margin: EdgeInsets.only(top: 10.0),
              child:ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cartItems.length,
                itemBuilder: (context, int i) {
                return ListTile(
                  title: Text(_cartItems[i].itemName ?? ''),
                  subtitle: Text('cost: ${_cartItems[i].price.toString()}'),
                  trailing: Row(      
                    mainAxisSize: MainAxisSize.min,    
                    children: <Widget>[
                    (_cartItems[i].count == null || _cartItems[i].count <= 1) ? 
                    IconButton(
                      onPressed: () async{
                        setState(() {
                          foodIds.remove(_cartItems[i].itemId);
                        });
                        await editCartItem(_cartItems[i].itemId, 0, context);
                      },
                      icon: new Icon(Icons.delete),
                    )
                    : IconButton(
                      onPressed: () async{
                        await editCartItem(_cartItems[i].itemId, (_cartItems[i].count-1), context);
                      },
                      icon: new Icon(Icons.remove),
                    ),
                    Text(
                      '${_cartItems[i].count ?? 0}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    IconButton(
                      icon: new Icon(Icons.add),
                      onPressed: () async{
                        await editCartItem(_cartItems[i].itemId, (_cartItems[i].count+1), context);
                      },
                    )
                  ]),
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
        } else {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            width: MediaQuery.of(context).size.width * 0.6,
            child: Text("No Items to display"),
          );
        }
      },
    );
  }
}