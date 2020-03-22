import 'package:flutter/material.dart';
import 'package:tf_toast/Toast.dart';
import 'package:dio/dio.dart';

export 'package:dio/dio.dart';
export 'package:tf_toast/Toast.dart';
export 'package:tf_toast/ToastConfig.dart';

class Helper {
  static Dio dio;

  static Future loading(Future api, BuildContext context, {String title, String success}) {
    toast(context, title: title);

    return api.then((res) {
      success != null ? toast(context, title: success ?? '加载完成', duration: 1) : Toast.dismiss();
      return Future.value(res);
    }, onError: (e) {
      toast(context, title: '网络异常', duration: 1);
      return Future.error(e);
    });
  }

  static toast(BuildContext context, {String title, double duration = 11}) {
    try {
      Toast.dismiss();
    } catch (e) {}

    Toast.show(context, title: title ?? '加载中', duration: duration);
  }

  static Dio get fetch {
    if (dio == null) {
      dio = Dio();
      dio.options.connectTimeout = 5000;
    }

    return dio;
  }

  static String serializeTime(int time) {
    return '${(time ~/ 60).toString().padLeft(2, '0')}:${(time % 60).toString().padLeft(2, '0')}';
  }

  static String ellipsis(String str, int len) {
    if (str == null) str = '';
    if (str.length <= len) return str;
    return '${str.substring(0, len)}...';
  }
}
