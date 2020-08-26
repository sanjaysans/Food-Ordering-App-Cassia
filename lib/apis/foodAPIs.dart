import 'package:canteen_food_ordering_app/models/user.dart';
import 'package:canteen_food_ordering_app/notifiers/authNotifier.dart';
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
        pr.hide().then((isHidden) {
          print(isHidden);
        });
        toast("Email ID not verified");
        return;
      }
      if (firebaseUser != null) {
        print("Log In: $firebaseUser");
        authNotifier.setUser(firebaseUser);
        await getUserDetails(authNotifier);
        print("done");
        pr.hide().then((isHidden) {
          print(isHidden);
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) {
            return NavigationBarPage(selectedIndex: 1);
          }),
        );
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) {
            return LoginPage();
          }),
        );
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
  user.uuid = currentUser.uid;
  if (userDataUploadVar != true) {
    await userRef
        .document(currentUser.uid)
        .setData(user.toMap())
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
