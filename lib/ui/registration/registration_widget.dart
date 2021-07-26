import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/models/User.dart' as UserClass;
import 'package:test_flutter/ui/login/login_widget.dart';
import 'package:test_flutter/ui/main/main_widget.dart';

TextEditingController nameController = new TextEditingController();
TextEditingController emailController = new TextEditingController();
TextEditingController passwordController = new TextEditingController();
final FirebaseAuth auth = FirebaseAuth.instance;

class RegistrationWidget extends StatelessWidget {
  const RegistrationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(right: 20),
                  child: AutoSizeText(
                    "Создайте новый аккаунт",
                    style: TextStyle(
                        fontSize: 30,
                        color: Color(0xFF2A41CB),
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 20)),
                nameField(),
                Padding(padding: EdgeInsets.only(bottom: 10)),
                emailField(),
                Padding(padding: EdgeInsets.only(bottom: 10)),
                passwordField(),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginWidget()));
                    },
                    child: Text("У меня уже есть аккаунт")),
                Spacer(),
                Container(
                  width: double.infinity,
                  height: 70,
                  padding: EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      var newUser =
                          UserClass.User(nameController.text, 1, "Казань")
                            ..email = emailController.text;
                      register(newUser, passwordController.text, context);
                      /*newUser.saveToFirebase(
                        context,
                        FirebaseFirestore.instance
                            .collection('core')
                            .doc("users").collection("users"));*/
                    },
                    child: Text("Зарегистироваться"),
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ))),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget nameField() {
  return new TextFormField(
    controller: nameController,
    decoration: new InputDecoration(
      labelText: "Введите имя",
      fillColor: Color(0xFF6C1F1F),
      focusedBorder: OutlineInputBorder(),
      border: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(10.0),
        borderSide: new BorderSide(),
      ),
      //fillColor: Colors.green
    ),
    validator: (val) {
      if (val!.length == 0) {
        return "Имя не может быть пустым";
      } else {
        return null;
      }
    },
    keyboardType: TextInputType.name,
    style: new TextStyle(
      fontFamily: "Poppins",
    ),
  );
}

Widget emailField() {
  return new TextFormField(
    controller: emailController,
    decoration: new InputDecoration(
      labelText: "Введите электронный адрес",
      fillColor: Color(0xFF6C1F1F),
      focusedBorder: OutlineInputBorder(),
      border: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(10.0),
        borderSide: new BorderSide(),
      ),
      //fillColor: Colors.green
    ),
    validator: (val) {
      if (val!.length == 0) {
        return "Адрес не может быть пустым";
      } else {
        return null;
      }
    },
    keyboardType: TextInputType.emailAddress,
    style: new TextStyle(
      fontFamily: "Poppins",
    ),
  );
}

Widget passwordField() {
  return new TextFormField(
    controller: passwordController,
    obscureText: true,
    decoration: new InputDecoration(
      labelText: "Введите пароль",
      fillColor: Color(0xFF6C1F1F),
      focusedBorder: OutlineInputBorder(),
      border: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(10.0),
        borderSide: new BorderSide(),
      ),
      //fillColor: Colors.green
    ),
    validator: (val) {
      if (val!.length < 6) {
        return "Пароль должен содержать минимум 6 символов";
      } else {
        return null;
      }
    },
    style: new TextStyle(
      fontFamily: "Poppins",
    ),
  );
}

register(UserClass.User newUser, String password, BuildContext context) async {
  var user = (await auth.createUserWithEmailAndPassword(
    email: newUser.email,
    password: password,
  ))
      .user;
  if (user != null) {
    newUser.id = user.uid;
    saveToFirestore(
        newUser,
        FirebaseFirestore.instance
            .collection('core')
            .doc("users")
            .collection("list"),
        context);
  } else {
    //TODO Update state
  }
}

saveToFirestore(UserClass.User user, CollectionReference users,
    BuildContext context) async {
  // Call the user's CollectionReference to add a new user

  /*return Future(() {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Произошла ошибка сохранения пользователя. Проверьте свои данные"),
      ));
    });*/

  Map<String, dynamic> postData = {
    'name': user.name, // John Doe
    'age': user.age,
    'city': user.city,
    "email": user.email,
    'friends': {},
    'friendRequests':[]
  };
  return users
      .doc("${user.id}")
      .set(postData)
      .then((value) => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
          (Route<dynamic> route) => false))
      .catchError((error) => print("Failed to add user: $error"));
}
