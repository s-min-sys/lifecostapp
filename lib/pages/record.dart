import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/default_style.dart';
import 'package:flutter_pickers/time_picker/model/date_mode.dart';
import 'package:flutter_pickers/time_picker/model/date_type.dart';
import 'package:flutter_pickers/time_picker/model/pduration.dart';
import 'package:lifecostapp/components/global.dart';
import 'package:lifecostapp/components/model.dart';
import 'package:lifecostapp/helper/alert.dart';
import 'package:lifecostapp/helper/netutils.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  PickerData? fromPickerData, toPickerData;
  List<int> fromPosition = [], toPostions = [];
  final priceController = TextEditingController();
  late FocusNode myFocusNode;
  PDuration at = PDuration.now();

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  void doRecord() {
    var price = 0;

    try {
      price = (double.parse(priceController.text) * 100).toInt();
      // ignore: empty_catches
    } catch (e) {}

    if (price <= 0) {
      AlertUtils.alertDialog(context: context, content: "木有填写正确的价格");

      return;
    }

    var pickerData = fromPickerData;

    if (pickerData == null || pickerData.ids.isEmpty) {
      AlertUtils.alertDialog(context: context, content: "没选择来源");

      return;
    }

    var fromWalletID = pickerData.ids.values
        .elementAt(pickerData.selected[0])[pickerData.selected[1]];

    pickerData = toPickerData;
    if (pickerData == null || pickerData.ids.isEmpty) {
      AlertUtils.alertDialog(context: context, content: "没选择去向");

      return;
    }

    var toWalletID = pickerData.ids.values
        .elementAt(pickerData.selected[0])[pickerData.selected[1]];

    DateTime curAt = DateTime(
        at.getSingle(DateType.Year),
        at.getSingle(DateType.Month),
        at.getSingle(DateType.Day),
        at.getSingle(DateType.Hour),
        at.getSingle(DateType.Minute),
        at.getSingle(DateType.Second));

    NetUtils.requestHttp('/record', method: NetUtils.postMethod, data: {
      'fromSubWalletID': fromWalletID,
      'toSubWalletID': toWalletID,
      'amount': price,
      'at': (curAt.millisecondsSinceEpoch / 1000).round(),
    }, onSuccess: (data) {
      AlertUtils.alertDialog(context: context, content: "记录成功，是否关闭")
          .then((value) => {if (value == 'ok') Navigator.pop(context)});
    }, onError: (error) {
      AlertUtils.alertDialog(context: context, content: error);
    });
  }

  List<String> fromSelectText() {
    var baseInfo = Global.baseInfo;
    if (baseInfo == null) {
      return ['', ''];
    }

    PickerData? pickerData = fromPickerData;

    if (pickerData == null || pickerData.selected.isEmpty) {
      pickerData = baseInfo.toPickerData(true);
    }

    if (pickerData.selected.isEmpty) {
      return ['', ''];
    }

    fromPickerData = pickerData;

    return [
      pickerData.names.keys.elementAt(pickerData.selected[0]),
      pickerData.names.values
          .elementAt(pickerData.selected[0])[pickerData.selected[1]]
    ];
  }

  List<String> toSelectText() {
    var baseInfo = Global.baseInfo;
    if (baseInfo == null) {
      return ['', ''];
    }

    PickerData? pickerData = toPickerData;

    if (pickerData == null || pickerData.selected.isEmpty) {
      pickerData = baseInfo.toPickerData(false);
    }

    if (pickerData.selected.isEmpty) {
      return ['', ''];
    }

    toPickerData = pickerData;

    return [
      pickerData.names.keys.elementAt(pickerData.selected[0]),
      pickerData.names.values
          .elementAt(pickerData.selected[0])[pickerData.selected[1]]
    ];
  }

  void _datePicker() {
    Pickers.showDatePicker(context,
        mode: DateMode.YMDHMS, selectDate: PDuration.now(), onConfirm: (p) {
      setState(() {
        at = p;
      });
      myFocusNode.requestFocus();
    }, onCancel: (bool isCancel) {
      myFocusNode.requestFocus();
    });
  }

  void _showPicker(bool fromRequest) {
    var baseInfo = Global.baseInfo;
    if (baseInfo == null) {
      return;
    }

    var pickerData = baseInfo.toPickerData(fromRequest);
    if (fromRequest) {
      PickerData? oldPickerData = fromPickerData;
      if (oldPickerData != null) {
        pickerData.selected = oldPickerData.selected;
      }
      fromPickerData = pickerData;
    } else {
      PickerData? oldPickerData = toPickerData;
      if (oldPickerData != null) {
        pickerData.selected = oldPickerData.selected;
      }
      toPickerData = pickerData;
    }

    Pickers.showMultiLinkPicker(context,
        pickerStyle: DefaultPickerStyle(),
        data: pickerData.names,
        selectData: pickerData.getSelectedNames(),
        columeNum: 5,
        suffix: ['', '', '', '', ''], onConfirm: (List p, List<int> position) {
      setState(() {
        if (fromRequest) {
          fromPickerData?.selected = position;
        } else {
          toPickerData?.selected = position;
        }
      });
      myFocusNode.requestFocus();
    }, onCancel: (bool isCancel) {
      myFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    var from = fromSelectText();
    var to = toSelectText();

    DateTime curAt = DateTime(
        at.getSingle(DateType.Year),
        at.getSingle(DateType.Month),
        at.getSingle(DateType.Day),
        at.getSingle(DateType.Hour),
        at.getSingle(DateType.Minute),
        at.getSingle(DateType.Second));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('记录'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _showPicker(true);
              },
              child: SizedBox(
                height: 80,
                width: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(
                        Icons.person,
                        color: Colors.pink,
                        size: 24.0,
                      ),
                      Text(from[0]),
                    ]),
                    const Divider(
                      color: Colors.red,
                      height: 20,
                      thickness: 1,
                      indent: 20,
                      endIndent: 0,
                    ),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(
                        Icons.wallet,
                        color: Colors.pink,
                        size: 24.0,
                      ),
                      Text(from[1]),
                    ]),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 200,
                      child: TextField(
                        autofocus: true,
                        focusNode: myFocusNode,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.money),
                            border: OutlineInputBorder(),
                            labelText: '金额(元)',
                            hintText: '输入金额'),
                        inputFormatters: [
                          FilteringTextInputFormatter(RegExp("[0-9.]"),
                              allow: true),
                        ],
                        controller: priceController,
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        //elevation: 0,
                        foregroundColor: Colors.red,
                        //change text color of button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        doRecord();
                      },
                      child: const Row(children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward),
                      ]),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      foregroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                    ),
                    onPressed: () {
                      _datePicker();
                    },
                    child: Text(curAt.toString()),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, size: 24),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _showPicker(false);
              },
              child: SizedBox(
                height: 80,
                width: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(
                        Icons.person,
                        color: Colors.green,
                        size: 24.0,
                      ),
                      Text(to[0]),
                    ]),
                    const Divider(
                      color: Colors.red,
                      height: 20,
                      thickness: 1,
                      indent: 20,
                      endIndent: 0,
                    ),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(
                        Icons.wallet,
                        color: Colors.green,
                        size: 24.0,
                      ),
                      Text(to[1]),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        onPressed: () {
          _showPicker(true);
        },
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
