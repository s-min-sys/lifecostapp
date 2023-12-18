import 'package:flutter/material.dart';
import 'package:lifecostapp/components/global.dart';
import 'package:lifecostapp/components/model.dart';
import 'package:lifecostapp/helper/alert.dart';
import 'package:lifecostapp/helper/netutils.dart';
import 'package:lifecostapp/pages/home.dart';
import 'package:lifecostapp/pages/login.dart';

class Share {
  static void doLogout(BuildContext context) {
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

  static void naviToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => const HomePage(
                  online: true,
                )),
        (route) => false);
  }

  static void naviToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false);
  }

  static bool isNetworkError(String error) {
    return error.startsWith('ClientException');
  }

  static void doFlushBaseInfos(BuildContext context, bool alertWhenError) {
    NetUtils.requestHttp('/base-infos', method: NetUtils.getMethod,
        onSuccess: (data) {
      var baseInfo = BaseInfo.fromJson(data);

      if (baseInfo.groups.isNotEmpty) {
        Global.baseInfo = baseInfo;

        return;
      }
    }, onError: (error) {
      if (alertWhenError) {
        AlertUtils.alertDialog(context: context, content: error);
      }
    }, onReLogin: () {});
  }
}
