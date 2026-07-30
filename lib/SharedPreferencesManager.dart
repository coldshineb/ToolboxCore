import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static SharedPreferences? sharedPreferences;

  // 设置持久化数据
  Future<int> loadPref() async {
    sharedPreferences = await SharedPreferences.getInstance(); // 获取持久化数据
    return 0;
  }
}
