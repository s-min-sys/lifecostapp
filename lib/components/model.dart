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
      names.values.elementAt(selected[0])[selected]
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
      groups: (json['groups'] as List).map((e) => IDName.fromJson(e)).toList(),
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
