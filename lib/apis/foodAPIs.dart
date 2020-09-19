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

