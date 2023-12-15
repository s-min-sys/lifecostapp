import 'package:flutter/material.dart';
import 'package:lifecostapp/components/global.dart';
import 'package:lifecostapp/components/model.dart';
import 'package:lifecostapp/helper/alert.dart';
import 'package:lifecostapp/helper/netutils.dart';
import 'package:lifecostapp/pages/home.dart';
import 'package:lifecostapp/pages/login.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final groupNameController = TextEditingController();
  final groupEnterCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('组'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '组名字',
                  hintText: '输入一个合法的组名字'),
              controller: groupNameController,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                doCreateGroup();
              },
              child: const Text('创建组')),
          const Divider(),
          Padding(
            //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '进组码',
                  hintText: '输入进组邀请码'),
              controller: groupEnterCodeController,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                doJoinGroup();
              },
              child: const Text('加入组')),
          const SizedBox(
            height: 200,
          ),
          const Divider(),
          ElevatedButton(
              onPressed: () {
                doLogout();
              },
              child: const Text('退出')),
        ]),
      ),
    );
  }

  void doCreateGroup() {
    String groupName = groupNameController.text;
    if (groupName == '') {
      AlertUtils.alertDialog(context: context, content: '请输入组名字');

      return;
    }

    NetUtils.requestHttp('/manager/group/new',
        method: NetUtils.postMethod,
        data: {
          'name': groupNameController.text,
        }, onResult: (code, msg, data) {
      if (code == 1) {
        AlertUtils.alertDialog(context: context, content: '组名字已经存在');

        return;
      }

      if (code != 0) {
        AlertUtils.alertDialog(context: context, content: msg);

        return;
      }

      doGetBaseInfos();
    }, onError: (error) {
      AlertUtils.alertDialog(context: context, content: error);
    });
  }

  void doJoinGroup() {
    String groupName = groupEnterCodeController.text;
    if (groupName == '') {
      AlertUtils.alertDialog(context: context, content: '请输入进组邀请码');

      return;
    }

    NetUtils.requestHttp('/manager/group/join/$groupName',
        method: NetUtils.postMethod, data: {}, onResult: (code, msg, data) {
      if (code != 0) {
        AlertUtils.alertDialog(context: context, content: msg);

        return;
      }

      doGetBaseInfos();
    }, onError: (error) {
      AlertUtils.alertDialog(context: context, content: error);
    });
  }

  void doGetBaseInfos() {
    NetUtils.requestHttp('/base-infos', method: NetUtils.getMethod,
        onSuccess: (data) {
      Global.baseInfo = BaseInfo.fromJson(data);

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const HomePage(
                    title: '生活消费',
                  )),
          (route) => false);
    }, onError: (error) {
      AlertUtils.alertDialog(context: context, content: error);
    });
  }

  void doLogout() {
    NetUtils.requestHttp('/logout', method: NetUtils.postMethod, data: {},
        onSuccess: (data) {
      AlertUtils.alertDialog(context: context, content: '成功退出');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false);
    }, onError: (error) {
      AlertUtils.alertDialog(context: context, content: error);
    });
  }
}
