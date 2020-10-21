import 'package:canteen_food_ordering_app/models/food.dart';
import 'package:canteen_food_ordering_app/models/user.dart';
import 'package:canteen_food_ordering_app/notifiers/authNotifier.dart';
import 'package:canteen_food_ordering_app/screens/adminHome.dart';
import 'package:canteen_food_ordering_app/screens/login.dart';
import 'package:canteen_food_ordering_app/screens/navigationBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

ProgressDialog pr;

void toast(String data){
  Fluttertoast.showToast(
    msg: data,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.grey,
    textColor: Colors.white
  );
}

login(User user, AuthNotifier authNotifier, BuildContext context) async {
  pr = new ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
  pr.show();
  AuthResult authResult;
  try {
    authResult = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: user.email, password: user.password);
  } catch (error) {
    pr.hide().then((isHidden) {
      print(isHidden);
    });
    toast(error.message.toString());
    print(error);
    return;
  }

  try {
    if (authResult != null) {
      FirebaseUser firebaseUser = authResult.user;
      if (!firebaseUser.isEmailVerified) {
        await FirebaseAuth.instance.signOut();
        pr.hide().then((isHidden) {
          print(isHidden);
        });
        toast("Email ID not verified");
        return;
      }
      else if (firebaseUser != null) {
        print("Log In: $firebaseUser");
        authNotifier.setUser(firebaseUser);
        await getUserDetails(authNotifier);
        print("done");
        pr.hide().then((isHidden) {
          print(isHidden);
        });
        if(authNotifier.userDetails.role == 'admin'){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (BuildContext context) {
              return AdminHomePage();
            }),
          );
        }else{
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (BuildContext context) {
              return NavigationBarPage(selectedIndex: 1);
            }),
          );
        }
      }
    }
  } catch (error) {
    pr.hide().then((isHidden) {
      print(isHidden);
    });
    toast(error.message.toString());
    print(error);
    return;
  }
  
}

signUp(User user, AuthNotifier authNotifier, BuildContext context) async {
  pr = new ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
  pr.show();
  bool userDataUploaded = false;
  AuthResult authResult;
  try{
    authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: user.email.trim(), password: user.password
    );
  } catch(error){
    pr.hide().then((isHidden) {
      print(isHidden);
    });
    toast(error.message.toString());
    print(error);
    return;
  }

  try {
    if (authResult != null) {
      UserUpdateInfo updateInfo = UserUpdateInfo();
      updateInfo.displayName = user.displayName;

      FirebaseUser firebaseUser = authResult.user;
      await firebaseUser.sendEmailVerification();

      if (firebaseUser != null) {
        await firebaseUser.updateProfile(updateInfo);
        await firebaseUser.reload();
        print("Sign Up: $firebaseUser");
        uploadUserData(user, userDataUploaded);
        await FirebaseAuth.instance.signOut();
        authNotifier.setUser(null);
        pr.hide().then((isHidden) {
          print(isHidden);
        });
        toast("Verification link is sent to ${user.email}");
        Navigator.pop(context);
      }
    }
    pr.hide().then((isHidden) {
      print(isHidden);
    });
  } catch (error) {
    pr.hide().then((isHidden) {
      print(isHidden);
    });
    toast(error.message.toString());
    print(error);
    return;
  }
  
}

getUserDetails(AuthNotifier authNotifier) async {
  await Firestore.instance
      .collection('users')
      .document(authNotifier.user.uid)
      .get()
      .catchError((e) => print(e))
      .then((value) => {
        (value != null) ? 
          authNotifier.setUserDetails(User.fromMap(value.data)):
          print(value)                    
      });
}

uploadUserData(User user, bool userdataUpload) async {
  bool userDataUploadVar = userdataUpload;
  FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();

  CollectionReference userRef = Firestore.instance.collection('users');
  CollectionReference cartRef = Firestore.instance.collection('carts');
  
  user.uuid = currentUser.uid;
  if (userDataUploadVar != true) {
    await userRef
        .document(currentUser.uid)
        .setData(user.toMap())
        .catchError((e) => print(e))
        .then((value) => userDataUploadVar = true);
    await cartRef
        .document(currentUser.uid)
        .setData({})
        .catchError((e) => print(e))
        .then((value) => userDataUploadVar = true);
  } else {
    print('already uploaded user data');
  }
  print('user data uploaded successfully');
}

initializeCurrentUser(AuthNotifier authNotifier, BuildContext context) async {
  FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
  if (firebaseUser != null) {
    authNotifier.setUser(firebaseUser);
    await getUserDetails(authNotifier);
  }
}

signOut(AuthNotifier authNotifier, BuildContext context) async {
  await FirebaseAuth.instance.signOut();

  authNotifier.setUser(null);
  print('log out');
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (BuildContext context) {
      return LoginPage();
    }),
  );
}

forgotPassword(User user, AuthNotifier authNotifier, BuildContext context) async {
  pr = new ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
  pr.show();
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email);
  } catch (error) {
    pr.hide().then((isHidden) {
      print(isHidden);
    });
    toast(error.message.toString());
    print(error);
    return;
  }
  pr.hide().then((isHidden) {
    print(isHidden);
  });
  toast("Reset Email has sent successfully");
  Navigator.pop(context);
}

addToCart(Food food, BuildContext context) async {
  pr = new ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
  pr.show();
  try {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    CollectionReference cartRef = Firestore.instance.collection('carts');
    QuerySnapshot data = await cartRef.document(currentUser.uid).collection('items').getDocuments();
    if(data.documents.length >= 10) {
      pr.hide().then((isHidden) {
        print(isHidden);
      });
      toast("Cart cannot have more than 10 times!");
      return;
    }
    await cartRef
      .document(currentUser.uid).collection('items').document(food.id).setData({"count": 1})
      .catchError((e) => print(e))
      .then((value) => print("Success"));
  } catch (error) {
    pr.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Failed to add to cart!");
    print(error);
    return;
  }
  pr.hide().then((isHidden) {
    print(isHidden);
  });
  toast("Added to cart successfully!");
}

removeFromCart(Food food, BuildContext context) async {
  pr = new ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
  pr.show();
  try {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    CollectionReference cartRef = Firestore.instance.collection('carts');
    await cartRef
      .document(currentUser.uid).collection('items').document(food.id).delete()
      .catchError((e) => print(e))
      .then((value) => print("Success"));
  } catch (error) {
    pr.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Failed to Remove from cart!");
    print(error);
    return;
  }
  pr.hide().then((isHidden) {
    print(isHidden);
  });
  toast("Removed from cart successfully!");
}

addNewItem(String itemName, int price, int totalQty, BuildContext context) async {
  pr = new ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
  pr.show();
  try {
    CollectionReference itemRef = Firestore.instance.collection('items');
    await itemRef
      .document().setData({"item_name": itemName, "price": price, "total_qty": totalQty})
      .catchError((e) => print(e))
      .then((value) => print("Success"));
  } catch (error) {
    pr.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Failed to add to new item!");
    print(error);
    return;
  }
  pr.hide().then((isHidden) {
    print(isHidden);
  });
  Navigator.pop(context);
  toast("New Item added successfully!");
}

editItem(String itemName, int price, int totalQty, BuildContext context, String id) async {
  pr = new ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
  pr.show();
  try {
    CollectionReference itemRef = Firestore.instance.collection('items');
    await itemRef
      .document(id).setData({"item_name": itemName, "price": price, "total_qty": totalQty})
      .catchError((e) => print(e))
      .then((value) => print("Success"));
  } catch (error) {
    pr.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Failed to edit item!");
    print(error);
    return;
  }
  pr.hide().then((isHidden) {
    print(isHidden);
  });
  Navigator.pop(context);
  toast("Item edited successfully!");
}

deleteItem(String id, BuildContext context) async {
  pr = new ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
  pr.show();
  try {
    CollectionReference itemRef = Firestore.instance.collection('items');
    await itemRef
      .document(id).delete()
      .catchError((e) => print(e))
      .then((value) => print("Success"));
  } catch (error) {
    pr.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Failed to edit item!");
    print(error);
    return;
  }
  pr.hide().then((isHidden) {
    print(isHidden);
  });
  Navigator.pop(context);
  toast("Item edited successfully!");
}

editCartItem(String itemId, int count, BuildContext context) async {
  pr = new ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
  pr.show();
  try {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    CollectionReference cartRef = Firestore.instance.collection('carts');
    if(count <= 0){
      await cartRef
      .document(currentUser.uid).collection('items').document(itemId).delete()
      .catchError((e) => print(e))
      .then((value) => print("Success"));
    }else{
      await cartRef
        .document(currentUser.uid).collection('items').document(itemId).updateData({"count": count})
        .catchError((e) => print(e))
        .then((value) => print("Success"));
    }
  } catch (error) {
    pr.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Failed to update Cart!");
    print(error);
    return;
  }
  pr.hide().then((isHidden) {
    print(isHidden);
  });
  toast("Cart updated successfully!");
}

addMoney(int amount, BuildContext context, String id) async {
  pr = new ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
  pr.show();
  try {
    CollectionReference userRef = Firestore.instance.collection('users');
    await userRef
      .document(id).updateData({'balance': FieldValue.increment(amount)})
      .catchError((e) => print(e))
      .then((value) => print("Success"));
  } catch (error) {
    pr.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Failed to add money!");
    print(error);
    return;
  }
  pr.hide().then((isHidden) {
    print(isHidden);
  });
  Navigator.pop(context);
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (BuildContext context) {
      return NavigationBarPage(selectedIndex: 1);
    }),
  );
  toast("Money added successfully!");
}

placeOrder(BuildContext context, double total) async {
  pr = new ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
  pr.show();
  try {
    // Initiaization
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    CollectionReference cartRef = Firestore.instance.collection('carts');
    CollectionReference orderRef = Firestore.instance.collection('orders');
    CollectionReference itemRef = Firestore.instance.collection('items');
    CollectionReference userRef = Firestore.instance.collection('users');

    List<String> foodIds = new List<String>();
    Map<String, int> count = new Map<String, int>();
    List<dynamic> _cartItems = new List<dynamic>();

    // Checking user balance
    DocumentSnapshot userData = await userRef.document(currentUser.uid).get();
    if(userData.data['balance'] < total){
      pr.hide().then((isHidden) {
        print(isHidden);
      });
      toast("You dont have succifient balance to place this order!");
      return;
    }

    // Getting all cart items of the user
    QuerySnapshot data = await cartRef.document(currentUser.uid).collection('items').getDocuments();
    data.documents.forEach((item) {
      foodIds.add(item.documentID);
      count[item.documentID] = item.data['count'];
    });

    // Checking for item availability
    QuerySnapshot snap = await itemRef.where(FieldPath.documentId, whereIn: foodIds).getDocuments();
    for (var i = 0; i < snap.documents.length; i++) {
      if(snap.documents[i].data['total_qty'] < count[snap.documents[i].documentID]){
        pr.hide().then((isHidden) {
          print(isHidden);
        });
        print("not");
        toast("Item: ${snap.documents[i].data['item_name']} has QTY: ${snap.documents[i].data['total_qty']} only. Reduce/Remove the item.");
        return;
      }
    }

    // Creating cart items array
    snap.documents.forEach((item) {
      _cartItems.add({
        "item_id": item.documentID,
        "count": count[item.documentID],
        "item_name": item.data['item_name'],
        "price": item.data['price']
      });
    });
    
    // Creating a transaction
    await Firestore.instance.runTransaction((Transaction transaction) async {

        // Update the item count in items table
        for (var i = 0; i < snap.documents.length; i++) {
          await transaction.update(snap.documents[i].reference, {"total_qty": snap.documents[i].data["total_qty"] - count[snap.documents[i].documentID]});
        }

        // Deduct amount from user
        await userRef.document(currentUser.uid).updateData({'balance': FieldValue.increment(-1*total)});

        // Place a new order
        await orderRef
          .document()
          .setData({
            "items": _cartItems, 
            "is_delivered": false, 
            "total": total, 
            "placed_at": DateTime.now(), 
            "placed_by": currentUser.uid
          });
        
        // Empty cart
        for (var i = 0; i < data.documents.length; i++) {
          await transaction.delete(data.documents[i].reference);
        }
        print("in in");
        // return;
    });
    
    // Successfull transaction
    pr.hide().then((isHidden) {
      print(isHidden);
    });
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return NavigationBarPage(selectedIndex: 1);
      }),
    );
    toast("Order Placed Successfully!");
  } catch (error) {
    pr.hide().then((isHidden) {
      print(isHidden);
    });
    Navigator.pop(context);
    toast("Failed to place order!");
    print(error);
    return;
  }
}

orderReceived(String id, BuildContext context) async {
  pr = new ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
  pr.show();
  try {
    CollectionReference ordersRef = Firestore.instance.collection('orders');
    await ordersRef
      .document(id).updateData({'is_delivered': true})
      .catchError((e) => print(e))
      .then((value) => print("Success"));
  } catch (error) {
    pr.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Failed to mark as received!");
    print(error);
    return;
  }
  pr.hide().then((isHidden) {
    print(isHidden);
  });
  Navigator.pop(context);
  toast("Order received successfully!");
}
