import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:lifecostapp/components/model.dart';
import 'package:lifecostapp/components/share.dart';
import 'package:lifecostapp/components/ui.dart';
import 'package:lifecostapp/helper/alert.dart';
import 'package:lifecostapp/helper/netutils.dart';
import 'package:toastification/toastification.dart';

class DeletedRecordsPage extends StatefulWidget {
  const DeletedRecordsPage({super.key});

  @override
  // ignore: no_logic_in_create_state
  State<DeletedRecordsPage> createState() => _DeletedRecordsPageState();
}

class _DeletedRecordsPageState extends State<DeletedRecordsPage> {
  List<DeletedBill> items = [];
  bool restoreFlag = false;

  @override
  void initState() {
    super.initState();

    flushDeletedRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('删除历史'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(restoreFlag),
        ),
      ),
      body: Column(children: [
        Expanded(
            child: ListView.builder(
          itemCount: items.length,
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
        )),
      ]),
    );
  }

  Widget recordIteWithWrapper(int index) {
    return Dismissible(
        key: Key(items[index].bill.id),
        background: Container(
            color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        WavyAnimatedText('右滑恢复'),
                      ],
                      isRepeatingAnimation: true,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        WavyAnimatedText('左滑彻底删除'),
                      ],
                      isRepeatingAnimation: true,
                    ),
                  ),
                )
              ],
            )),
        confirmDismiss: (DismissDirection direction) async {
          if (direction == DismissDirection.endToStart) {
            return await AlertUtils.alertDialog(
                    context: context, content: '确定要清除当前删除记录么？') ==
                'ok';
          } else if (direction == DismissDirection.startToEnd) {
            return await AlertUtils.alertDialog(
                    context: context, content: '确定要恢复当前已删除记录么？') ==
                'ok';
          } else {
            return Future(() => false);
          }
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            removeRecrod(items[index].bill.id);
          } else if (direction == DismissDirection.startToEnd) {
            restoreRecrod(items[index].bill.id);
          }

          items.removeAt(index);

          setState(() {});
        },
        child: Column(children: [
          recordItemUI(
              items[index].bill,
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Text(
                  '删除于${items[index].deletedAt}',
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              )),
        ]));
  }

  void flushDeletedRecords() {
    NetUtils.requestHttp('/deleted-records',
        method: NetUtils.getMethod, parameters: {}, onSuccess: (data) {
      var newRecords = GetDeletedRecordsResp.fromJson(data);
      setState(() {
        items = newRecords.bills;
      });
    }, onError: (error) {
      AlertUtils.alertDialog(
          context: context, content: error, hideCancelButton: true);
    }, onReLogin: () {
      Share.doLogout(context);
    });
  }

  void removeRecrod(String id) {
    NetUtils.requestHttp('/deleted-records/delete/$id',
        method: NetUtils.postMethod, data: {}, onSuccess: (data) {
      toastification.show(
        context: context,
        title: '清除删除记录成功',
        autoCloseDuration: const Duration(seconds: 2),
      );
    }, onError: (error) {});
  }

  void restoreRecrod(String id) {
    NetUtils.requestHttp('/deleted-records/restore/$id',
        method: NetUtils.postMethod, data: {}, onSuccess: (data) {
      restoreFlag = true;
      toastification.show(
        context: context,
        title: '恢复记录成功',
        autoCloseDuration: const Duration(seconds: 2),
      );
    }, onError: (error) {});
  }
}
