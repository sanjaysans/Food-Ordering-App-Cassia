class OrderItem {
  String itemName;
  int price;
  String id;
  int count;

  OrderItem(this.id, this.itemName, this.count, this.price);
  
}

class Order{
  String orderId;
  String orderDate;
  double totalAmount;
  bool status;
  List<OrderItem> items;

  Order(this.items, this.orderDate, this.orderId, this.status, this.totalAmount);

}
