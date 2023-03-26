import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isUser() async {
  SharedPreferences session = await SharedPreferences.getInstance();
  if (session.getString("type") == "User") {
    return true;
  } else {
    return false;
  }
}
