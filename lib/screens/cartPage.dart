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
  List<Cart> _cartItems = new List<Cart>();
  List<String> _foodIds = new List<String>();
  Map<String, int> _count = new Map<String, int>();

  @override
  void initState() {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    getUserDetails(authNotifier);
    getCart(authNotifier.userDetails.uuid);
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
      body: (authNotifier.userDetails.uuid == Null || _foodIds.isEmpty) ? Container(
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
            stream: Firestore.instance.collection('items').where(FieldPath.documentId, whereIn: _foodIds).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData && snapshot.data.documents.length > 0 ) {
                _cartItems = new List<Cart>();
                snapshot.data.documents.forEach((item) {
                  _cartItems.add(Cart(item.documentID, _count[item.documentID], item.data['item_name'], item.data['total_qty'], item.data['price']));
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
                          (_cartItems[i].count <= 1) ? 
                          IconButton(
                            onPressed: () async{
                              await editCartItem(_cartItems[i].itemId, (_cartItems[i].count-1), context);
                              setState(() {
                                getCart(authNotifier.userDetails.uuid);
                              });
                            },
                            icon: new Icon(Icons.delete),
                          )
                          : IconButton(
                            onPressed: () async{
                              await editCartItem(_cartItems[i].itemId, (_cartItems[i].count-1), context);
                              setState(() {
                                getCart(authNotifier.userDetails.uuid);
                              });
                            },
                            icon: new Icon(Icons.remove),
                          ),
                          Text(
                            '${_cartItems[i].count}',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          IconButton(
                            icon: new Icon(Icons.add),
                            onPressed: () async{
                              await editCartItem(_cartItems[i].itemId, (_cartItems[i].count+1), context);
                              setState(() {
                                getCart(authNotifier.userDetails.uuid);
                              });
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
          ),
        ],
      ),
    );
  }

  void getCart(uid) async {
    QuerySnapshot snapshot = await Firestore.instance.collection('carts').document(uid).collection('items').getDocuments();
    _foodIds = new List<String>();
    _count = new Map<String, int>();
    snapshot.documents.forEach((item) {
      _foodIds.add(item.documentID);
      _count[item.documentID] = item.data['count'];
    });
    setState(() { });
  }

  // void getData(uid) async {
  //   QuerySnapshot snapshot = await Firestore.instance.collection('carts').document(uid).collection('items').getDocuments();
  //   List<String> foodIds = new List<String>();
  //   // _count = new Map<String, int>();
  //   snapshot.documents.forEach((item) {
  //     foodIds.add(item.documentID);
  //     // _count[item.documentID] = item.data['count'];
  //   });
  //   StreamBuilder(builder: null) snapshot = await Firestore.instance.collection('items').where(FieldPath.documentId, whereIn: _foodIds).snapshots();
    
  // }

}