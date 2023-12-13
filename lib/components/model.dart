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
}
