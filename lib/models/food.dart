class Food {
  String itemName;
  int totalQty;
  int price;
  String id;

  Food(this.id, this.itemName, this.totalQty, this.price);

  // Food.fromMap(Map<String, dynamic> data) {
  //   displayName = data['displayName'];
  //   email = data['email'];
  //   password = data['password'];
  //   uuid = data['uuid'];
  //   role = data['role'];
  //   balance = data['balance'];
  // }

  Map<String, dynamic> toMapForCart() {
    Map<String, dynamic> map = {};
    map['item_id'] = id;
    map['count'] = 1;
    return map;
  }
}
