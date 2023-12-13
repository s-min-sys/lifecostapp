import 'package:flutter/material.dart';
import 'package:lifecostapp/pages/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int mode = 1; // 1: login; 2: register;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(mode == 1 ? 'Login' : 'Register'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: SizedBox(
                    width: 200,
                    height: 150,
                    child: Image.asset('asset/images/logo.png')),
              ),
            ),
            const Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'UserName',
                    hintText: 'Enter valid user name'),
              ),
            ),
            const Padding(
              padding:
                  EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                onPressed: () {
                  if (mode == 1) {
                    setState(() {
                      mode = 2;
                    });
                  } else {
                    setState(() {
                      mode = 1;
                    });
                  }
                },
                child: Text(
                  mode == 1 ? 'Not Account' : 'Has Account',
                  style: const TextStyle(color: Colors.blue, fontSize: 15),
                ),
              ),
              TextButton(
                onPressed: () {
                  //
                },
                child: const Text(
                  'Forgot Password',
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                ),
              ),
            ]),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HomePage(
                                title: '生活消费',
                              )));
                },
                child: Text(
                  mode == 1 ? 'Login' : 'register',
                  style: const TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            const SizedBox(
              height: 130,
            ),
            const Text('New User? Create Account')
          ],
        ),
      ),
    );
  }
}
