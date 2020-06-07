import 'package:flutter/foundation.dart';


class Utils {

  static Future sleep(int seconds) async {
    debugPrint("Sleeping for $seconds seconds ...");
    await Future.delayed(Duration(seconds: seconds));
  }

}
