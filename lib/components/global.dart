import 'dart:convert';

import 'package:lifecostapp/components/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Global {
  static const baseInfoKey = 'base-info';

  static BaseInfo? _baseInfo;
  static bool devMode = false;

  static SharedPreferences? gSP;

  static void realInit(SharedPreferences sp) {
    gSP = sp;

    if (sp.containsKey(baseInfoKey)) {
      String? s = sp.getString(baseInfoKey);
      if (s != null) {
        _baseInfo = BaseInfo.fromJson(json.decode(s));
      }
    }
  }

  static void init() {
    SharedPreferences.getInstance().then((sp) => realInit(sp));
  }

  static set baseInfo(BaseInfo? bi) {
    _baseInfo = bi;

    if (bi != null) {
      String d = json.encode(_baseInfo);
      SharedPreferences.getInstance()
          .then((sp) => {sp.setString('base-info', d)});
    } else {
      SharedPreferences.getInstance().then((sp) => {sp.remove('base-info')});
    }
  }

  static BaseInfo? get baseInfo {
    return _baseInfo;
  }

  static List<CacheRecord> getCachedRecordList() {
    var records = gSP?.getStringList('cached-records');
    if (records == null) {
      return [];
    }

    return records.map((e) => CacheRecord.fromJson(json.decode(e))).toList();
  }

  static void addToCachedRecordList(CacheRecord reccord) {
    var records = gSP?.getStringList('cached-records');
    records ??= [];

    records.insert(0, json.encode(reccord));
    gSP?.setStringList('cached-records', records);
  }

  static void removeCachedRecordList() {
    gSP?.remove('cached-records');
  }

  static void savetStatByLables(bool statByLables) {
    gSP?.setBool('statByLables', statByLables);
  }

  static void savettatLabelIDs(List<IDName> statLabelIDs) {
    gSP?.setString('statLabelIDs', json.encode(statLabelIDs));
  }

  static bool getStatByLables() {
    return gSP?.getBool('statByLables') ?? false;
  }

  static List<IDName> getStatLabelIDs() {
    var s = gSP?.getString('statLabelIDs');
    if (s == null) {
      return [];
    }

    return (json.decode(s) as List).map((e) => IDName.fromJson(e)).toList();
  }

  static void setLastRecordFromSelectedIDs(List<String> ids) {
    gSP?.setStringList('lastRecordFromSelectedIDs', ids);
  }

  static List<String>? getLastRecordFromSelectedIDs() {
    return gSP?.getStringList('lastRecordFromSelectedIDs');
  }

  static void setLastRecordToSelectedIDs(List<String> ids) {
    gSP?.setStringList('lastRecordToSelectedIDs', ids);
  }

  static List<String>? getLastRecordToSelectedIDs() {
    return gSP?.getStringList('lastRecordToSelectedIDs');
  }
}
