class IDName {
  final String id;
  final String name;

  const IDName({required this.id, required this.name});

  factory IDName.fromJson(Map<String, dynamic> json) {
    return IDName(
      id: json['id'],
      name: json['name'],
    );
  }

  factory IDName.empty() {
    return const IDName(id: '', name: '');
  }

  Map toJson() {
    Map map = {};
    map["id"] = id;
    map["name"] = name;
    return map;
  }

  String toNameD() {
    return name;
  }
}

class MerchantWallets {
  final String personID;
  final String personName;
  final int costDir;
  final List<IDName> wallets;

  const MerchantWallets({
    required this.personID,
    required this.personName,
    required this.costDir, // 1: in group; 2: in; 3: out
    required this.wallets,
  });

  factory MerchantWallets.fromJson(Map<String, dynamic> json) {
    return MerchantWallets(
      personID: json['personID'],
      personName: json['personName'],
      costDir: json['costDir'],
      wallets:
          (json['wallets'] as List).map((e) => IDName.fromJson(e)).toList(),
    );
  }

  factory MerchantWallets.empty() {
    return const MerchantWallets(
        personID: '', personName: '', costDir: 0, wallets: []);
  }

  Map toJson() {
    Map map = {};
    map["personID"] = personID;
    map["personName"] = personName;
    map["costDir"] = costDir;
    map["wallets"] = wallets;

    return map;
  }

  List<String> toNameD() {
    List<String> l = [];
    for (int idx = 0; idx < wallets.length; idx++) {
      l.add(wallets[idx].name);
    }

    return l;
  }

  List<String> toIDD() {
    List<String> l = [];
    for (int idx = 0; idx < wallets.length; idx++) {
      l.add(wallets[idx].id);
    }

    return l;
  }
}

class PickerData {
  final Map<String, List<String>> ids;
  final Map<String, List<String>> names;
  List<int> selected;

  PickerData(this.ids, this.names, this.selected);

  List? getSelectedNames() {
    if (names.isEmpty) {
      return null;
    }

    if (selected.isEmpty) {
      selected = [0, 0];
    }

    return [
      names.keys.elementAt(selected[0]),
      names.values.elementAt(selected[0])[selected[1]]
    ];
  }

  void adjustSelected(String personID, String walletID) {
    var selectPersonIndex = -1, selectedWalletIndex = 1;

    for (var idx = 0; idx < ids.keys.length; idx++) {
      if (ids.keys.elementAt(idx) == personID) {
        selectPersonIndex = idx;

        for (var i = 0; i < ids.values.elementAt(idx).length; i++) {
          if (ids.values.elementAt(idx).elementAt(i) == walletID) {
            selectedWalletIndex = i;
          }
        }
      }
    }

    if (selectPersonIndex != -1 && selectedWalletIndex != -1) {
      selected = [selectPersonIndex, selectedWalletIndex];
    }
  }

  List<String> getSelectedIDs() {
    if (selected.length != 2) {
      return [];
    }

    return [
      ids.keys.elementAt(selected[0]),
      ids.values.elementAt(selected[0]).elementAt(selected[1])
    ];
  }
}

class BaseInfo {
  final List<MerchantWallets> merchantWallets;
  final MerchantWallets selfWallets;
  final List<IDName> labels;
  final List<IDName> groups;

  const BaseInfo({
    required this.merchantWallets,
    required this.selfWallets,
    required this.labels, // 1: in group; 2: in; 3: out
    required this.groups,
  });

  factory BaseInfo.fromJson(Map<String, dynamic> json) {
    return BaseInfo(
      merchantWallets: (json['merchantWallets'] as List)
          .map((e) => MerchantWallets.fromJson(e))
          .toList(),
      selfWallets: MerchantWallets.fromJson(json['selfWallets']),
      labels: (json['labels'] as List).map((e) => IDName.fromJson(e)).toList(),
      groups: json['groups'] == null
          ? []
          : (json['groups'] as List).map((e) => IDName.fromJson(e)).toList(),
    );
  }

  Map toJson() {
    Map map = {};
    map["merchantWallets"] = merchantWallets;
    map["selfWallets"] = selfWallets;
    map["labels"] = labels;
    map["groups"] = groups;

    return map;
  }

  PickerData toPickerData(bool fromRequest) {
    Map<String, List<String>> idM = {}, nameM = {};
    List<int> selected = [];

    for (int idx = 0; idx < merchantWallets.length; idx++) {
      if (fromRequest) {
        if (merchantWallets[idx].costDir == 2) {
          continue;
        }
      } else {
        if (merchantWallets[idx].costDir == 3) {
          continue;
        }
      }

      idM[merchantWallets[idx].personID] = merchantWallets[idx].toIDD();
      nameM[merchantWallets[idx].personName] = merchantWallets[idx].toNameD();
    }

    idM[selfWallets.personID] = selfWallets.toIDD();
    nameM[selfWallets.personName] = selfWallets.toNameD();

    if (fromRequest) {
      selected = [idM.length - 1, 0];
    } else {
      //return (fromPickerData.names.values.elementAt(fromPickerData.selected[0])
      //as List)[fromPickerData.selected[1]];
      selected = [0, 0];
    }

    return PickerData(idM, nameM, selected);
  }
}

class Bill {
  final String id;
  final String fromSubWalletID;
  final String fromSubWalletName;
  final String toSubWalletID;
  final String toSubWalletName;
  final int costDir;
  final int amount;
  final List<String> labelIDs;
  final List<String> labelIDNames;
  final String remark;
  final int lossAmount;
  final String lossWalletID;
  final String lossWalletName;
  final String atS;
  final String fromPersonName;
  final String toPersonName;
  final String operationID;
  final String operationName;

  const Bill({
    required this.id,
    required this.fromSubWalletID,
    required this.fromSubWalletName,
    required this.toSubWalletID,
    required this.toSubWalletName,
    required this.costDir,
    required this.amount,
    required this.labelIDs,
    required this.labelIDNames,
    required this.remark,
    required this.lossAmount,
    required this.lossWalletID,
    required this.lossWalletName,
    required this.atS,
    required this.fromPersonName,
    required this.toPersonName,
    required this.operationID,
    required this.operationName,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      fromSubWalletID: json['fromSubWalletID'],
      fromSubWalletName: json['fromSubWalletName'],
      toSubWalletID: json['toSubWalletID'],
      toSubWalletName: json['toSubWalletName'],
      costDir: json['costDir'],
      amount: json['amount'],
      labelIDs: List<String>.from(json['labelIDs'] as List),
      labelIDNames: List<String>.from(json['labelIDNames'] as List),
      remark: json['remark'],
      lossAmount: json['lossAmount'],
      lossWalletID: json['lossWalletID'],
      lossWalletName: json['lossWalletName'],
      atS: json['atS'],
      fromPersonName: json['fromPersonName'],
      toPersonName: json['toPersonName'],
      operationID: json['operationID'],
      operationName: json['operationName'],
    );
  }

  factory Bill.empty() {
    return const Bill(
      id: '',
      fromSubWalletID: '',
      fromSubWalletName: '',
      toSubWalletID: '',
      toSubWalletName: '',
      costDir: 0,
      amount: 0,
      labelIDs: [],
      labelIDNames: [],
      remark: '',
      lossAmount: 0,
      lossWalletID: '',
      lossWalletName: '',
      atS: '',
      fromPersonName: '',
      toPersonName: '',
      operationID: '',
      operationName: '',
    );
  }

  factory Bill.fromCacheRecord(CacheRecord record) {
    return Bill(
      id: '',
      fromSubWalletID: record.fromSubWalletID,
      fromSubWalletName: record.fromSubWalletName,
      toSubWalletID: record.toSubWalletID,
      toSubWalletName: record.toSubWalletName,
      costDir: record.costDir,
      amount: record.amount,
      labelIDs: [],
      labelIDNames: [],
      remark: '',
      lossAmount: 0,
      lossWalletID: '',
      lossWalletName: '',
      atS: record.at.toString(),
      fromPersonName: record.fromPersonName,
      toPersonName: record.toPersonName,
      operationID: '',
      operationName: '',
    );
  }
}

class GetRecordsResp {
  final List<Bill> bills;
  final bool hasMore;
  final Statistics dayStatistics;
  final Statistics weekStatistics;
  final Statistics monthStatistics;
  final Statistics seasonStatistics;
  final Statistics yearStatistics;

  const GetRecordsResp(
      {required this.bills,
      required this.hasMore,
      required this.dayStatistics,
      required this.weekStatistics,
      required this.monthStatistics,
      required this.seasonStatistics,
      required this.yearStatistics});

  factory GetRecordsResp.fromJson(Map<String, dynamic> json) {
    return GetRecordsResp(
      bills: json['bills'] == null
          ? []
          : (json['bills'] as List).map((e) => Bill.fromJson(e)).toList(),
      hasMore: json['hasMore'],
      dayStatistics: Statistics.fromJson(json['dayStatistics']),
      weekStatistics: Statistics.fromJson(json['weekStatistics']),
      monthStatistics: Statistics.fromJson(json['monthStatistics']),
      seasonStatistics: json.containsKey('seasonStatistics') &&
              json['seasonStatistics'] != null
          ? Statistics.fromJson(json['seasonStatistics'])
          : Statistics.empty(),
      yearStatistics:
          json.containsKey('yearStatistics') && json['yearStatistics'] != null
              ? Statistics.fromJson(json['yearStatistics'])
              : Statistics.empty(),
    );
  }

  factory GetRecordsResp.empty() {
    return GetRecordsResp(
        bills: [],
        hasMore: false,
        dayStatistics: Statistics.empty(),
        weekStatistics: Statistics.empty(),
        monthStatistics: Statistics.empty(),
        seasonStatistics: Statistics.empty(),
        yearStatistics: Statistics.empty());
  }
}

class Statistics {
  final int incomingCount;
  final int outgoingCount;
  final int groupTransCount;

  final int incomingAmount;
  final int outgoingAmount;

  const Statistics(
      {required this.incomingCount,
      required this.outgoingCount,
      required this.groupTransCount,
      required this.incomingAmount,
      required this.outgoingAmount});

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      incomingCount: json['incomingCount'],
      outgoingCount: json['outgoingCount'],
      groupTransCount: json['groupTransCount'],
      incomingAmount: json['incomingAmount'],
      outgoingAmount: json['outgoingAmount'],
    );
  }

  factory Statistics.empty() {
    return const Statistics(
        incomingCount: 0,
        outgoingCount: 0,
        groupTransCount: 0,
        incomingAmount: 0,
        outgoingAmount: 0);
  }
}

class StatisticsResp {
  final Statistics dayStatistics;
  final Statistics weekStatistics;
  final Statistics monthStatistics;

  const StatisticsResp({
    required this.dayStatistics,
    required this.weekStatistics,
    required this.monthStatistics,
  });

  factory StatisticsResp.fromJson(Map<String, dynamic> json) {
    return StatisticsResp(
      dayStatistics: Statistics.fromJson(json['dayStatistics']),
      weekStatistics: Statistics.fromJson(json['weekStatistics']),
      monthStatistics: Statistics.fromJson(json['monthStatistics']),
    );
  }

  factory StatisticsResp.empty() {
    return StatisticsResp(
        dayStatistics: Statistics.empty(),
        weekStatistics: Statistics.empty(),
        monthStatistics: Statistics.empty());
  }
}

class GroupEnterCodesResp {
  final List<String> enterCodes;
  final String expireAtS;

  const GroupEnterCodesResp(
      {required this.enterCodes, required this.expireAtS});

  factory GroupEnterCodesResp.fromJson(Map<String, dynamic> json) {
    return GroupEnterCodesResp(
      enterCodes: List<String>.from(json['enterCodes']),
      expireAtS: json['expireAtS'],
    );
  }

  factory GroupEnterCodesResp.empty() {
    return const GroupEnterCodesResp(enterCodes: [], expireAtS: '');
  }
}

class CacheRecord {
  final String fromSubWalletID;
  final String fromSubWalletName;
  final String fromPersonName;
  final String toSubWalletID;
  final String toSubWalletName;
  final String toPersonName;
  final int costDir;
  final int amount;
  final String remark;
  final List<String> labels;
  final DateTime at;

  const CacheRecord({
    required this.fromSubWalletID,
    required this.fromSubWalletName,
    required this.fromPersonName,
    required this.toSubWalletID,
    required this.toSubWalletName,
    required this.toPersonName,
    required this.costDir,
    required this.amount,
    required this.remark,
    required this.labels,
    required this.at,
  });

  factory CacheRecord.fromJson(Map<String, dynamic> json) {
    return CacheRecord(
      fromSubWalletID: json['fromSubWalletID'],
      fromSubWalletName: json['fromSubWalletName'],
      fromPersonName: json['fromPersonName'],
      toSubWalletID: json['toSubWalletID'],
      toSubWalletName: json['toSubWalletName'],
      toPersonName: json['toPersonName'],
      costDir: json['costDir'],
      amount: json['amount'],
      remark: json.containsKey('remark') ? json['remark'] : '',
      labels: json.containsKey('labels') && json['labels'] != null
          ? List<String>.from(json['labels'])
          : [],
      at: json.containsKey('at') ? DateTime.parse(json['at']) : DateTime.now(),
    );
  }

  Map toJson() {
    Map map = {};
    map["fromSubWalletID"] = fromSubWalletID;
    map["fromSubWalletName"] = fromSubWalletName;
    map["fromPersonName"] = fromPersonName;
    map["toSubWalletID"] = toSubWalletID;
    map["toSubWalletName"] = toSubWalletName;
    map["toPersonName"] = toPersonName;
    map["costDir"] = costDir;
    map["amount"] = amount;
    map["remark"] = remark;
    map["labels"] = labels;
    map["at"] = at.toString();

    return map;
  }
}

class Record4Commit {
  final String fromSubWalletID;
  final String toSubWalletID;
  final int amount;
  final String remark;
  final List<String> labels;
  final int at;

  const Record4Commit({
    required this.fromSubWalletID,
    required this.toSubWalletID,
    required this.amount,
    required this.remark,
    required this.labels,
    required this.at,
  });

  factory Record4Commit.fromCacheRecord(CacheRecord record) {
    return Record4Commit(
      fromSubWalletID: record.fromSubWalletID,
      toSubWalletID: record.toSubWalletID,
      amount: record.amount,
      remark: record.remark,
      labels: record.labels,
      at: (record.at.millisecondsSinceEpoch / 1000).round(),
    );
  }

  Map toJson() {
    Map map = {};
    map["fromSubWalletID"] = fromSubWalletID;
    map["toSubWalletID"] = toSubWalletID;
    map["amount"] = amount;
    map["remark"] = remark;
    map["labelIDs"] = labels;
    map["at"] = at;

    return map;
  }
}

class DeletedBill {
  final Bill bill;
  final String deletedAt;

  const DeletedBill({
    required this.bill,
    required this.deletedAt,
  });

  factory DeletedBill.fromJson(Map<String, dynamic> json) {
    return DeletedBill(bill: Bill.fromJson(json), deletedAt: json['deletedAt']);
  }
}

class GetDeletedRecordsResp {
  final List<DeletedBill> bills;

  const GetDeletedRecordsResp({
    required this.bills,
  });

  factory GetDeletedRecordsResp.fromJson(Map<String, dynamic> json) {
    return GetDeletedRecordsResp(
        bills: json['bills'] == null
            ? []
            : (json['bills'] as List)
                .map((e) => DeletedBill.fromJson(e))
                .toList());
  }
}

class DeleteRecordResp {
  final Statistics dayStatistics;
  final Statistics weekStatistics;
  final Statistics monthStatistics;
  final Statistics seasonStatistics;
  final Statistics yearStatistics;

  const DeleteRecordResp(
      {required this.dayStatistics,
      required this.weekStatistics,
      required this.monthStatistics,
      required this.seasonStatistics,
      required this.yearStatistics});

  factory DeleteRecordResp.fromJson(Map<String, dynamic> json) {
    return DeleteRecordResp(
      dayStatistics: Statistics.fromJson(json['dayStatistics']),
      weekStatistics: Statistics.fromJson(json['weekStatistics']),
      monthStatistics: Statistics.fromJson(json['monthStatistics']),
      seasonStatistics: json.containsKey('seasonStatistics') &&
              json['seasonStatistics'] != null
          ? Statistics.fromJson(json['seasonStatistics'])
          : Statistics.empty(),
      yearStatistics:
          json.containsKey('yearStatistics') && json['yearStatistics'] != null
              ? Statistics.fromJson(json['yearStatistics'])
              : Statistics.empty(),
    );
  }

  factory DeleteRecordResp.empty() {
    return DeleteRecordResp(
        dayStatistics: Statistics.empty(),
        weekStatistics: Statistics.empty(),
        monthStatistics: Statistics.empty(),
        seasonStatistics: Statistics.empty(),
        yearStatistics: Statistics.empty());
  }
}

class LifeCostTotalData {
  final int consumeCount;
  final int consumeAmount;
  final int earnCount;
  final int earnAmount;

  const LifeCostTotalData(
      {required this.consumeCount,
      required this.consumeAmount,
      required this.earnCount,
      required this.earnAmount});

  factory LifeCostTotalData.fromJson(Map<String, dynamic> json) {
    return LifeCostTotalData(
      consumeCount:
          json.containsKey('consume_count') ? json['consume_count'] : 0,
      consumeAmount:
          json.containsKey('consume_amount') ? json['consume_amount'] : 0,
      earnCount: json.containsKey('earn_count') ? json['earn_count'] : 0,
      earnAmount: json.containsKey('earn_amount') ? json['earn_amount'] : 0,
    );
  }
}

class StatWeekDay {
  final int weekDay;
  final int monthDay;
  final LifeCostTotalData stat;

  const StatWeekDay(
      {required this.weekDay, required this.monthDay, required this.stat});

  factory StatWeekDay.fromJson(Map<String, dynamic> json) {
    return StatWeekDay(
      weekDay: json['weekDay'],
      monthDay: json['monthDay'],
      stat: LifeCostTotalData.fromJson(json['stat']),
    );
  }
}

class StatWeek {
  final int week;
  final LifeCostTotalData stat;
  final List<StatWeekDay> days;

  const StatWeek({required this.week, required this.stat, required this.days});

  factory StatWeek.fromJson(Map<String, dynamic> json) {
    return StatWeek(
      week: json['week'],
      stat: LifeCostTotalData.fromJson(json['stat']),
      days: json.containsKey('days') && json['days'] != null
          ? (json['days'] as List).map((e) => StatWeekDay.fromJson(e)).toList()
          : [],
    );
  }
}

class StatMonth {
  final int month;
  final LifeCostTotalData stat;
  final List<StatWeek> weeks;

  const StatMonth(
      {required this.month, required this.stat, required this.weeks});

  factory StatMonth.fromJson(Map<String, dynamic> json) {
    return StatMonth(
      month: json['month'],
      stat: LifeCostTotalData.fromJson(json['stat']),
      weeks: json.containsKey('weeks') && json['weeks'] != null
          ? (json['weeks'] as List).map((e) => StatWeek.fromJson(e)).toList()
          : [],
    );
  }
}

class StatSeason {
  final int season;
  final LifeCostTotalData stat;
  final List<StatMonth> months;

  const StatSeason(
      {required this.season, required this.stat, required this.months});

  factory StatSeason.fromJson(Map<String, dynamic> json) {
    return StatSeason(
      season: json['season'],
      stat: LifeCostTotalData.fromJson(json['stat']),
      months: json.containsKey('months') && json['months'] != null
          ? (json['months'] as List).map((e) => StatMonth.fromJson(e)).toList()
          : [],
    );
  }
}

class StatYear {
  final int year;
  final LifeCostTotalData stat;
  final List<StatSeason> seasons;

  const StatYear(
      {required this.year, required this.stat, required this.seasons});

  factory StatYear.fromJson(Map<String, dynamic> json) {
    return StatYear(
      year: json['year'],
      stat: LifeCostTotalData.fromJson(json['stat']),
      seasons: json.containsKey('seasons') && json['seasons'] != null
          ? (json['seasons'] as List)
              .map((e) => StatSeason.fromJson(e))
              .toList()
          : [],
    );
  }
}
