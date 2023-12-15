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

  List toNameD() {
    List l = [];
    for (int idx = 0; idx < wallets.length; idx++) {
      l.add(wallets[idx].name);
    }

    return l;
  }

  List toIDD() {
    List l = [];
    for (int idx = 0; idx < wallets.length; idx++) {
      l.add(wallets[idx].id);
    }

    return l;
  }
}

class PickerData {
  final Map ids;
  final Map names;
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
    Map idM = {}, nameM = {};
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
}

class GetRecordsResp {
  final List<Bill> bills;
  final bool hasMore;
  final Statistics dayStatistics;
  final Statistics weekStatistics;
  final Statistics monthStatistics;

  const GetRecordsResp(
      {required this.bills,
      required this.hasMore,
      required this.dayStatistics,
      required this.weekStatistics,
      required this.monthStatistics});

  factory GetRecordsResp.fromJson(Map<String, dynamic> json) {
    return GetRecordsResp(
      bills: json['bills'] == null
          ? []
          : (json['bills'] as List).map((e) => Bill.fromJson(e)).toList(),
      hasMore: json['hasMore'],
      dayStatistics: Statistics.fromJson(json['dayStatistics']),
      weekStatistics: Statistics.fromJson(json['weekStatistics']),
      monthStatistics: Statistics.fromJson(json['monthStatistics']),
    );
  }

  factory GetRecordsResp.empty() {
    return GetRecordsResp(
        bills: [],
        hasMore: false,
        dayStatistics: Statistics.empty(),
        weekStatistics: Statistics.empty(),
        monthStatistics: Statistics.empty());
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
