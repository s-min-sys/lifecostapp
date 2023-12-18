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
  const RecordPage({super.key, required this.online});

  final bool online;

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  PickerData? fromPickerData, toPickerData;
  List<int> fromPosition = [], toPostions = [];
  final priceController = TextEditingController();
  late FocusNode myFocusNode;
  PDuration at = PDuration.now();
  bool online = true;

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();

    online = widget.online;
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
    var fromWalletName = pickerData.names.values
        .elementAt(pickerData.selected[0])[pickerData.selected[1]];
    var fromPersonID = pickerData.ids.keys.elementAt(pickerData.selected[0]);
    var fromPersonName =
        pickerData.names.keys.elementAt(pickerData.selected[0]);

    pickerData = toPickerData;
    if (pickerData == null || pickerData.ids.isEmpty) {
      AlertUtils.alertDialog(context: context, content: "没选择去向");

      return;
    }

    var toWalletID = pickerData.ids.values
        .elementAt(pickerData.selected[0])[pickerData.selected[1]];
    var toWalletName = pickerData.names.values
        .elementAt(pickerData.selected[0])[pickerData.selected[1]];
    var toPersonID = pickerData.ids.keys.elementAt(pickerData.selected[0]);
    var toPersonName = pickerData.names.keys.elementAt(pickerData.selected[0]);

    int dir = 1;
    if (fromPersonID == Global.baseInfo?.selfWallets.personID) {
      dir = 3;
    } else if (toPersonID == Global.baseInfo?.selfWallets.personID) {
      dir = 2;
    }

    DateTime curAt = DateTime(
        at.getSingle(DateType.Year),
        at.getSingle(DateType.Month),
        at.getSingle(DateType.Day),
        at.getSingle(DateType.Hour),
        at.getSingle(DateType.Minute),
        at.getSingle(DateType.Second));

    if (online) {
      NetUtils.requestHttp('/record', method: NetUtils.postMethod, data: {
        'fromSubWalletID': fromWalletID,
        'toSubWalletID': toWalletID,
        'amount': price,
        'at': (curAt.millisecondsSinceEpoch / 1000).round(),
      }, onSuccess: (data) {
        AlertUtils.alertDialog(
          context: context,
          content: "记录成功，是否关闭",
        ).then((value) => {if (value == 'ok') Navigator.pop(context, online)});
      }, onError: (error) {
        setState(() {
          online = false;
        });

        Global.addToCachedRecordList(CacheRecord(
            fromSubWalletID: fromWalletID,
            fromSubWalletName: fromWalletName,
            fromPersonName: fromPersonName,
            toSubWalletID: toWalletID,
            toSubWalletName: toWalletName,
            toPersonName: toPersonName,
            costDir: dir,
            amount: price,
            at: curAt));
        AlertUtils.alertDialog(
          context: context,
          content: "缓存成功, 记录将会在连接服务器后自动上传，是否关闭",
        ).then((value) => {if (value == 'ok') Navigator.pop(context, online)});
      });
    }

    if (!online) {
      Global.addToCachedRecordList(CacheRecord(
          fromSubWalletID: fromWalletID,
          fromSubWalletName: fromWalletName,
          fromPersonName: fromPersonName,
          toSubWalletID: toWalletID,
          toSubWalletName: toWalletName,
          toPersonName: toPersonName,
          costDir: dir,
          amount: price,
          at: curAt));
      AlertUtils.alertDialog(
        context: context,
        content: "缓存成功, 记录将会在连接服务器后自动上传，是否关闭",
      ).then((value) => {if (value == 'ok') Navigator.pop(context, online)});
    }
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
        columeNum: 2,
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

  String title() {
    if (online) {
      return '记录';
    }

    return '记录 [离线模式]';
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
        title: Text(title()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
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
            const Icon(
              Icons.arrow_downward,
              color: Colors.pink,
              size: 24.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                autofocus: true,
                focusNode: myFocusNode,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.money),
                    border: OutlineInputBorder(),
                    labelText: '金额(元)',
                    hintText: '输入金额'),
                inputFormatters: [
                  FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                ],
                controller: priceController,
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
            const Icon(
              Icons.arrow_downward,
              color: Colors.pink,
              size: 24.0,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            //elevation: 0,
                            //foregroundColor: Colors.red,
                            //backgroundColor: Colors.lightBlue,
                            //change text color of button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                            Text('记录'),
                            SizedBox(width: 10),
                            Icon(Icons.send),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
