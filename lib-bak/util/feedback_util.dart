import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

const int toastDuration = 500;

class FeedbackUtil {
  FeedbackUtil._();

  static void showError(String message,{int dur = toastDuration}) {
    EasyLoading.showError(message,duration: Duration(milliseconds: dur));
  }

  static void showSuccess(String message,{int dur = toastDuration}) {
    EasyLoading.showSuccess(message,duration: Duration(milliseconds: dur));
  }

  static void showInfo(String message,{int dur = toastDuration}) {
    EasyLoading.showInfo(message,duration: Duration(milliseconds: dur));
  }

  static void showLoading(String message) {
    EasyLoading.show(status: message);
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
