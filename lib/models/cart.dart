class Cart {
  int count;
  String itemId;
  String itemName;
  int totalQty;
  int price;

  Cart(this.itemId, this.count, this.itemName, this.totalQty, this.price);

  // Food.fromMap(Map<String, dynamic> data) {
  //   displayName = data['displayName'];
  //   email = data['email'];
  //   password = data['password'];
  //   uuid = data['uuid'];
  //   role = data['role'];
  //   balance = data['balance'];
  // }

  // Map<String, dynamic> toMapForCart() {
  //   Map<String, dynamic> map = {};
  //   map['id'] = id;
  //   map['count'] = 1;
  //   return map;
  // }
}
