import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifecostapp/components/global.dart';
import 'package:lifecostapp/components/model.dart';
import 'package:lifecostapp/helper/alert.dart';
import 'package:lifecostapp/helper/money.dart';
import 'package:lifecostapp/helper/netutils.dart';
import 'package:lifecostapp/pages/login.dart';
import 'package:lifecostapp/pages/record.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Bill> items = [];
  bool hasMore = false;
  Statistics dayStatistics = Statistics.empty();
  Statistics weekStatistics = Statistics.empty();
  Statistics monthStatistics = Statistics.empty();
  IndicatorController controller = IndicatorController();

  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  void flushRecords() {
    String recordID = '';
    if (items.isNotEmpty) {
      recordID = items[items.length - 1].id;
    }

    NetUtils.requestHttp('/records', method: NetUtils.postMethod, parameters: {
      'flag': '1',
    }, data: {
      'recordID': recordID,
      'pageCount': 4,
    }, onSuccess: (data) {
      var newRecords = GetRecordsResp.fromJson(data);
      setState(() {
        items = newRecords.bills;
        hasMore = hasMore;
        dayStatistics = newRecords.dayStatistics;
        weekStatistics = newRecords.weekStatistics;
        monthStatistics = newRecords.monthStatistics;
      });
    }, onError: (error) {
      AlertUtils.alertDialog(context: context, content: error);
    });
  }

  void _loadMore() {
    bool up = controller.edge == IndicatorEdge.leading;

    setState(() {
      isLoading = true;
    });

    bool newForward = up;

    String recordID = '';
    if (items.isNotEmpty) {
      if (!up) {
        recordID = items[items.length - 1].id;
      } else {
        recordID = items[0].id;
      }
    } else {
      newForward = false;
    }

    NetUtils.requestHttp('records', method: NetUtils.postMethod, parameters: {
      'flag': '1',
    }, data: {
      'recordID': recordID,
      'pageCount': 10,
      'newForward': newForward,
    }, onSuccess: (data) {
      var newRecords = GetRecordsResp.fromJson(data);

      if (newRecords.bills.isNotEmpty) {
        if (newForward) {
          items.insertAll(0, newRecords.bills.reversed);
        } else {
          items.addAll(newRecords.bills);
        }
      }
      hasMore = newRecords.hasMore;
      dayStatistics = newRecords.dayStatistics;
      weekStatistics = newRecords.weekStatistics;
      monthStatistics = newRecords.monthStatistics;

      setState(() {
        isLoading = false;
      });
    }, onError: (error) {
      AlertUtils.alertDialog(context: context, content: error);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMore);
    flushRecords();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Widget> personWidget(String personName, walletName, Color? color) {
    List<Widget> widgets = [];

    widgets.add(Icon(
      Icons.person,
      color: color,
      size: 24.0,
    ));
    widgets.add(Text(personName));
    widgets.add(Icon(
      Icons.wallet,
      color: color,
      size: 24.0,
    ));
    widgets.add(Text(walletName));

    return widgets;
  }

  List<Widget> mechanismWidget(
      String walletName, IconData? icon, Color? color) {
    List<Widget> widgets = [];

    widgets.add(Icon(
      icon,
      color: Colors.green,
      size: 24.0,
    ));
    widgets.add(Text(walletName));

    return widgets;
  }

  Widget? recordItemUI(Bill bill) {
    List<Widget> wLeft = [], wRight = [];
    IconData dirIcon = Icons.arrow_downward_outlined;
    Color dirColor = Colors.grey;
    Widget priceExWidget;

    if (bill.costDir == 1) {
      // CostDirInGroup
      wLeft = personWidget(
          bill.fromPersonName, bill.fromSubWalletName, Colors.grey);
      wRight =
          personWidget(bill.toPersonName, bill.toSubWalletName, Colors.grey);
      priceExWidget = Text(priceToUIYuanStringWithYuan(bill.amount),
          style: const TextStyle(fontSize: 22, color: Colors.grey));
    } else if (bill.costDir == 2) {
      //  CostDirIn
      wLeft =
          personWidget(bill.toPersonName, bill.toSubWalletName, Colors.green);
      wRight = mechanismWidget(
          bill.fromSubWalletName, Icons.add_reaction_outlined, Colors.green);
      dirIcon = Icons.arrow_upward_outlined;
      dirColor = Colors.green;
      priceExWidget = Text('+ ${priceToUIYuanStringWithYuan(bill.amount)}',
          style: const TextStyle(fontSize: 22, color: Colors.green));
    } else if (bill.costDir == 3) {
      // CostDirOut
      wLeft =
          personWidget(bill.fromPersonName, bill.fromSubWalletName, Colors.red);
      wRight = mechanismWidget(
          bill.toSubWalletName, Icons.shopping_cart_outlined, Colors.red);
      dirColor = Colors.red;
      priceExWidget = Text('- ${priceToUIYuanStringWithYuan(bill.amount)}',
          style: const TextStyle(fontSize: 22, color: Colors.red));
    } else {
      priceExWidget = const Text(':-()',
          style: TextStyle(fontSize: 22, color: Colors.grey));
    }

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
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
            const SizedBox(width: 30),
            const Expanded(
              child: Text(''),
            ),
            priceExWidget,
          ]),
        ],
      ),
    );
  }

  Widget statisticItemWidget(
      String title, subTitle, int count, Color? subTitleColor) {
    return Row(children: [
      Text(
        '  $title:',
        style: const TextStyle(fontSize: 14, color: Colors.black),
      ),
      Text(
        '[$count单]',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      Text(
        '  $subTitle',
        style: TextStyle(fontSize: 10, color: subTitleColor),
      ),
    ]);
  }

  Widget statisticsWidget(String title, Statistics statistics) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.2), //边框颜色
          width: 1, //边框宽度
        ), // 边色与边宽度
        color: Colors.white, // 底色
        boxShadow: [
          BoxShadow(
            blurRadius: 10, //阴影范围
            spreadRadius: 0.1, //阴影浓度
            color: Colors.grey.withOpacity(0.2), //阴影颜色
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            statisticItemWidget(
                '支出',
                priceToUIYuanStringWithYuan(statistics.outgoingAmount),
                statistics.outgoingCount,
                Colors.red),
            statisticItemWidget(
                '收入',
                priceToUIYuanStringWithYuan(statistics.incomingAmount),
                statistics.incomingCount,
                Colors.green),
          ],
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CheckboxListTile(
                title: const Text('开发环境'),
                onChanged: (bool? value) {
                  setState(() {
                    Global.devMode = value!;
                  });

                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (route) => false);
                },
                value: Global.devMode,
              ),
              ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.payments)),
                  title: const Text("生成进组码"),
                  onTap: () => {
                        NetUtils.requestHttp('/manager/group/enter-codes',
                            method: NetUtils.postMethod,
                            data: {}, onSuccess: (data) {
                          var resp = GroupEnterCodesResp.fromJson(data);
                          if (resp.enterCodes.isEmpty) {
                            AlertUtils.alertDialog(
                                context: context, content: '没接收到进组码');

                            return;
                          }

                          AlertUtils.alertDialog(
                                  context: context,
                                  content:
                                      '${resp.enterCodes[0]} , 过期时间为:${resp.expireAtS}',
                                  okButtonText: '拷贝进组码到内存',
                                  cancelButtonText: '关闭',
                                  title: '此进入码只显示一次')
                              .then((value) => {
                                    if (value == 'ok')
                                      {
                                        Clipboard.setData(ClipboardData(
                                            text: resp.enterCodes[0]))
                                      }
                                  });
                        }, onError: (error) {
                          AlertUtils.alertDialog(
                              context: context, content: error);
                        })
                      }),
              ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.payments)),
                  title: const Text("退出"),
                  onTap: () => {doLogout()}),
            ],
          ),
        ),
      ),
      body: CustomMaterialIndicator(
        trigger: IndicatorTrigger.bothEdges,
        onRefresh: () async {
          _loadMore();
        },
        controller: controller,
        indicatorBuilder:
            (BuildContext context, IndicatorController controller) {
          return const Icon(
            Icons.ac_unit,
            color: Colors.blue,
            size: 30,
          );
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                statisticsWidget('日统计', dayStatistics),
                statisticsWidget('周统计', weekStatistics),
              ]),
            ),
            Expanded(
              child: ListView.separated(
                //controller: _scrollController,
                itemCount: items.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < items.length) {
                    return recordItemUI(items[index]);
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecordPage()),
          );
        },
        tooltip: '记录',
        child: const Icon(Icons.add),
      ),
    );
  }
}
