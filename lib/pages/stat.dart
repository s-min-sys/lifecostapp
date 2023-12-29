import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:lifecostapp/components/model.dart';
import 'package:lifecostapp/components/share.dart';
import 'package:lifecostapp/components/ui.dart';
import 'package:lifecostapp/helper/alert.dart';
import 'package:lifecostapp/helper/money.dart';
import 'package:lifecostapp/helper/netutils.dart';

class StatPage extends StatefulWidget {
  const StatPage({super.key});

  @override
  State<StatPage> createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  List<StatYear> statistics = [];
  Map<String, List<Bill>> dayBills = {};

  fnYearMonthDayKey(int year, int month, int day) {
    return '$year-$month-$day';
  }

  @override
  void initState() {
    super.initState();

    NetUtils.requestHttp('/statistics/all', method: NetUtils.getMethod,
        onSuccess: (data) {
      statistics =
          (data['years'] as List).map((e) => StatYear.fromJson(e)).toList();
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

  Widget statisticsWidgetTiny(String title, LifeCostTotalData stat) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.blue),
        ),
        statisticItemWidget(
            '支出',
            priceToUIYuanStringWithYuan(stat.consumeAmount),
            stat.consumeCount,
            Colors.red),
        statisticItemWidget('收入', priceToUIYuanStringWithYuan(stat.earnAmount),
            stat.earnCount, Colors.green)
      ]),
    );
  }

  Widget statisticsWidget(String title, LifeCostTotalData stat) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
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

  int year = 0;
  int season = 0;
  int month = 0;
  int week = 0;
  int weekDay = 0;

  StatYear? getYearData(int year) {
    for (var idx = 0; idx < statistics.length; idx++) {
      if (statistics[idx].year == year) {
        return statistics[idx];
      }
    }

    return null;
  }

  StatSeason? getSeasonData(StatYear yearData, int season) {
    for (var idx = 0; idx < yearData.seasons.length; idx++) {
      if (yearData.seasons[idx].season == season) {
        return yearData.seasons[idx];
      }
    }

    return null;
  }

  StatMonth? getMonthData(StatSeason seasonData, int month) {
    for (var idx = 0; idx < seasonData.months.length; idx++) {
      if (seasonData.months[idx].month == month) {
        return seasonData.months[idx];
      }
    }

    return null;
  }

  StatWeek? getWeekData(StatMonth monthData, int week) {
    for (var idx = 0; idx < monthData.weeks.length; idx++) {
      if (monthData.weeks[idx].week == week) {
        return monthData.weeks[idx];
      }
    }

    return null;
  }

  StatWeekDay? getWeekDayData(StatWeek weekData, int weekDay) {
    for (var idx = 0; idx < weekData.days.length; idx++) {
      if (weekData.days[idx].weekDay == weekDay) {
        return weekData.days[idx];
      }
    }

    return null;
  }

  void getDayRecords(int year, int month, int day) {
    NetUtils.requestHttp('/records/day', method: NetUtils.postMethod, data: {
      'year': year,
      'month': month,
      'day': day,
    }, onSuccess: (data) {
      var newRecords =
          (data['bills'] as List).map((e) => Bill.fromJson(e)).toList();
      dayBills[fnYearMonthDayKey(year, month, day)] = newRecords;
      setState(() {});
    }, onError: (error) {
      AlertUtils.alertDialog(context: context, content: error);
    }, onReLogin: () {
      Share.doLogout(context);
    });
  }

  Widget? buildMainPanel() {
    Widget fnUI(String title, LifeCostTotalData stat, VoidCallback fn) {
      return InkWell(
        child: statisticsWidget(
          title,
          stat,
        ),
        onTap: () {
          setState(() {
            fn();
          });
        },
      );
    }

    Widget fnTinyUI(String title, LifeCostTotalData stat, VoidCallback fn) {
      return InkWell(
        child: statisticsWidgetTiny(title, stat),
        onTap: () {
          setState(() {
            fn();
          });
        },
      );
    }

    List<Widget> dateUIs() {
      if (year == 0) {
        return statistics
            .map((e) => fnUI('${e.year}年', e.stat, () {
                  year = e.year;
                  season = 0;
                  month = 0;
                  week = 0;
                  weekDay = 0;
                }))
            .toList();
      }

      List<Widget> widgets = [];

      StatYear? statYear = getYearData(year);
      if (statYear == null) {
        return widgets;
      }

      widgets.add(fnTinyUI('${statYear.year}年', statYear.stat, () {
        year = 0;
        season = 0;
        month = 0;
        week = 0;
        weekDay = 0;
      }));

      if (season == 0) {
        widgets.addAll(
            statYear.seasons.map((e) => fnUI('第${e.season}季', e.stat, () {
                  season = e.season;
                  month = 0;
                  week = 0;
                  weekDay = 0;
                })));

        return widgets;
      }

      StatSeason? statSeason = getSeasonData(statYear, season);
      if (statSeason == null) {
        return widgets;
      }

      widgets.add(fnTinyUI('第${statSeason.season}季', statSeason.stat, () {
        season = 0;
        month = 0;
        week = 0;
        weekDay = 0;
      }));

      if (month == 0) {
        widgets.addAll(
            statSeason.months.map((e) => fnUI('${e.month}月', e.stat, () {
                  month = e.month;
                  week = 0;
                  weekDay = 0;
                })));

        return widgets;
      }

      StatMonth? statMonth = getMonthData(statSeason, month);
      if (statMonth == null) {
        return widgets;
      }

      widgets.add(fnTinyUI('${statMonth.month}月', statMonth.stat, () {
        month = 0;
        week = 0;
        weekDay = 0;
      }));

      if (week == 0) {
        widgets
            .addAll(statMonth.weeks.map((e) => fnUI('第${e.week}周', e.stat, () {
                  week = e.week;
                  weekDay = 0;
                })));

        return widgets;
      }

      StatWeek? statWeek = getWeekData(statMonth, week);
      if (statWeek == null) {
        return widgets;
      }

      widgets.add(fnTinyUI('第${statWeek.week}周', statWeek.stat, () {
        week = 0;
        weekDay = 0;
      }));

      if (weekDay == 0) {
        widgets
            .addAll(statWeek.days.map((e) => fnUI('周${e.weekDay}', e.stat, () {
                  weekDay = e.weekDay;
                })));

        return widgets;
      }

      StatWeekDay? statWeekDay = getWeekDayData(statWeek, weekDay);
      if (statWeekDay == null) {
        return widgets;
      }

      widgets.add(fnTinyUI('周${statWeekDay.weekDay}', statWeekDay.stat, () {
        weekDay = 0;
      }));

      List<Widget> detailWidgets = [];

      if (dayBills
          .containsKey(fnYearMonthDayKey(year, month, statWeekDay.monthDay))) {
        var bills =
            dayBills[fnYearMonthDayKey(year, month, statWeekDay.monthDay)];
        if (bills != null) {
          detailWidgets.addAll(bills.map((e) => recordItemUI(e, null)));
        }
      } else {
        getDayRecords(year, month, statWeekDay.monthDay);
      }

      widgets.add(const Padding(
        padding: EdgeInsets.all(8.0),
        child: Divider(),
      ));
      if (detailWidgets.isEmpty) {
        widgets.add(Text('$year-$month-${statWeekDay.monthDay} 暂无详情数据'));
      } else {
        widgets.addAll(detailWidgets);
      }

      return widgets;
    }

    return Column(children: dateUIs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
      ),
      body: SingleChildScrollView(child: buildMainPanel()),
    );
  }
}
