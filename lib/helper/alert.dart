import 'package:flutter/material.dart';

class AlertUtils {
  static Future alertDialog(
      {required BuildContext context,
      String title = '错误',
      required content}) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop("ok");
                  },
                  child: const Text("确定")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop("cancel");
                  },
                  child: const Text("取消"))
            ],
          );
        });
  }
}
