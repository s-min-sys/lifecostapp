import 'package:flutter/material.dart';
import 'package:lifecostapp/components/model.dart';
import 'package:lifecostapp/helper/money.dart';

List<Widget> personWidget(String personName, walletName) {
  List<Widget> widgets = [];

  Color color = Colors.cyan;

  widgets.add(Icon(
    Icons.person,
    color: color,
    size: 16.0,
  ));
  widgets.add(Text(personName));
  widgets.add(const SizedBox(width: 8));
  widgets.add(Icon(
    Icons.wallet,
    color: color,
    size: 16.0,
  ));
  widgets.add(Text(walletName));

  return widgets;
}

List<Widget> mechanismWidget(String walletName, IconData? icon) {
  List<Widget> widgets = [];
  widgets.add(Icon(
    icon,
    color: Colors.cyan,
    size: 36.0,
  ));
  widgets.add(const SizedBox(width: 2));
  widgets.add(Text(walletName));

  return widgets;
}

Widget recordItemUI(Bill bill, Widget? status) {
  List<Widget> wLeft = [], wRight = [];
  IconData dirIcon = Icons.arrow_downward_outlined;
  Color dirColor = Colors.grey,
      borderColor = Colors.grey,
      shadowColor = Colors.grey;
  Widget priceExWidget;

  List<Widget> statuses = [];

  if (status != null) {
    statuses.add(status);
  }

  if (bill.costDir == 1) {
    // CostDirInGroup
    wLeft = personWidget(bill.fromPersonName, bill.fromSubWalletName);
    wRight = personWidget(bill.toPersonName, bill.toSubWalletName);
    priceExWidget = Text(priceToUIYuanStringWithYuan(bill.amount),
        style: const TextStyle(fontSize: 22, color: Colors.grey));
  } else if (bill.costDir == 2) {
    //  CostDirIn
    wLeft = personWidget(bill.toPersonName, bill.toSubWalletName);
    wRight =
        mechanismWidget(bill.fromSubWalletName, Icons.add_reaction_outlined);
    dirIcon = Icons.arrow_upward_outlined;
    dirColor = Colors.green;
    priceExWidget = Text('+ ${priceToUIYuanStringWithYuan(bill.amount)}',
        style: const TextStyle(fontSize: 22, color: Colors.green));
    borderColor = const Color(0xF000FF00);
    shadowColor = const Color(0x0F00FF00);
  } else if (bill.costDir == 3) {
    // CostDirOut
    wLeft = personWidget(bill.fromPersonName, bill.fromSubWalletName);
    wRight =
        mechanismWidget(bill.toSubWalletName, Icons.shopping_cart_outlined);
    dirColor = Colors.red;
    priceExWidget = Text('- ${priceToUIYuanStringWithYuan(bill.amount)}',
        style: const TextStyle(fontSize: 22, color: Colors.red));
    borderColor = const Color(0xF0FF0000);
    shadowColor = const Color(0x0FFF0000);
  } else {
    priceExWidget =
        const Text(':-()', style: TextStyle(fontSize: 22, color: Colors.grey));
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        border: Border.all(
          width: .6,
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
              color: shadowColor,
              offset: const Offset(0.0, 6.0),
              blurRadius: 6,
              spreadRadius: 0)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [...wLeft]),
              const Spacer(),
              Row(children: [
                Text(bill.atS,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ]),
            Row(children: [
              Column(children: [
                Row(children: [
                  Icon(
                    dirIcon,
                    color: dirColor,
                    size: 24.0,
                  ),
                ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [...wRight]),
              ]),
              Visibility(
                  visible: bill.remark.isNotEmpty && bill.remark.length <= 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      bill.remark,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                      ),
                    ),
                  )),
              const SizedBox(width: 30),
              const Expanded(
                child: Text(''),
              ),
              priceExWidget,
            ]),
            Visibility(
              visible: bill.labelIDNames.isNotEmpty || bill.remark.length > 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 2,
                  children: [
                    Visibility(
                      visible: bill.remark.length > 4,
                      child: Text(
                        '备注: ${bill.remark}',
                        style: const TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                        softWrap: true,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    ...bill.labelIDNames
                        .map((e) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0)),
                                  border: Border.all(color: Colors.blueAccent)),
                              child: Text(
                                e,
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                    color: Colors.blue),
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ),
            ),
            ...statuses,
          ],
        ),
      ),
    ),
  );
}
