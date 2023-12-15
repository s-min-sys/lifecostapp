import 'package:flutter/material.dart';

class AlertUtils {
  static Future alertDialog(
      {required BuildContext context,
      String title = '错误',
      okButtonText = '确定',
      cancelButtonText = '取消',
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
                  child: Text(okButtonText)),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop("cancel");
                  },
                  child: Text(cancelButtonText))
            ],
          );
        });
  }
}
