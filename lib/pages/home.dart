import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifecostapp/components/global.dart';
import 'package:lifecostapp/components/model.dart';
import 'package:lifecostapp/components/share.dart';
import 'package:lifecostapp/components/ui.dart';
import 'package:lifecostapp/helper/alert.dart';
import 'package:lifecostapp/helper/money.dart';
import 'package:lifecostapp/helper/netutils.dart';
import 'package:lifecostapp/pages/deletedrecords.dart';
import 'package:lifecostapp/pages/login.dart';
import 'package:lifecostapp/pages/record.dart';
import 'package:lifecostapp/pages/walletadd.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:toastification/toastification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.online});
  final bool online;

  @override
  // ignore: no_logic_in_create_state
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Bill> items = [];
  bool hasMore = false;
  Statistics dayStatistics = Statistics.empty();
  Statistics weekStatistics = Statistics.empty();
  Statistics monthStatistics = Statistics.empty();
  Statistics seasonStatistics = Statistics.empty();
  Statistics yearStatistics = Statistics.empty();
  IndicatorController controller = IndicatorController();

  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool statByLables = false;
  List<IDName> selectedLabels = [];
  MultiSelectItem<IDName> noLabelData =
      MultiSelectItem<IDName>(const IDName(id: '', name: ''), '所有无标签数据');
  List<MultiSelectItem<IDName>> labels = [];
  bool forceReloadRecords = false;

  void flushRecords() {
    if (widget.online) {
      flushRecords4Onlne();
    } else {
      flushRecords4Offlne();
    }
  }

  void flushRecords4Offlne() {
    var records = Global.getCachedRecordList();
    if (records.isNotEmpty) {
      items = records.map((e) => Bill.fromCacheRecord(e)).toList();
      setState(() {});
    }
  }

  void flushRecords4Onlne() {
    List<String>? labels;
    if (statByLables) {
      labels = selectedLabels.map((e) => e.id).toList();
    }

    NetUtils.requestHttp('/records', method: NetUtils.postMethod, parameters: {
      'flag': '1',
    }, data: {
      'pageCount': 10,
      'requestStat': true,
      'statLabelIDs': labels,
    }, onSuccess: (data) {
      var newRecords = GetRecordsResp.fromJson(data);
      setState(() {
        items = newRecords.bills;
        hasMore = hasMore;
        dayStatistics = newRecords.dayStatistics;
        weekStatistics = newRecords.weekStatistics;
        monthStatistics = newRecords.monthStatistics;
        seasonStatistics = newRecords.seasonStatistics;
        yearStatistics = newRecords.yearStatistics;
        if (newRecords.bills.isNotEmpty) {
          toastification.show(
            context: context,
            title: '加载${newRecords.bills.length}条记录',
            autoCloseDuration: const Duration(seconds: 2),
          );
        }
      });
    }, onError: (error) {
      AlertUtils.alertDialog(context: context, content: error);
    }, onReLogin: () {
      Share.doLogout(context);
    });
  }

  void _loadMore() {
    if (widget.online) {
      _loadMore4Online();
    } else {
      flushRecords4Offlne();
    }
  }

  void _loadMore4Online() {
    _loadMore4OnlineOnUDFlag(controller.edge == IndicatorEdge.leading);
  }

  void _loadMore4OnlineOnUDFlag(bool up) {
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

    List<String>? labels;
    if (statByLables) {
      labels = selectedLabels.map((e) => e.id).toList();
    }

    NetUtils.requestHttp('/records', method: NetUtils.postMethod, parameters: {
      'flag': '1',
    }, data: {
      'recordID': recordID,
      'pageCount': 10,
      'newForward': newForward,
      'requestStat': true,
      'statLabelIDs': labels,
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
      seasonStatistics = newRecords.seasonStatistics;
      yearStatistics = newRecords.yearStatistics;
      if (newRecords.bills.isNotEmpty) {
        toastification.show(
          context: context,
          title: '新加载${newRecords.bills.length}条记录',
          autoCloseDuration: const Duration(seconds: 2),
        );
      }

      setState(() {
        isLoading = false;
      });
    }, onError: (error) {
      if (Share.isNetworkError(error)) {
        AlertUtils.alertDialog(
                context: context,
                content: '网络错误，是否切换到离线模式?',
                okButtonText: '好',
                cancelButtonText: "不要了")
            .then((value) => {
                  if (value == 'ok')
                    {if (context.mounted) Share.naviToLogin(context)}
                });
      } else {
        AlertUtils.alertDialog(context: context, content: error);
      }

      setState(() {
        isLoading = false;
      });
    }, onReLogin: () {
      Share.doLogout(context);
    });
  }

  @override
  void initState() {
    super.initState();

    statByLables = Global.getStatByLables();
    selectedLabels = Global.getStatLabelIDs();

    _scrollController.addListener(_loadMore);
    flushRecords();

    var records = Global.getCachedRecordList();
    if (records.isNotEmpty) {
      var submits =
          records.map((e) => Record4Commit.fromCacheRecord(e)).toList();
      NetUtils.requestHttp('/record/batch', method: NetUtils.postMethod, data: {
        'records': submits,
      }, onSuccess: (data) {
        Global.removeCachedRecordList();
        toastification.show(
          context: context,
          title: '缓存记录 ${submits.length} 条上传成功',
          autoCloseDuration: const Duration(seconds: 2),
        );
      }, onError: (error) {
        AlertUtils.alertDialog(
          context: context,
          content: error,
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                Colors.green)
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

  String userName() {
    var baseInfo = Global.baseInfo;
    if (baseInfo == null) {
      return '-';
    }

    return baseInfo.selfWallets.personName;
  }

  void removeRecrod(String id) {
    NetUtils.requestHttp('/record/delete/$id',
        method: NetUtils.postMethod, data: {}, onSuccess: (data) {
      var deleteRecordResp = DeleteRecordResp.fromJson(data);
      setState(() {
        dayStatistics = deleteRecordResp.dayStatistics;
        weekStatistics = deleteRecordResp.weekStatistics;
        monthStatistics = deleteRecordResp.monthStatistics;
        seasonStatistics = deleteRecordResp.seasonStatistics;
        yearStatistics = deleteRecordResp.yearStatistics;
      });
      toastification.show(
        context: context,
        title: '删除记录成功',
        autoCloseDuration: const Duration(seconds: 2),
      );
    }, onError: (error) {
      AlertUtils.alertDialog(context: context, content: error);
    });
  }

  Widget title() {
    if (widget.online) {
      return const Text('生活消费');
    }

    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      const Text('生活消费'),
      const Text(' 离线模式',
          style: TextStyle(
            fontSize: 12,
            color: Colors.blueGrey,
          )),
      const SizedBox(width: 20),
      ElevatedButton(
          onPressed: () {
            Share.naviToLogin(context);
          },
          child: const Text('转在线'))
    ]);
  }

  Widget recordIteWithWrapper(int index) {
    if (!Global.enableDelete) {
      return recordItemUI(items[index], null);
    }

    return Dismissible(
        key: Key(items[index].id),
        background: Container(
            color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        WavyAnimatedText('左滑删除'),
                      ],
                      isRepeatingAnimation: true,
                    ),
                  ),
                )
              ],
            )),
        confirmDismiss: (DismissDirection direction) async {
          if (direction != DismissDirection.endToStart) {
            return Future(() => false);
          }
          return await AlertUtils.alertDialog(
                  context: context, content: '确定要删除当前记录么？') ==
              'ok';
        },
        onDismissed: (direction) {
          removeRecrod(items[index].id);
          items.removeAt(index);
          setState(() {});
        },
        child: recordItemUI(items[index], null));
  }

  @override
  Widget build(BuildContext context) {
    labels = [noLabelData];
    var labelsA = Global.baseInfo?.labels
        .map((e) => MultiSelectItem<IDName>(e, e.name))
        .toList();
    if (labelsA != null) {
      labels.addAll(labelsA);
    }

    for (var i = 0; i < labels.length; i++) {
      for (var idx = 0; idx < selectedLabels.length; idx++) {
        if (selectedLabels[idx].id == labels[i].value.id) {
          selectedLabels[idx] = labels[i].value;
          break;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: title(),
      ),
      onDrawerChanged: (bool isOpened) {
        if (!isOpened) {
          if (forceReloadRecords) {
            forceReloadRecords = false;
            flushRecords();
          }
        }
      },
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(userName()),
                accountEmail: const Text(''),
              ),
              CheckboxListTile(
                title: const Text('开发环境'),
                onChanged: (bool? value) {
                  forceReloadRecords = true;
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
              const Divider(),
              CheckboxListTile(
                title: const Text('允许删除记录'),
                onChanged: (bool? value) {
                  setState(() {
                    Global.enableDelete = value!;
                  });
                },
                value: Global.enableDelete,
              ),
              const Divider(),
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
                                      '${resp.enterCodes[0]}\n\n过期时间为:${resp.expireAtS}',
                                  okButtonText: '复制',
                                  cancelButtonText: '关闭',
                                  title: '此邀请码码只显示一次')
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
              const Divider(),
              ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.wallet_sharp)),
                  title: const Text("增加钱包"),
                  onTap: () => {
                        toWalletAddPage(),
                      }),
              const Divider(),
              ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.wallet_sharp)),
                  title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('统计 - 按标签显示'),
                            Switch(
                              value: statByLables,
                              onChanged: (bool value) {
                                Global.savetStatByLables(value);
                                forceReloadRecords = true;
                                setState(() {
                                  statByLables = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Visibility(
                          visible: statByLables,
                          child: MultiSelectDialogField(
                            listType: MultiSelectListType.CHIP,
                            buttonText: const Text("选择标签"),
                            title: const Text("标签"),
                            initialValue: selectedLabels,
                            items: labels,
                            onConfirm: (values) {
                              selectedLabels =
                                  values.map((e) => e as IDName).toList();
                              forceReloadRecords = true;
                              setState(() {});

                              Global.savettatLabelIDs(selectedLabels);
                            },
                            chipDisplay: MultiSelectChipDisplay(),
                          ),
                        ),
                      ]),
                  onTap: () => {
                        toWalletAddPage(),
                      }),
              const Divider(),
              ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.logout)),
                  title: const Text("查看删除记录"),
                  onTap: () => {toDeletedRecordsPage()}),
              const Divider(),
              ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.logout)),
                  title: const Text("注销用户"),
                  onTap: () => {doLogout()}),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(height: 90, width: 20),
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      statisticsWidget('日统计', dayStatistics),
                      const SizedBox(width: 2),
                      statisticsWidget('周统计', weekStatistics),
                      const SizedBox(width: 2),
                      statisticsWidget('月统计', monthStatistics),
                      const SizedBox(width: 2),
                      statisticsWidget('季统计', seasonStatistics),
                      const SizedBox(width: 2),
                      statisticsWidget('年统计', yearStatistics),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomMaterialIndicator(
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
              child: ListView.builder(
                itemCount: items.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < items.length) {
                    return recordIteWithWrapper(index);
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          toRecordPage();
        },
        tooltip: '记录',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> toRecordPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RecordPage(online: widget.online)),
    );

    if (result != null && result != widget.online) {
      if (context.mounted) Share.naviToLogin(context);
    } else {
      if (widget.online) {
        _loadMore4OnlineOnUDFlag(true);
      } else {
        flushRecords4Offlne();
      }
    }
  }

  Future<void> toDeletedRecordsPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeletedRecordsPage()),
    );

    if (result != null && result) {
      flushRecords();
    }
  }

  Future<void> toWalletAddPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WalletAddPage()),
    );

    if (context.mounted) Share.doFlushBaseInfos(context, true);
  }
}
