import 'package:flutter/material.dart';
import 'package:lifecostapp/helper/alert.dart';
import 'package:lifecostapp/helper/netutils.dart';
import 'package:toastification/toastification.dart';

class WalletAddPage extends StatefulWidget {
  const WalletAddPage({super.key});

  @override
  State<WalletAddPage> createState() => _WalletAddPageState();
}

class _WalletAddPageState extends State<WalletAddPage> {
  final personWalletNameController = TextEditingController();
  final earnWalletNameController = TextEditingController();
  final consumeWalletNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('增加钱包(机构)'),
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          Padding(
            //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '个人的钱包名字',
                  hintText: '输入一个合法的钱包名字: 例如 支付宝/微信 等'),
              controller: personWalletNameController,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                personWalletNew();
              },
              child: const Text('生成新的个人钱包')),
          const Divider(),
          Padding(
            //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '进账的方式/机构名字',
                  hintText: '输入一个合法的进账方式名字: 例如 理财/路上拾遗/继承遗产 等'),
              controller: earnWalletNameController,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                earnConsumeWalletNew(3);
              },
              child: const Text('生成新的进账方式')),
          const Divider(),
          Padding(
            //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '消费的方式/机构名字',
                  hintText: '输入一个消费的方式/机构名字: 例如 胜利商场A柜台/奶茶店/丢钱 等'),
              controller: consumeWalletNameController,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                earnConsumeWalletNew(2);
              },
              child: const Text('生成新的消费方式')),
        ])));
  }

  void personWalletNew() {
    var name = personWalletNameController.text;

    if (name == "") {
      AlertUtils.alertDialog(context: context, content: '请输入名字');
    }

    NetUtils.requestHttp('/manager/wallet/new',
        method: NetUtils.postMethod,
        data: {
          'name': name,
        }, onResult: (code, msg, data) {
      if (code == 2) {
        AlertUtils.alertDialog(context: context, content: '钱包名字已经存在');

        return;
      }

      if (code != 0) {
        AlertUtils.alertDialog(context: context, content: msg);

        return;
      }

      personWalletNameController.text = '';
      toastification.show(
        context: context,
        title: '添加个人钱包 $name 成功',
        autoCloseDuration: const Duration(seconds: 5),
      );
    }, onError: (error) {
      AlertUtils.alertDialog(context: context, content: error);
    });
  }

  void earnConsumeWalletNew(int dir) {
    var name = earnWalletNameController.text;
    if (dir == 2) {
      name = consumeWalletNameController.text;
    }

    if (name == "") {
      AlertUtils.alertDialog(context: context, content: '请输入名字');
    }

    NetUtils.requestHttp('manager/wallet/new-by-dir',
        method: NetUtils.postMethod,
        data: {
          'newWalletName': name,
          'dir': dir,
        }, onResult: (code, msg, data) {
      if (code == 2) {
        AlertUtils.alertDialog(context: context, content: '钱包名字已经存在');

        return;
      }

      if (code != 0) {
        AlertUtils.alertDialog(context: context, content: msg);

        return;
      }

      if (dir == 3) {
        toastification.show(
          context: context,
          title: '添加进账机构 $name 成功',
          autoCloseDuration: const Duration(seconds: 5),
        );

        earnWalletNameController.text = '';
      } else if (dir == 2) {
        consumeWalletNameController.text = '';
        toastification.show(
          context: context,
          title: '添加消费机构 $name 成功',
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    }, onError: (error) {
      AlertUtils.alertDialog(context: context, content: error);
    });
  }
}
