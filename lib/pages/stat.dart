import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:lifecostapp/components/model.dart';
import 'package:lifecostapp/helper/alert.dart';
import 'package:lifecostapp/helper/money.dart';
import 'package:lifecostapp/helper/netutils.dart';

class StatPage extends StatefulWidget {
  const StatPage({super.key});

  @override
  State<StatPage> createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  final GlobalKey<SliverTreeViewState> _simpleTreeKey =
      GlobalKey<SliverTreeViewState>();
  final AutoScrollController scrollController = AutoScrollController();
  TreeNode node = TreeNode.root();

  @override
  void initState() {
    super.initState();

    NetUtils.requestHttp('/statistics/all', method: NetUtils.getMethod,
        onSuccess: (data) {
      node = buildYears(data['years'] as List);
      setState(() {});
    }, onError: (error) {
      AlertUtils.alertDialog(context: context, content: error);
    });
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

  Widget statisticsWidget(String title, LifeCostTotalData stat) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 0.1,
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
                priceToUIYuanStringWithYuan(stat.consumeAmount),
                stat.consumeCount,
                Colors.red),
            statisticItemWidget(
                '收入',
                priceToUIYuanStringWithYuan(stat.earnAmount),
                stat.earnCount,
                Colors.green)
          ],
        ),
      ),
    );
  }

  Widget buildStatItem(TreeNode<dynamic> node) {
    if (node.data == null) {
      return const ListTile(
        title: Text('年度统计'),
      );
    }

    bool f = node.data is StatYear;
    if (f) {
      var v = node.data as StatYear;
      return statisticsWidget('${v.year}年', v.stat);
    }

    f = node.data is StatSeason;
    if (f) {
      var v = node.data as StatSeason;
      return statisticsWidget('第${v.season}季', v.stat);
    }

    f = node.data is StatMonth;
    if (f) {
      var v = node.data as StatMonth;
      return statisticsWidget('${v.month}月', v.stat);
    }

    f = node.data is StatWeek;
    if (f) {
      var v = node.data as StatWeek;
      return statisticsWidget('第${v.week}周', v.stat);
    }

    f = node.data is StatWeekDay;
    if (f) {
      var v = node.data as StatWeekDay;
      return statisticsWidget('周${v.weekDay} [${v.monthDay}号]', v.stat);
    }

    return const Text('呵呵');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
      ),
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverTreeView.simple(
            key: _simpleTreeKey,
            tree: node,
            scrollController: scrollController,
            expansionBehavior: ExpansionBehavior.none,
            builder: (context, node) => Card(
              child: buildStatItem(node),
            ),
          ),
        ],
      ),
    );
  }
}

TreeNode<StatWeekDay> buildWeekDay(StatWeekDay v) {
  return TreeNode<StatWeekDay>(data: v);
}

TreeNode<StatWeek> buildWeek(StatWeek v) {
  return TreeNode<StatWeek>(data: v)
    ..addAll(v.days.map((e) => buildWeekDay(e)).toList());
}

TreeNode<StatMonth> buildMonth(StatMonth v) {
  return TreeNode<StatMonth>(data: v)
    ..addAll(v.weeks.map((e) => buildWeek(e)).toList());
}

TreeNode<StatSeason> buildSeason(StatSeason v) {
  return TreeNode<StatSeason>(data: v)
    ..addAll(v.months.map((e) => buildMonth(e)).toList());
}

TreeNode<StatYear> buildYear(dynamic year) {
  var v = StatYear.fromJson(year);
  return TreeNode<StatYear>(data: v)
    ..addAll(v.seasons.map((e) => buildSeason(e)).toList());
}

TreeNode buildYears(List years) {
  return TreeNode.root()..addAll(years.map((e) => buildYear(e)).toList());
}
