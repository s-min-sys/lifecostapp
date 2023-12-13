import 'package:flutter/material.dart';
import 'package:lifecostapp/components/global.dart';
import 'package:lifecostapp/components/model.dart';
import 'package:lifecostapp/helper/alert.dart';
import 'package:lifecostapp/helper/dioutils.dart';
import 'package:lifecostapp/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int mode = 1; // 1: login; 2: register;
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  void doGetBaseInfos() {
    DioUtils.requestHttp('/base-infos', method: DioUtils.getMethod,
        onSuccess: (data) {
      Global.baseInfo = BaseInfo.fromJson(data);

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const HomePage(
                    title: '生活消费',
                  )),
          (route) => false);
    }, onError: (error) {
      AlertUtils.alertDialog(context: context, content: error)
          .then((value) => {print(value)});
    });
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((sp) => {
          if (sp.containsKey('token'))
            {DioUtils.reset(sp.getString('token')), doGetBaseInfos()}
        });
    super.initState();
  }

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
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'UserName',
                    hintText: 'Enter valid user name'),
                controller: userNameController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
                controller: passwordController,
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
                  if (mode == 1) {
                    DioUtils.requestHttp('/login',
                        method: DioUtils.postMethod,
                        data: {
                          'userName': userNameController.text,
                          'password': passwordController.text
                        }, onSuccess: (data) {
                      SharedPreferences.getInstance()
                          .then((sp) => {sp.setString('token', data['token'])});
                      DioUtils.reset(data['token']);
                      doGetBaseInfos();
                    }, onError: (error) {
                      AlertUtils.alertDialog(context: context, content: error)
                          .then((value) => {print(value)});
                    });
                  } else {}
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
