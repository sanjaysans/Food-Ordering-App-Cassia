import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cassia'),
      ),
      body: 
      SingleChildScrollView(
        physics: ScrollPhysics(),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 10.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _foodItems.length,
                  itemBuilder: (context, int index) {
                  final item = _foodItems[index];
                  return ListTile(
                    title: Text(item.name ?? ''),
                    subtitle: Text('cost: ${item.price.toString()}'),
                    trailing: new Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        item.count !=0 ? new  IconButton(icon: new Icon(Icons.remove),onPressed: ()=>setState(()=> item.count--),):new Container(),
                          new Text(item.count.toString()),
                          new IconButton(icon: new Icon(Icons.add),onPressed: ()=>setState(()=>item.count++))
                      ],
                    ),
                    onTap: () {
                    },
                  );
                }),
              ),
            ],
          ),
      ),
    );
  }
}

class FoodItem {
  final String name;
  final double price;
  final int quantity;
  int count = 0;

  FoodItem(this.name, this.price, this.quantity);
}

List<FoodItem> _foodItems = <FoodItem>[
  FoodItem("Idly", 8.0, 10),
  FoodItem("Dosa", 15.0, 10),
  FoodItem("Ghee Roast", 18.0, 10),
  FoodItem("Pongal", 15.0, 10),
  FoodItem("Vada", 10.0, 10),
  FoodItem("Poori", 8.0, 10),
  FoodItem("Chappathi", 8.0, 10),
  FoodItem("Gulab Jamun", 8.0, 10),
  FoodItem("Gopi Manchurian", 15.0, 10),
  FoodItem("Mini Meals", 25.0, 10),
  FoodItem("Meals", 38.0, 10),
];