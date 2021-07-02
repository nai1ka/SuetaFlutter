import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/ui/main/main_widget.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
TextEditingController emailController = new TextEditingController();
TextEditingController passwordController = new TextEditingController();

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
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
              children: [
                Container(
                  padding: EdgeInsets.only(right: 20),
                  child: AutoSizeText(
                    "Войдите в свой аккаунт",
                    style: TextStyle(
                        fontSize: 30,
                        color: Color(0xFF2A41CB),
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 20)),
                emailField(),
                Padding(padding: EdgeInsets.only(bottom: 10)),
                passwordField(),
                Spacer(),
                Container(
                  width: double.infinity,
                  height: 70,
                  padding: EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      signInWithEmailAndPassword(context);
                    },
                    child: Text("Войти"),
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

void signInWithEmailAndPassword(BuildContext context) async {
  var user = (await auth.signInWithEmailAndPassword(
    email: emailController.text,
    password: passwordController.text,
  ))
      .user;

  if (user != null) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
        (Route<dynamic> route) => false);
  } else {
    //TODO Update UI
  }
}
