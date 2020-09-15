import 'package:canteen_food_ordering_app/apis/foodAPIs.dart';
import 'package:canteen_food_ordering_app/notifiers/authNotifier.dart';
import 'package:canteen_food_ordering_app/widgets/customRaisedButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:canteen_food_ordering_app/models/food.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyEdit = GlobalKey<FormState>();
  List<Food> _foodItems = new List<Food>();
  String name = '';

  signOutUser() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    if (authNotifier.user != null) {
      signOut(authNotifier, context);
    }
  }

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
        title: Text('Cassia'),
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
      // ignore: unrelated_type_equality_checks
      body: (authNotifier.userDetails == null) ? Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        width: MediaQuery.of(context).size.width * 0.6,
        child: Text("No Items to display"),
      ) : (authNotifier.userDetails.role == 'admin') ? adminHome(context) : Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        width: MediaQuery.of(context).size.width * 0.6,
        child: Text("No Items to display"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return popupForm(context);
            }
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromRGBO(255, 63, 111, 1),
      ),
    );
  }

  Widget adminHome(context){
    // AuthNotifier authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    return SingleChildScrollView(
        physics: ScrollPhysics(),
          child: Column(
            children: <Widget>[
              Card(
                child: TextField(
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search), hintText: 'Search...'),
                  onChanged: (val) {
                    setState(() {
                      name = val;
                    });
                  },
                ),
              ),
              StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('items').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData && snapshot.data.documents.length > 0) {
                  _foodItems = new List<Food>();
                  snapshot.data.documents.forEach((item) {
                    _foodItems.add(Food(item.documentID, item['item_name'], item['total_qty'], item['price']));
                  });
                  List<Food> _suggestionList = (name == '' || name == null) ? _foodItems
                    : _foodItems.where((element) => element.itemName.toLowerCase().contains(name.toLowerCase())).toList();
                  if(_suggestionList.length > 0){
                    return Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child:ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _suggestionList.length,
                      itemBuilder: (context, int i) {
                      return ListTile(
                        title: Text(_suggestionList[i].itemName ?? ''),
                        subtitle: Text('cost: ${_suggestionList[i].price.toString()}'),
                        trailing: Text('Total Quantity: ${_suggestionList[i].totalQty.toString()}'),
                        onLongPress: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return popupDeleteOrEmpty(context, _suggestionList[i]);
                            }
                          );
                        },
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return popupEditForm(context, _suggestionList[i]);
                            }
                          );
                        },
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

  Widget popupForm(context){
    String itemName;
    int totalQty, price;
    return AlertDialog(
      content: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Form(
            key: _formKey,
            autovalidate: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("New Food Item", style: TextStyle(
                    color: Color.fromRGBO(255, 63, 111, 1),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (String value) {
                      if(value.length < 3) return "Not a valid name";
                      else return null;
                    },
                    keyboardType: TextInputType.text,
                    onSaved: (String value) {
                      itemName = value;
                    },
                    cursorColor: Color.fromRGBO(255, 63, 111, 1),
                    decoration: InputDecoration(
                      hintText: 'Food Name',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                      icon: Icon(
                        Icons.fastfood,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (String value) {
                      if(value.length > 3) return "Not a valid price";
                      else if(int.tryParse(value) == null) return "Not a valid integer";
                      else return null;
                    },
                    keyboardType: TextInputType.numberWithOptions(),
                    onSaved: (String value) {
                      price = int.parse(value);
                    },
                    cursorColor: Color.fromRGBO(255, 63, 111, 1),
                    decoration: InputDecoration(
                      hintText: 'Price in INR',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                      icon: Icon(
                        Icons.attach_money,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (String value) {
                      if(value.length > 4) return "QTY cannot be above 4 digits";
                      else if(int.tryParse(value) == null) return "Not a valid integer";
                      else return null;
                    },
                    keyboardType: TextInputType.numberWithOptions(),
                    onSaved: (String value) {
                      totalQty = int.parse(value);
                    },
                    cursorColor: Color.fromRGBO(255, 63, 111, 1),
                    decoration: InputDecoration(
                      hintText: 'Total QTY',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                      icon: Icon(
                        Icons.add_shopping_cart,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        addNewItem(itemName, price, totalQty, context);
                      }
                    },
                    child: CustomRaisedButton(buttonText: 'Add Item'),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget popupEditForm(context, Food data){
    String itemName = data.itemName;
    int totalQty = data.totalQty, price = data.price;
    return AlertDialog(
      content: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Form(
            key: _formKeyEdit,
            autovalidate: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Edit Food Item", style: TextStyle(
                    color: Color.fromRGBO(255, 63, 111, 1),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: itemName,
                    validator: (String value) {
                      if(value.length < 3) return "Not a valid name";
                      else return null;
                    },
                    keyboardType: TextInputType.text,
                    onSaved: (String value) {
                      itemName = value;
                    },
                    cursorColor: Color.fromRGBO(255, 63, 111, 1),
                    decoration: InputDecoration(
                      hintText: 'Food Name',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                      icon: Icon(
                        Icons.fastfood,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: price.toString(),
                    validator: (String value) {
                      if(value.length > 3) return "Not a valid price";
                      else if(int.tryParse(value) == null) return "Not a valid integer";
                      else return null;
                    },
                    keyboardType: TextInputType.numberWithOptions(),
                    onSaved: (String value) {
                      price = int.parse(value);
                    },
                    cursorColor: Color.fromRGBO(255, 63, 111, 1),
                    decoration: InputDecoration(
                      hintText: 'Price in INR',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                      icon: Icon(
                        Icons.attach_money,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: totalQty.toString(),
                    validator: (String value) {
                      if(value.length > 4) return "QTY cannot be above 4 digits";
                      else if(int.tryParse(value) == null) return "Not a valid integer";
                      else return null;
                    },
                    keyboardType: TextInputType.numberWithOptions(),
                    onSaved: (String value) {
                      totalQty = int.parse(value);
                    },
                    cursorColor: Color.fromRGBO(255, 63, 111, 1),
                    decoration: InputDecoration(
                      hintText: 'Total QTY',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                      icon: Icon(
                        Icons.add_shopping_cart,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      if (_formKeyEdit.currentState.validate()) {
                        _formKeyEdit.currentState.save();
                        editItem(itemName, price, totalQty, context, data.id);
                      }
                    },
                    child: CustomRaisedButton(buttonText: 'Edit Item'),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget popupDeleteOrEmpty(context, Food data){
    return AlertDialog(
      content: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    deleteItem(data.id, context);
                  },
                  child: CustomRaisedButton(buttonText: 'Delete Item'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    editItem(data.itemName, data.price, 0, context, data.id);
                  },
                  child: CustomRaisedButton(buttonText: 'Empty Item'),
                ),
              ),
            ],
          ),
        ],
      )
    );
  }

}
